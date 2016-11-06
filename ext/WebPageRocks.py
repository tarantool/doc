import os
import sys
import urlparse

from glob import glob
from pprint import pprint

from docutils import nodes, utils
from docutils.parsers.rst import Directive, directives

from lupa import LuaRuntime, lua_type

class wp_rock(nodes.General, nodes.Element): pass

class wp_rock_list(nodes.General, nodes.Element): pass

class WebPageRocksDirectives(Directive):
    required_arguments = 0
    optional_arguments = 0
    has_content = False
    option_spec = {
        'path': directives.path
    }

    def process_rockspec(self, rsname):
        source = None
        rock_def = {}
        try:
            with open(rsname, 'r') as fh:
                source = fh.read()
        except Exception as e:
            return self.severe('failed to open/read rockspec: %s' % repr(e))
        lr = LuaRuntime()
        try:
            lr.execute(source)
            _G = lr.globals()
            rock_def['package']     = _G['package']
            rock_def['version']     = _G['version']
            rock_def['source']      = dict(_G['source'])
            rock_def['description'] = dict(_G['description'])
        except Exception as e:
            return self.severe('failed process rockspec: %s' % repr(e))

        rock = wp_rock()
        rock.defs = rock_def
        rock.filename = os.path.basename(rsname)
        return rock

    def process_manifest(self, manifest_path):
        if manifest_path.endswith('.zip'):
            return None
        version = ''
        components = os.path.basename(manifest_path).split('-')
        if len(components) > 2 or len(components) < 1 or \
           components[0] != 'manifest':
            return None
        if len(components) == 1:
            pass
        elif components[1] in ('5.1', '5.2', '5.3'):
            version = 'Lua %s ' % components[1]
        elif components[1] in ('jit', 'luajit'):
            version = 'LuaJIT '
        name = version + 'manifest file'
        zip_manifest_path = None
        if os.path.exists(manifest_path + '.zip'):
            zip_manifest_path = manifest_path + '.zip'
        return (name, manifest_path, zip_manifest_path)

    def run(self):
        rocks_repo = self.options.get('path', None)

        if not rocks_repo:
            return [self.severe('file_path option is missing')]
        rockspecs = glob(os.path.join(rocks_repo, '*.rockspec'))
        manifests = glob(os.path.join(rocks_repo, 'manifest*'))

        if not rockspecs:
            return [self.severe('rockspecs aren\'t found')]

        rslist = wp_rock_list()
        rslist.manifest = []

        for rockspec in rockspecs:
            rock_def = self.process_rockspec(rockspec)
            rslist += rock_def

        for manifest in manifests:
            rslist.manifest.append(self.process_manifest(manifest))

        rslist.manifests = [m for m in rslist.manifest if m != None]

        return [rslist]

def get_rock_url(name):
    # baseurl = 'http://tarantool.org/'
    baseurl = 'https://raw.githubusercontent.com/tarantool/rocks/gh-pages/'
    return urlparse.urljoin(baseurl, name)

def visit_wp_rock_node(self, node):
    # li->
    self.body.append(self.starttag(node, 'li', CLASS="b-rock-list-item b-clearbox"))
    # li->a->
    self.body.append(
        self.starttag(node, 'a',
            href = node.defs['description']['homepage']
        )
    )
    # li->a->div->
    self.body.append(self.starttag(node, 'div', CLASS="b-rock-list-item-ico"))
    # li->a->
    self.body.append('</div>')
    #
    self.body.append('</a>')
    # li->div->
    self.body.append(self.starttag(node, 'div', CLASS="b-rock-list-item-cnt"))
    # li->div->div->
    self.body.append(self.starttag(node, 'div', CLASS="b-rock-list-item-head"))
    # li->div->div->div->
    self.body.append(self.starttag(node, 'div', CLASS="b-rock-list-item-download"))
    self.body.append(
        node.defs['version'] + ': '
    )
    # li->div->div->div->a->
    self.body.append(self.starttag(node, 'a', href = get_rock_url(node.filename)))
    self.body.append("<span class=\"b-url_w_i-text\">rockspec</span>")
    self.body.append("<i class=\"fa fa-arrow-circle-o-down fa-pull-right\"></i>")
    # li->div->div->div->
    self.body.append('</a>')
    # li->div->div->
    self.body.append('</div>')
    # li->div->div->h2->
    self.body.append(self.starttag(node, 'h2', CLASS="b-rock-list-item-title"))
    # li->div->div->h2->a->
    self.body.append(
        self.starttag(node, 'a',
            href = node.defs['description']['homepage']
        )
    )
    summary = node.defs['description'].get('summary', None)
    summary = ' - ' + summary if summary else ''
    self.body.append('%s%s' % (node.defs['package'], summary))
    # li->div->div->h2->
    self.body.append('</a>')
    # li->div->div->
    self.body.append('</h2>')
    # li->div->
    self.body.append('</div>')
    # li->div->div->
    self.body.append(self.starttag(node, 'div', CLASS="b-rock-list-item-bottom"))
    # li->div->div->div->
    self.body.append(self.starttag(node, 'div', CLASS='b-rock-list-item-license'))
    self.body.append('License: %s' % node.defs['description']['license'])
    # li->div->div->
    self.body.append('</div>')
    # li->div->div->ul->
    self.body.append(self.starttag(node, 'ul', CLASS="b-rock-sublist"))
    # li->div->div->ul->li->
    self.body.append(self.starttag(node, 'li', CLASS="b-rock-sublist-item"))
    # li->div->div->ul->li->a->
    self.body.append(self.starttag(node, 'a', href = node.defs['source']['url']))
    self.body.append("<i class=\"fa fa-clock-o fa-pull-left\"></i>")
    self.body.append("<span class=\"b-url_w_i-text\">latest sources</span>")
    # li->div->div->ul->li->
    self.body.append('</a>')
    # li->div->div->ul->
    self.body.append('</li>')
    # li->div->div->ul->li->
    self.body.append(self.starttag(node, 'li', CLASS="b-rock-sublist-item"))
    # li->div->div->ul->li->a->
    self.body.append(
        self.starttag(node, 'a',
            href = node.defs['description']['homepage']
        )
    )
    self.body.append("<i class=\"fa fa-home fa-pull-left\"></i>")
    self.body.append("<span class=\"b-url_w_i-text\">project homepage</span>")
    # li->div->div->ul->li->
    self.body.append('</a>')
    # li->div->div->ul->
    self.body.append('</li>')
    # li->div->div->
    self.body.append('</ul>')
    # li->div->
    self.body.append('</div>')
    # li->
    self.body.append('</div>')

def depart_wp_rock_node(self, node):
    self.body.append('</li>')

def visit_wp_rock_list_node(self, node):
    self.body.append(self.starttag(node, 'ul', CLASS="b-rock-list"))

def depart_wp_rock_list_node(self, node):
    self.body.append('</ul>')
    self.body.append(self.starttag(node, 'ul', CLASS="b-docs_list-footer"))
    for manifest in node.manifests:
        self.body.append(self.starttag(node, 'li', CLASS="b-docs_list-footer-item"))
        self.body.append('<a href="%s">%s</a>' % (
            get_rock_url(manifest[1]), manifest[0]
        ))
        if manifest[2] is not None:
            self.body.append(' (<a href="%s">zip</a>)' % get_rock_url(manifest[2]))
        self.body.append('</li>')
    self.body.append('</ul>')

def setup(app):
    app.add_node(wp_rock, html=(visit_wp_rock_node, depart_wp_rock_node))
    app.add_node(wp_rock_list,
            html=(visit_wp_rock_list_node, depart_wp_rock_list_node))
    app.add_directive('wp_rocks', WebPageRocksDirectives)
