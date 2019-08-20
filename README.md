# doc
Tarantool web site and documentation

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
Run required make command
```bash
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-html"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-html-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-singlehtml"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-singlehtml-ru"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-pdf"
docker run --rm -it -v $(pwd):/doc tarantool-doc-builder sh -c "make sphinx-pdf-ru"
```
