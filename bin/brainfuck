#!/usr/bin/env python3
# 
# Usage: ./brainfuck.py file

import sys

class _Getch:
    """Gets a single character from standard input. Does not echo to the
screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self):
        return self.impl()

class _GetchUnix:
    def __init__(self):
        import tty

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()



def execute(filename):
    with open(filename, 'r') as f:
        evaluate(f.read())


def evaluate(code):
    code = cleanup(code)
    bracemap = buildbracemap(code)

    cells, codeptr, cellptr = [0], 0, 0

    while codeptr < len(code):
        command = code[codeptr]
        if command == ">":
            cellptr += 1
            if cellptr == len(cells): cells.append(0)
        elif command == "<":
            cellptr = 0 if cellptr <= 0 else cellptr - 1
        elif command == "+":
            cells[cellptr] = cells[cellptr] + 1 if cells[cellptr] < 255 else 0
        elif command == "-":
            cells[cellptr] = cells[cellptr] - 1 if cells[cellptr] > 0 else 255
        elif command == "[" and cells[cellptr] == 0:
            codeptr = bracemap[codeptr]
        elif command == "]" and cells[cellptr] != 0:
            codeptr = bracemap[codeptr]
        elif command == ".":
            sys.stdout.write(chr(cells[cellptr]))
        elif command == ",":
            getch = _Getch()
            cells[cellptr] = ord(getch())
        
        codeptr += 1


def cleanup(code):
    out = filter(lambda x: x in ['>', '<', '+', '-', '[', ']', '.', ','], code)
    return list(out)


def buildbracemap(code):
    temp_bracestack, bracemap = [], {}
    for pos, cmd in enumerate(code):
        if cmd == "[": temp_bracestack.append(pos)
        if cmd == "]":
            start = temp_bracestack.pop()
            bracemap[start] = pos
            bracemap[pos] = start

    return bracemap


def main():
    if len(sys.argv) == 2:
        execute(sys.argv[1])
    else:
        print("Usage:", sys.argv[0], "filename")


if __name__ == "__main__":
    main()
