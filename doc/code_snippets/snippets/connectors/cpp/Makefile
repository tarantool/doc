all: Simple

Simple: Simple.o
	g++ -std=c++17 Simple.o -o Simple

Simple.o: Reader.hpp Simple.cpp
	g++ -std=c++17 -c Simple.cpp
