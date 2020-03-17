EXE     := build/brainfuck

SRCS    := $(wildcard src/*.cpp)
OBJS    := $(SRCS:src/%.cpp=build/%.o)

CFLAGS  := -std=c++17 -pedantic -Wall -Werror
LDFLAGS :=
LDLIBS  :=

CXX     := g++
INSTALL := install

main: $(EXE)
.PHONY: main

$(EXE): $(OBJS)
	@echo "build/*.o -> $@"
	@$(CXX) $(LDFLAGS) $(OBJS) -o $@ $(LDLIBS)

build/%.o: src/%.cpp | build_dirs
	@echo "$< -> $@"
	@$(CXX) $(CFLAGS) -c -MMD $< -o $@

install:
	@echo TODO
.PHONY: install

clean:
	rm -rf build
.PHONY: clean

build_dirs:
	@mkdir -p build
.PHONY: build_dirs
