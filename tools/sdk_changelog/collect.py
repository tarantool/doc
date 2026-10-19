#!/usr/bin/env python3
"""Draft an Enterprise SDK changelog entry from the changelogs of bundled modules.

Pipeline:
  1. Diff the SDK between two release tags: BundleRocks.cmake (rock versions),
     CMakeLists.txt (tt-ee, cartridge-cli), CHANGELOG.md (Tarantool series bumps).
  2. For every bumped component, fetch its changelog and keep the versions in
     (old, new]. Sources are tried in order: the configured one, GitHub
     releases, commit subjects between the version tags. For Tarantool, the
     Community Edition changelog is merged with the Enterprise one.
  3. Render an RST section in the style of doc/release/enterprise-changelog.rst
     and insert it above the latest revision.
  4. Optionally (--pr) commit it to a new branch off the base branch and open
     a draft pull request with gh.

The text is collected as is (English, no rewriting); a writer edits the draft.
See README.md for setup.
"""

import argparse
import base64
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from collections import OrderedDict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
CHANGELOG_RST = os.path.join("doc", "release", "enterprise-changelog.rst")

KIND_ORDER = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"]
KIND_ALIASES = {
    "added": "Added",
    "new features": "Added",
    "features": "Added",
    "functionality added or changed": "Added",
    "changed": "Changed",
    "changes": "Changed",
    "improvements": "Changed",
    "deprecated": "Deprecated",
    "removed": "Removed",
    "fixed": "Fixed",
    "bugs fixed": "Fixed",
    "bug fixes": "Fixed",
    "security": "Security",
}
# Sections that only point elsewhere (Tarantool EE -> CE release page).
SKIP_SECTIONS = {"community edition"}


def log(msg):
    print(msg, file=sys.stderr)


# --------------------------------------------------------------------------
# Versions

def vkey(version):
    """Sortable key for '1.7.6', 'v2.14.0', '0.0.12-1' (rockspec revision dropped)."""
    version = version.lstrip("v").split("-")[0]
    return tuple(int(p) if p.isdigit() else 0 for p in version.split("."))


def in_range(version, old, new):
    return (old is None or vkey(version) > vkey(old)) and vkey(version) <= vkey(new)


def plain(version):
    return version.lstrip("v").split("-")[0]


# --------------------------------------------------------------------------
# Sources

def http_get(url, headers=None):
    req = urllib.request.Request(url, headers=headers or {})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        if e.code == 403 and "api.github.com" in url:
            sys.exit("GitHub API rate limit exceeded: run `gh auth login` (or set GH_TOKEN) and retry")
        raise


def have_gh():
    if not shutil.which("gh"):
        return False
    return subprocess.run(["gh", "auth", "status"], capture_output=True).returncode == 0


GH = None


def github(path):
    """GET a GitHub API path; uses gh (works for private repos) when logged in."""
    global GH
    if GH is None:
        GH = have_gh()
    if GH:
        res = subprocess.run(["gh", "api", path], capture_output=True, text=True)
        if res.returncode != 0:
            return None
        return json.loads(res.stdout)
    headers = {"Accept": "application/vnd.github+json"}
    if os.environ.get("GH_TOKEN"):
        headers["Authorization"] = "Bearer " + os.environ["GH_TOKEN"]
    body = http_get("https://api.github.com/" + path, headers)
    return json.loads(body) if body else None


def github_file(repo, path, refs):
    global GH
    if GH is None:
        GH = have_gh()
    if not GH:  # raw files are not rate-limited like the anonymous API
        for ref in refs:
            text = http_get("https://raw.githubusercontent.com/%s/%s/%s" % (repo, ref, path))
            if text is not None:
                return text
        return None
    for ref in refs:
        data = github("repos/%s/contents/%s?ref=%s" % (repo, path, urllib.parse.quote(ref)))
        if data and "content" in data:
            return base64.b64decode(data["content"]).decode("utf-8")
    return None


PUBLIC = {}


def link_repo(cfg, repo):
    """Repo to link issue refs to, or None: GitLab and private repos are not public."""
    if cfg.get("source") == "gitlab" or not repo:
        return None
    if repo not in PUBLIC:
        data = github("repos/" + repo)
        PUBLIC[repo] = bool(data) and not data.get("private", True)
    return repo if PUBLIC[repo] else None


def github_releases(repo):
    releases, page = [], 1
    while True:
        chunk = github("repos/%s/releases?per_page=100&page=%d" % (repo, page))
        if not chunk:
            return releases
        releases += chunk
        if len(chunk) < 100:
            return releases
        page += 1


class GitLab:
    def __init__(self):
        self.url = os.environ.get("GITLAB_URL", "").rstrip("/")
        self.token = os.environ.get("GITLAB_TOKEN")

    @property
    def enabled(self):
        return bool(self.url and self.token)

    def file(self, project, path, ref):
        if not self.enabled:
            return None
        url = "%s/api/v4/projects/%s/repository/files/%s/raw?ref=%s" % (
            self.url, urllib.parse.quote(project, safe=""),
            urllib.parse.quote(path, safe=""), urllib.parse.quote(ref))
        return http_get(url, {"PRIVATE-TOKEN": self.token})


class Sdk:
    """Reads SDK files at a tag from a local clone (--sdk-dir) or GitLab."""

    def __init__(self, sdk_dir, gitlab, project):
        self.sdk_dir, self.gitlab, self.project = sdk_dir, gitlab, project

    def file(self, path, ref):
        if self.sdk_dir:
            res = subprocess.run(["git", "-C", self.sdk_dir, "show", "%s:%s" % (ref, path)],
                                 capture_output=True, text=True)
            if res.returncode == 0:
                return res.stdout
            if not self.gitlab.enabled:
                sys.exit("SDK: cannot read %s at %s: %s" % (path, ref, res.stderr.strip()))
            # The tag is not fetched into the local clone: fall back to GitLab.
        if not self.gitlab.enabled:
            sys.exit("SDK: pass --sdk-dir or set GITLAB_URL and GITLAB_TOKEN")
        text = self.gitlab.file(self.project, path, ref)
        if text is None:
            sys.exit("SDK: %s not found at %s" % (path, ref))
        return text

    def subjects(self, old_ref, new_ref):
        """Commit subjects in old_ref..new_ref (local clone only)."""
        if not self.sdk_dir:
            return ""
        res = subprocess.run(["git", "-C", self.sdk_dir, "log", "--format=%s",
                              "%s..%s" % (old_ref, new_ref)], capture_output=True, text=True)
        return res.stdout


# --------------------------------------------------------------------------
# What changed in the SDK

def parse_rocks(cmake):
    """{rock: highest version} from add_public_rock/add_private_rock calls."""
    rocks = OrderedDict()
    for name, version in re.findall(r"add_(?:public|private)_rock\(\s*(\S+)\s+([^\s)]+)", cmake):
        if name not in rocks or vkey(version) > vkey(rocks[name]):
            rocks[name] = version
    return rocks


def parse_cmake_var(cmake, var):
    m = re.search(r"set\(%s\s+\"?([^\s)\"]+)" % re.escape(var), cmake)
    return m.group(1) if m else None


def parse_tarantool_version(sdk_changelog, series, upto_rev):
    """Latest 'bump tarantool <series> ... <version>' in SDK revisions <= upto_rev."""
    rev, found = None, []
    for line in sdk_changelog.splitlines():
        head = re.match(r"#{1,2} \[?r?(\d+)(?:\.0\.0)?\]?", line)
        if head:
            rev = int(head.group(1))
            continue
        m = tarantool_bump(series).search(line)
        if m and rev is not None and rev <= upto_rev:
            found.append(m.group(1))
    return max(found, key=vkey) if found else None


def revision_lines(sdk_changelog, prev, rev):
    """Lines of the SDK CHANGELOG sections for revisions in (prev, rev].

    None if there is no section for rev yet (it appears when the tag is made).
    """
    cur, lines, seen = None, [], False
    for line in sdk_changelog.splitlines():
        head = re.match(r"#{1,2} \[?r?(\d+)(?:\.0\.0)?\]?", line)
        if head:
            cur = int(head.group(1))
            seen = seen or cur == rev
            continue
        if cur is not None and prev < cur <= rev and line.strip():
            lines.append(line)
    return lines if seen else None


def mentioned(name, text):
    """Whether a component name occurs in text as a whole word ('graphqlapi' != 'graphqlapi-helpers')."""
    return re.search(r"(?<![\w-])%s(?![\w-])" % re.escape(name), text, re.I) is not None


def tarantool_bump(series):
    return re.compile(r"bump tarantool[^\n]*?%s[^\n]*?(%s\.\d+)" % (
        re.escape(series), re.escape(series)), re.I)


# --------------------------------------------------------------------------
# Changelog parsing. A release is {"version", "intro": [str], "groups":
# OrderedDict[(subsystem or None, kind)] -> [item text]}.

def kind_of(title):
    title = title.strip().strip(":").strip()
    return KIND_ALIASES.get(title.lower(), title)


PARA = "\0"  # marks a loose paragraph among list items
NOLINK = "\1"  # marks text whose issue refs point to a private repo


def split_items(lines):
    """Bullets ('-', '*') with continuation lines and nested bullets; loose paragraphs too."""
    items = []  # [text, [children], is_bullet]
    cur = None
    for line in lines:
        bullet = re.match(r"^(\s*)[-*]\s+(.*)$", line)
        if bullet and len(bullet.group(1)) < 2:
            cur = [bullet.group(2), [], True]
            items.append(cur)
        elif bullet and cur:
            cur[1].append(bullet.group(2))
        elif not line.strip():
            if cur and not cur[1]:
                cur = None
        elif cur is None:
            cur = [line.strip(), [], False]
            items.append(cur)
        elif cur[1]:
            cur[1][-1] += " " + line.strip()
        else:
            cur[0] += " " + line.strip()
    out = []
    for text, children, is_bullet in items:
        if children:
            text += "\n\n" + "\n".join("  * " + c for c in children)
        if text.strip():
            out.append((text.strip() if is_bullet else PARA + text.strip()))
    return out


def inline_refs(text):
    """Markdown reference links '[text][ref]' + '[ref]: url' -> inline links."""
    refs = dict(re.findall(r"^\s*[-*]?\s*\[([^\]]+)\]:\s*(\S+)\s*$", text, re.M))
    text = re.sub(r"^\s*[-*]?\s*\[[^\]]+\]:\s*\S+\s*$\n?", "", text, flags=re.M)
    return re.sub(r"\[([^\]]+)\]\[([^\]]+)\]",
                  lambda m: "[%s](%s)" % (m.group(1), refs[m.group(2)]) if m.group(2) in refs else m.group(0),
                  text)


def parse_md_sections(text, version):
    """Markdown body of one release: '## Kind' / '### Subsystem' or '### Kind'.

    Headings that are not a change kind ('Overview', 'Compatibility') before
    the first kind go to the intro.
    """
    rel = {"version": version, "intro": [], "groups": OrderedDict()}
    kind, subsystem, buf, skip = None, None, [], False

    def flush():
        items = split_items(buf)
        if skip:
            return
        if kind is None:
            rel["intro"].extend(items)
        elif items:
            rel["groups"].setdefault((subsystem, kind), []).extend(items)

    for line in inline_refs(text).splitlines():
        if re.match(r"^#\s", line) or re.match(r"^(Date|Tag):", line):
            continue
        m = re.match(r"^(#{2,4})\s+(.*)$", line)
        label = re.match(r"^\s*\**\s*([A-Za-z ]+?)\s*\**\s*:\s*\**\s*$", line)
        if label and kind_of(label.group(1)) in KIND_ORDER:
            m = label  # 'Fixed:' / '**Fixed:**' used as a heading
        if m:
            flush()
            buf = []
            title = m.group(m.lastindex).strip()
            k = kind_of(title)
            skip = title.lower() in SKIP_SECTIONS
            if skip:
                continue
            if k in KIND_ORDER:
                kind, subsystem = k, None
            elif kind is not None:
                subsystem = title  # '### Core' under '## Bugs fixed'
            continue
        buf.append(line)
    flush()
    return rel


def parse_md_changelog(text, old, new):
    """Keep a Changelog style: '## [1.7.6] - date' (or '#' / no brackets)."""
    releases, cur, buf = [], None, []
    head = re.compile(r"^#{1,3}\s*\[?v?(\d+(?:\.\d+)+)\]?(?:\s|$|-)")
    for line in text.splitlines() + ["# [0.0.0]"]:
        m = head.match(line)
        if m:
            if cur and in_range(cur, old, new):
                releases.append(parse_md_sections("\n".join(buf), cur))
            cur, buf = m.group(1), []
        elif cur:
            buf.append(line)
    return sorted(releases, key=lambda r: vkey(r["version"]))


def parse_rst_changelog(text, old, new):
    """cartridge style: '[2.18.1] - date' over '----', kinds over '~~~~'."""
    md = []
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if re.match(r"^[-~=^]{3,}$", line):
            continue
        prev_rule = i > 0 and re.match(r"^[-~]{3,}$", lines[i - 1] or "")
        next_rule = i + 1 < len(lines) and re.match(r"^([-~])\1{2,}$", lines[i + 1])
        if next_rule and line.strip():
            level = "##" if next_rule.group(1) == "-" else "###"
            md.append("%s %s" % (level, line.strip()))
        elif prev_rule and not line.strip():
            continue
        else:
            md.append(line)
    return parse_md_changelog("\n".join(md), old, new)


def parse_releases(releases, old, new):
    out = []
    for r in releases:
        tag = r.get("tag_name", "")
        if re.match(r"^v?\d+(\.\d+)+$", tag) and in_range(tag, old, new):
            out.append(parse_md_sections(r.get("body") or "", plain(tag)))
    return sorted(out, key=lambda r: vkey(r["version"]))


# --------------------------------------------------------------------------
# Component collection

def github_commits(repo, old, new):
    """Commit subjects between two version tags ('1.0.0' or 'v1.0.0')."""
    for o in (old, "v" + old):
        for n in (new, "v" + new):
            data = github("repos/%s/compare/%s...%s" % (repo, o, n))
            if data and "commits" in data:
                subjects = [c["commit"]["message"].splitlines()[0] for c in data["commits"]]
                return [x for x in subjects if not x.startswith("Merge ")], \
                    "https://github.com/%s/compare/%s...%s" % (repo, o, n)
    return None, None


def try_source(source, repo, cfg, old, new, gitlab):
    """One source -> (releases or None, description)."""
    oldv, newv = (plain(old) if old else None), plain(new)
    if source == "releases":
        rels = github_releases(repo)
        if not rels:
            return None, "no GitHub releases in %s" % repo
        return parse_releases(rels, oldv, newv), "https://github.com/%s/releases" % repo
    if source == "commits":
        if not oldv:
            return None, "no previous version to compare"
        subjects, where = github_commits(repo, oldv, newv)
        if subjects is None:
            return None, "cannot compare %s...%s in %s" % (oldv, newv, repo)
        if not subjects:
            return [], where
        rel = {"version": newv, "intro": [], "groups": OrderedDict()}
        rel["groups"][(None, "Commits")] = subjects
        return [rel], where + " (no changelog: commit subjects, rewrite or drop)"
    path = cfg.get("file", "CHANGELOG.md")
    refs = [newv, "v" + newv, "master", "main"]
    text, where = None, None
    if source == "gitlab":
        if not gitlab.enabled:
            return None, "set GITLAB_URL and GITLAB_TOKEN to read %s from GitLab" % repo
        for ref in refs:
            text = gitlab.file(repo, path, ref)
            if text is not None:
                where = "GitLab %s:%s@%s" % (repo, path, ref)
                break
    else:
        text, where = github_file(repo, path, refs), "https://github.com/%s/blob/master/%s" % (repo, path)
    if text is None:
        return None, "%s/%s is not accessible" % (repo, path)
    parse = parse_rst_changelog if path.endswith(".rst") else parse_md_changelog
    return parse(text, oldv, newv), where


def collect_module(name, cfg, old, new, gitlab):
    """Returns (releases, source description); releases is None if nothing was found."""
    source = cfg.get("source", "changelog")
    repo = cfg.get("repo", "tarantool/" + name)
    if source == "manual":
        return None, "no changelog, fill in manually"
    chain = [source] + [x for x in ("releases", "commits") if x != source]
    misses = []
    for src in chain:
        rels, where = try_source(src, repo, cfg, old, new, gitlab)
        if rels:
            if misses:
                where += " (fallback; %s)" % "; ".join(misses)
            return rels, where
        misses.append(where if rels is None else "%s: no entries for this range" % where)
    return None, "; ".join(misses)


def mark_nolink(rel):
    rel["intro"] = [NOLINK + i for i in rel["intro"]]
    for key in rel["groups"]:
        rel["groups"][key] = [NOLINK + i for i in rel["groups"][key]]
    return rel


def collect_tarantool(cfg, gitlab, old, new):
    """CE + EE changelogs for every patch release in (old, new] of one series.

    The EE changelog has its own overview and EE-only changes and refers to
    the CE release for the rest; EE issue refs are not linked (private repo).
    """
    o, n = vkey(old), vkey(new)
    versions = ["%d.%d.%d" % (n[0], n[1], p) for p in range(o[2] + 1, n[2] + 1)]
    releases, sources = [], []
    for v in versions:
        text = None
        ce_file = cfg["gitlab_file"].format(version=v)
        if gitlab.enabled:
            text = gitlab.file(cfg["gitlab_project"], ce_file, v)
            if text:
                sources.append("GitLab %s:%s" % (cfg["gitlab_project"], ce_file))
        if text is None:
            rel = github("repos/%s/releases/tags/%s" % (cfg["github_repo"], v))
            text = rel and rel.get("body")
            if text:
                sources.append(rel.get("html_url"))
        if text is None:
            return None, "changelog for Tarantool %s not found" % v
        ce = parse_md_sections(text, v)

        ee_text = None
        if cfg.get("ee_github_repo"):
            ee_file = cfg["ee_file"].format(version=v)
            ee_text = github_file(cfg["ee_github_repo"], ee_file, [v])
            if ee_text:
                sources.append("%s:%s (EE)" % (cfg["ee_github_repo"], ee_file))
            else:
                sources.append("TODO: EE changelog %s:%s is not accessible" % (cfg["ee_github_repo"], ee_file))
        if ee_text:
            ee = mark_nolink(parse_md_sections(ee_text, v))
            for key, items in ce["groups"].items():
                ee["groups"].setdefault(key, []).extend(items)
            releases.append(ee)
        else:
            releases.append(ce)
    return releases, ", ".join(sources)


# --------------------------------------------------------------------------
# RST rendering

def to_rst(text, repo):
    """Inline Markdown -> RST, issue refs -> links (as in the existing page)."""
    if text.startswith(NOLINK):
        text, repo = text[len(NOLINK):], None
    text = re.sub(r"(?<!`)`([^`]+)`(?![`_])", r"``\1``", text)
    text = re.sub(r"\[([^\]]+)\]\((https?://[^)]+)\)", r"`\1 <\2>`__", text)
    text = re.sub(r">`_(?!_)", ">`__", text)
    if repo:
        base = "https://github.com/%s/issues/" % repo
        text = re.sub(r"(?<![\w/<`-])gh-(\d+)(?![\w>])",
                      lambda m: "`gh-%s <%s%s>`__" % (m.group(1), base, m.group(1)), text)
        text = re.sub(r"(?<=\()#(\d+)(?=\))",
                      lambda m: "`#%s <%s%s>`__" % (m.group(1), base, m.group(1)), text)
    return text


def render_items(items, repo):
    """List items as '* ...' and loose paragraphs as is, blank lines around paragraphs."""
    out, prev_para = "", None
    for i in items:
        para = PARA in i
        text = to_rst(i.replace(PARA, ""), repo)
        if prev_para is not None:
            out += "\n\n" if (para or prev_para) else "\n"
        out += text if para else "* " + text
        prev_para = para
    return out + "\n"


def heading(title, char):
    return "%s\n%s\n" % (title, char * len(title))


def render_component(title, anchor, releases, source, repo, subsystem_char="^"):
    out = []
    if anchor:
        out.append(".. _%s:\n" % anchor)
    out.append(heading(title, "~"))
    out.append(".. Source: %s\n" % source)
    if releases is None:
        out.append(".. TODO: %s.\n" % source)
        return "\n".join(out)
    if not releases:
        out.append(".. TODO: no changelog entries found for this range.\n")
        return "\n".join(out)
    if len(releases) > 1:
        vs = [r["version"] for r in releases]
        out.append("This release spans versions %s and %s.\n" % (", ".join(vs[:-1]), vs[-1]))
    for r in releases:
        if r["intro"]:
            out.append(render_items(r["intro"], repo))
    merged = OrderedDict()
    for r in releases:
        for key, items in r["groups"].items():
            merged.setdefault(key, []).extend(items)
    subsystems = OrderedDict((s, None) for s, _ in merged)
    rank = lambda k: KIND_ORDER.index(k) if k in KIND_ORDER else -1
    for sub in subsystems:
        if sub:
            out.append(heading(sub, subsystem_char))
        for (s, kind), items in sorted(((k, v) for k, v in merged.items() if k[0] == sub),
                                       key=lambda kv: rank(kv[0][1])):
            out.append("**%s:**\n" % kind)
            out.append(render_items(items, repo))
    return "\n".join(out)


def insert_section(rst, section, rev, replace=False, alongside=False):
    cur = re.search(r"^r%d\n-+\n" % rev, rst, re.M)
    if cur and not (replace or alongside):
        sys.exit("r%d is already in %s (use --replace or --alongside)" % (rev, CHANGELOG_RST))
    if cur and replace:
        nxt = re.compile(r"^r\d+\n-+\n", re.M).search(rst, cur.end())
        end = nxt.start() if nxt else len(rst)
        return rst[:cur.start()] + section + "\n\n" + rst[end:]
    m = re.search(r"^r\d+\n-+\n", rst, re.M)
    pos = m.start() if m else len(rst)
    return rst[:pos] + section + "\n\n" + rst[pos:]


# --------------------------------------------------------------------------
# Git / PR

def run(cmd, cwd=None):
    log("$ " + " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)


def https_remote():
    """origin as an HTTPS URL, so that fetch/push go through gh credentials, not SSH keys."""
    url = subprocess.run(["git", "remote", "get-url", "origin"], cwd=REPO_ROOT,
                         capture_output=True, text=True, check=True).stdout.strip()
    m = re.match(r"^(?:git@|ssh://git@)github\.com[:/](.+?)(?:\.git)?$", url)
    return "https://github.com/%s.git" % m.group(1) if m else url


# Use gh as the git credential helper for this call only.
GIT_GH = ["git", "-c", "credential.helper=", "-c", "credential.helper=!gh auth git-credential"]


def open_pr(rev, section, args, summary):
    branch = args.branch or "%s-r%d-changelog" % (args.base, rev)
    remote = https_remote()
    run(GIT_GH + ["fetch", remote, "%s:refs/remotes/origin/%s" % (args.base, args.base)], cwd=REPO_ROOT)
    tmp = tempfile.mkdtemp(prefix="sdk-changelog-")
    wt = os.path.join(tmp, "wt")
    remote_sha = subprocess.run(GIT_GH + ["ls-remote", "--heads", remote, branch], cwd=REPO_ROOT,
                                capture_output=True, text=True, check=True).stdout.split("\t")[0].strip()
    if remote_sha and not args.update:
        sys.exit("Branch %s already exists on GitHub (use --update to rebuild its PR)" % branch)
    run(["git", "worktree", "add", "-B", branch, wt, "origin/" + args.base], cwd=REPO_ROOT)
    try:
        path = os.path.join(wt, CHANGELOG_RST)
        with open(path, encoding="utf-8") as f:
            text = insert_section(f.read(), section, rev, args.replace, args.alongside)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        run(["git", "add", CHANGELOG_RST], cwd=wt)
        run(["git", "commit", "-m", "Add SDK r%d changelog draft" % rev], cwd=wt)
        push = ["push", remote, "%s:refs/heads/%s" % (branch, branch)]
        if remote_sha:  # rebuild the bot branch from scratch, only if nobody pushed to it meanwhile
            push.insert(1, "--force-with-lease=refs/heads/%s:%s" % (branch, remote_sha))
        run(GIT_GH + push, cwd=wt)
        body = ("Draft of the Enterprise SDK r%d changelog collected by "
                "`tools/sdk_changelog`. Texts are copied from the module changelogs "
                "as is; edit and translate before merging.\n\n%s\n" % (rev, summary))
        repo = re.sub(r"^https://github\.com/|\.git$", "", remote)
        if remote_sha:
            run(["gh", "pr", "edit", branch, "--repo", repo, "--body", body], cwd=wt)
            run(["gh", "pr", "view", branch, "--repo", repo, "--json", "url", "--jq", ".url"], cwd=wt)
            return
        run(["gh", "pr", "create", "--draft", "--repo", repo, "--base", args.base, "--head", branch,
             "--title", "SDK r%d changelog" % rev, "--body", body], cwd=wt)
    finally:
        run(["git", "worktree", "remove", "--force", wt], cwd=REPO_ROOT)
        run(["git", "branch", "-D", branch], cwd=REPO_ROOT)
        shutil.rmtree(tmp, ignore_errors=True)


# --------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("revision", help="SDK revision to describe, e.g. r712")
    p.add_argument("--from", dest="prev", help="previous SDK revision (default: revision - 1)")
    p.add_argument("--sdk-dir", default=os.environ.get("SDK_DIR"),
                   help="local clone of the SDK repo with tags fetched (default: $SDK_DIR)")
    p.add_argument("--new-ref", help="SDK git ref of the new revision (default: its tag)")
    p.add_argument("--old-ref", help="SDK git ref of the previous revision (default: its tag)")
    p.add_argument("--write", action="store_true", help="insert the section into %s" % CHANGELOG_RST)
    p.add_argument("--pr", action="store_true", help="commit to a new branch and open a draft PR")
    p.add_argument("--replace", action="store_true", help="replace the revision section if it already exists")
    p.add_argument("--alongside", action="store_true",
                   help="if the revision section exists, keep it and add the draft above it as 'rNNN (bot draft)'")
    p.add_argument("--update", action="store_true",
                   help="with --pr: rebuild the bot branch and PR if they already exist")
    p.add_argument("--all", action="store_true",
                   help="describe every component changed in the bundle, not only the ones in the SDK CHANGELOG")
    p.add_argument("--base", default="2.11", help="base branch for the PR (default: 2.11)")
    p.add_argument("--branch", help="PR branch name (default: <base>-r<N>-changelog)")
    args = p.parse_args()

    with open(os.path.join(HERE, "modules.json"), encoding="utf-8") as f:
        cfg = json.load(f)
    rev = int(args.revision.lstrip("r"))
    prev = int(args.prev.lstrip("r")) if args.prev else rev - 1
    tag = cfg["sdk"]["tag_format"]
    new_ref = args.new_ref or tag.format(rev=rev)
    old_ref = args.old_ref or tag.format(rev=prev)

    gitlab = GitLab()
    sdk = Sdk(args.sdk_dir, gitlab, os.environ.get("SDK_PROJECT", cfg["sdk"]["gitlab_project"]))

    old_rocks = parse_rocks(sdk.file("BundleRocks.cmake", old_ref))
    new_rocks = parse_rocks(sdk.file("BundleRocks.cmake", new_ref))
    old_cmake = sdk.file("CMakeLists.txt", old_ref)
    new_cmake = sdk.file("CMakeLists.txt", new_ref)
    sdk_log = sdk.file("CHANGELOG.md", new_ref)
    series = cfg["tarantool"]["series"]
    old_tnt = parse_tarantool_version(sdk_log, series, prev)
    new_tnt = parse_tarantool_version(sdk_log, series, rev)
    # The SDK CHANGELOG gets the new revision section only when it is tagged;
    # before that, take the bump from the commit subjects.
    bumps = tarantool_bump(series).findall(sdk.subjects(old_ref, new_ref))
    if bumps:
        new_tnt = max(bumps + [new_tnt or bumps[0]], key=vkey)

    # Which components to describe: the ones named in the SDK CHANGELOG section
    # of the revision (or, before it is tagged, in the commit subjects).
    lines = revision_lines(sdk_log, prev, rev)
    if lines is None:
        subjects = sdk.subjects(old_ref, new_ref)
        lines = subjects.splitlines() if subjects else None
        log("No r%d section in the SDK CHANGELOG yet; using %s" % (
            rev, "commit subjects" if lines else "all bundle changes"))
    scope_text = "\n".join(lines or [])
    in_scope = lambda name: args.all or lines is None or mentioned(name, scope_text)
    skipped = []

    if args.alongside:
        # Next to a reviewed section of the same revision: own title and anchors.
        parts = [heading("r%d (bot draft)" % rev, "-"),
                 "..  note::\n\n    This section is a draft collected automatically by "
                 "``tools/sdk_changelog`` from the component changelogs. It is not reviewed.\n",
                 ".. TODO: intro — what this release bumps and why it matters.\n"]
        anchor = lambda name: "enterprise-changelog-r%d-bot-%s" % (rev, name)
    else:
        parts = [heading("r%d" % rev, "-"),
                 ".. TODO: intro — what this release bumps and why it matters.\n"]
        anchor = lambda name: "enterprise-changelog-r%d-%s" % (rev, name)
    summary = []

    if old_tnt and new_tnt and vkey(new_tnt) > vkey(old_tnt) and not in_scope("tarantool"):
        skipped.append("Tarantool %s -> %s" % (old_tnt, new_tnt))
    elif old_tnt and new_tnt and vkey(new_tnt) > vkey(old_tnt):
        log("Tarantool %s -> %s" % (old_tnt, new_tnt))
        rels, src = collect_tarantool(cfg["tarantool"], gitlab, old_tnt, new_tnt)
        parts.append(render_component("Tarantool %s -> %s" % (old_tnt, new_tnt), None,
                                      rels, src, cfg["tarantool"]["github_repo"]))
        summary.append("- Tarantool %s -> %s" % (old_tnt, new_tnt))

    for name, ccfg in cfg["cmake"].items():
        old = parse_cmake_var(old_cmake, ccfg["var"])
        new = parse_cmake_var(new_cmake, ccfg["var"])
        if not new or (old and vkey(old) >= vkey(new)):
            continue
        title = "%s %s -> %s" % (name, plain(old), plain(new)) if old else "%s %s (new)" % (name, plain(new))
        if not in_scope(name):
            skipped.append(title)
            continue
        log(title)
        rels, src = collect_module(name, ccfg, old, new, gitlab)
        parts.append(render_component(title, anchor(name), rels, src, link_repo(ccfg, ccfg.get("repo"))))
        summary.append("- " + title + ("" if rels else " — **TODO: %s**" % src))

    for name, version in new_rocks.items():
        old = old_rocks.get(name)
        if old and vkey(old) >= vkey(version):
            continue
        title = "%s %s -> %s" % (name, plain(old), plain(version)) if old else "%s %s (new)" % (name, plain(version))
        if not in_scope(name):
            skipped.append(title)
            continue
        log(title)
        mcfg = dict(cfg["default"], **cfg["rocks"].get(name, {}))
        rels, src = collect_module(name, mcfg, old, version, gitlab)
        parts.append(render_component(title, anchor(name), rels, src,
                                      link_repo(mcfg, mcfg.get("repo", "tarantool/" + name))))
        summary.append("- " + title + ("" if rels else " — **TODO: %s**" % src))
    for name in old_rocks:
        if name not in new_rocks:
            if not in_scope(name):
                skipped.append("%s removed" % name)
                continue
            summary.append("- %s removed" % name)
            parts.append(heading("%s (removed)" % name, "~"))

    if skipped:
        log("Not in the SDK CHANGELOG, skipped: " + ", ".join(skipped))

    section = "\n\n".join(parts).rstrip() + "\n"
    if args.pr:
        open_pr(rev, section, args, "\n".join(summary))
    elif args.write:
        path = os.path.join(REPO_ROOT, CHANGELOG_RST)
        with open(path, encoding="utf-8") as f:
            text = insert_section(f.read(), section, rev, args.replace, args.alongside)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        log("Written to " + path)
    else:
        sys.stdout.write(section)


if __name__ == "__main__":
    main()
