# doc
Tarantool documentation source, published at https://www.tarantool.io/en/doc/1.10/

## How to build Tarantool documentation using [Docker](https://www.docker.com)

### Build docker image
```bash
docker build -t tarantool-doc-builder .
```

### Build Tarantool documentation using *tarantool-doc-builder* image

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

Generate rst from submodules:
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make submodules"
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

## Building css from less

Install required packages:
```shell script
npm install -g clean-css clean-css-cli node-less less-plugin-autoprefix 
```

Make css files:
```shell script
cd _theme/tarantool/_less
make all
```

Then remove output/html folder and build the documentation again

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
