# doc
Tarantool documentation

## How to build Tarantool documentation using [Docker](https://www.docker.com)

### Build docker image 
```bash
docker build -t tarantool-doc-builder .
```

### Build Tarantool documentation using *tarantool-doc-builder* image
Init make commands
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "cmake ."
```
Run required make command inside *tarantool-doc-builder* container
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-html"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-html-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-singlehtml"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-singlehtml-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-pdf"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-pdf-ru"
```

### Run built http documentation locally on your machine using python3 built-in server
```bash
cd output
python3 -m http.server
```
or python2
```bash
cd output
python -m SimpleHTTPServer
```
then go to [localhost:8000](http://localhost:8000) in your browser