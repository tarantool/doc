# Tarantool Documentation

Tarantool documentation source, published at https://www.tarantool.io/doc/.

## How to build Tarantool documentation using [Docker](https://www.docker.com)

### Build docker image
```bash
docker build -t tarantool-doc-builder .
```

### Build Tarantool documentation using *tarantool-doc-builder* image
## NOTE: 
> Run this command only if you don't have untracked files!
  check it by `git status` 
  Also failures during git submodule update can be fixed by:
   ```bash
   git submodule deinit -f .
   git submodule update --init
   ```

Init and update submodules:
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "./update_submodules.sh"
```
or do it manually:
```bash
git submodule init
git submodule update
git pull --recurse-submodules
git submodule update --remote --merge
```

Init make commands:
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "cmake ."
```

Run a required make command inside *tarantool-doc-builder* container:
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make html"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make html-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make singlehtml"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make singlehtml-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make pdf"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make pdf-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make json"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make json-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make epub"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make epub-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make update-pot"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make update-po"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make update-po-force"
```

### Run documentation locally on your machine
using python3 built-in server:
```bash
cd output/html
python3 -m http.server
```
or python2 built-in server:
```bash
cd output/html
python -m SimpleHTTPServer
```
then go to [localhost:8000](http://localhost:8000) in your browser.

## Localization

Terms:

* **translation unit** (TU) is an atomic piece of text which can be translated.
  A paragraph, a list item, a heading, image's alt-text and so on.
  
* **translation source files** are the files with translation units in English only.
    They're located in `locale/en`.

* **translation files** are the files which match original text to translated text.
  They're located in `locale/ru`.
  
We use Crowdin for continuous localization.
To work with Crowdin CLI, issue an API token in your 
[account settings](https://crowdin.com/settings#api-key).
Save it in `~/.crowdin.yml`:

```yaml
"api_token": "asdfg12345..."
```

Upload translation sources any time when they have changed:

```bash
# first, update the translation sources
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make update-pot"

# next, upload them to Crowdin
crowdin upload 
# or
crowdin upload sources
```

Upload translation files once for each project, to pass the existing translations to Crowdin:

```bash
crowdin upload translations --auto-approve-imported --import-eq-suggestions
```

Download translations files back when they're done.
Then reformat them to see the real changes.

```bash
crowdin download
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make reformat-po"
```
## How to contribute

To contribute to documentation, use the
[REST](http://docutils.sourceforge.net/docs/user/rst/quickstart.html)
format for drafting and submit your updates as a
[pull request](https://help.github.com/articles/creating-a-pull-request)
via GitHub.

To comply with the writing and formatting style, use the
[guidelines](https://www.tarantool.io/en/doc/2.2/dev_guide/documentation_guidelines/)
provided in the documentation, common sense and existing documents.

Notes:

* If you suggest creating a new documentation section (a whole new
  page), it has to be saved to the relevant section at GitHub.

* If you want to contribute to localizing this documentation (for example into
  Russian), add your translation strings to `.po` files stored in the
  corresponding locale directory (for example `/locale/ru/LC_MESSAGES/`
  for Russian). See more about localizing with Sphinx at
  http://www.sphinx-doc.org/en/stable/intl.html
