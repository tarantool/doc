# doc
Tarantool documentation

## How to build Tarantool documentation using [Docker](https://www.docker.com)

### Build docker image
```bash
docker build -t tarantool-doc-builder .
```

### Build Tarantool documentation using *tarantool-doc-builder* image

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
