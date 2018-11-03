#!/usr/bin/env python3

"""Interpret Brainfuck programs.

Copyright 2011 Sebastian Kaspari
"""


import sys
from argparse import SUPPRESS, ArgumentParser, Namespace
from contextlib import contextmanager
from subprocess import DEVNULL, CalledProcessError, check_output
from time import sleep


class Tape:
    """The tape of a Brainfuck program.

    The tape is represented by a list of integers, or "cells". Each cell has
    a minimum value of 0 and a maximum value of 255 that wraps. Meaning that if
    a cell's value is 0 and Brainfuck attempts to decrease the value of that
    cell, its new value will be 255. Contrarily, if a cell's value is 255 and
    Brainfuck attempts to increase the value of that cell, its new value will
    be 0. The tape does not wrap. Meaning that if Brainfuck attempts to move
    the pointer to the left and it is pointing at the first, or left-most cell,
    the pointer will not move. However, if Brainfuck attempts to move the
    pointer to the right and is pointing at the last, or right-most cell, a
    cell will be appended to the tape and the pointer will then be pointing at
    the new cell.
    """

    def __init__(self, term_width):
        self.cells = [0]
        self.ptr = 0
        self.term_width = term_width

    @property
    def current_cell(self):
        """Return the cell the pointer is currently pointing at."""
        return self.cells[self.ptr]

    @current_cell.setter
    def current_cell(self, value):
        """Set the value of the cell the pointer is currently pointing at."""
        self.cells[self.ptr] = value

    def move_right(self):
        """Increase self.value by 1 if self.value won't exceed self.maximum."""
        self.ptr += 1
        if self.ptr == len(self.cells):
            self.cells.append(0)

    def move_left(self):
        """Decrease self.value by 1 if self.value won't exceed self.maximum."""
        self.ptr = 0 if self.ptr <= 0 else self.ptr - 1

    def inc_cell(self):
        """Increase the value of the current_cell.

        However, if the new value would be > 255, the value is set to 0.
        """
        self.current_cell += 1 if self.current_cell < 255 else -255

    def dec_cell(self):
        """Decrease the value of the current_cell.

        However, if the new value would be < 0, the value is set to 255.
        """
        self.current_cell -= 1 if self.current_cell > 0 else -255

    def print_cells(self, show_ptr=False):
        """Output the tape.

        Take into account the terminal width when formatting output. Also, show
        where the pointer is by surrounding current_cell with parentheses.
        """
        # Format cells
        for_out = [' %s ' % str(c).ljust(3) for c in self.cells]
        if show_ptr:
            for_out[self.ptr] = '(%s)' % str(self.cells[self.ptr]).ljust(3)

        # Number of cells per line
        nc = int((self.term_width+1)/6)

        # Split cells into lines with a max of nc cells per line
        lines = [' '.join(for_out[i:i+nc]) for i in range(0, len(for_out), nc)]

        # Output lines
        for l in lines:
            print('\r\33[K', end='')  # Clear line
            print(' ' + l, flush=True)

        # Return number of lines so the cursor can be reset at the top
        return len(lines)


def err_out(err):
    """Output err to stderr and exit with an error code of 1."""
    print('brainfuck-py:', err, file=sys.stderr)
    sys.exit(1)


def getch():
    """Read one character from stdin."""
    # Prompt for input
    print('Input: ', end='', flush=True)

    try:
        import msvcrt
        char = msvcrt.getch()
    except ImportError:
        import tty
        from termios import error, tcgetattr, tcsetattr, TCSADRAIN
        fd = sys.stdin.fileno()
        old_settings = tcgetattr(fd)  # save tty settings
        try:
            tty.setraw(fd)
            char = sys.stdin.read(1)
        except error:
            char = None
        finally:
            tcsetattr(fd, TCSADRAIN, old_settings)  # restore tty settings
    finally:
        if char is None:
            msg = 'runtime error: stdin is already in use.' + \
                  '\nmake sure nothing is being piped in'
            err_out(msg)

    # Clear the prompt and echo'd input
    print('\r\33[K', end='')

    return char


def build_bracemap(code):
    """Return a dict linking opening and closing square brackets.

    Example:
        >>> build_bracemap('++[>++<-]')
        {2: 8, 8: 2}

    Therefore, when querying a bracemap with the index of the opening square
    bracket in the code, the index of its matching closing square bracket is
    returned. Nested square brackets are handled properly.
    """
    temp_bracestack, bracemap = [], {}
    for pos, cmd in enumerate(code):
        if cmd == '[':
            temp_bracestack.append(pos)
        if cmd == ']':
            start = temp_bracestack.pop()
            bracemap[start] = pos
            bracemap[pos] = start

    return bracemap


def evaluate(code, user_in, config):
    """Interpret the Brainfuck code.

    Interprets the Brainfuck code, character by character, pausing for delay
    milliseconds after each command is processed. If the user requested the
    tape be shown live, while the program is being executed, the output is not
    printed until after the program has terminated. Otherwise, the output is
    printed out as the program is being interpreted.

    Args:
        code: A list of Brainfuck commands to be executed for one program.
        user_in: A string of input to be passed to the Brainfuck program.
        config: A Namespace object of variables that modify the interpretation
            and output of Brainfuck programs.
            It contains:
            width: The width of the terminal.
            delay: The delay after each Brainfuck command is processed.
            dump_tape: Whether or not the tape should be shown after
                interpretation.
            show_tape: Whether or not the tape should be shown during
                interpretation.
            use_user_in: Whether input should be taken from user_in or stdin.

    Returns:
        Nothing.
    """
    output = ''
    bracemap = build_bracemap(code)
    codeptr = 0
    tape = Tape(config.width)

    while codeptr < len(code):
        if config.show_tape:
            n_lines = tape.print_cells(show_ptr=True)

        cmd = code[codeptr]
        if cmd == '>':
            tape.move_right()
        elif cmd == '<':
            tape.move_left()
        elif cmd == '+':
            tape.inc_cell()
        elif cmd == '-':
            tape.dec_cell()
        elif cmd == '[' and tape.current_cell == 0:
            # Jump to the matching ']' for this '['
            codeptr = bracemap[codeptr]
        elif cmd == ']' and tape.current_cell != 0:
            # Jump back to the matching '[' for this ']'
            codeptr = bracemap[codeptr]
        elif cmd == '.':
            if config.dump_tape or config.show_tape:
                output += chr(tape.current_cell)
            else:
                print(chr(tape.current_cell), end='', flush=True)
        elif cmd == ',':
            if config.use_user_in:  # -i/--input was given
                if not user_in:
                    err_out('runtime error: not enough input was given')
                tape.current_cell = ord(user_in.pop(0))
            else:
                tape.current_cell = ord(getch())

        # Clear all of the tape output from the temrinal
        if config.show_tape:
            print('\33[A'*n_lines, end='')

        codeptr += 1
        sleep(config.delay/1000.)

    if config.dump_tape:
        tape.print_cells()
    elif config.show_tape:
        tape.print_cells(show_ptr=True)

    if (config.dump_tape or config.show_tape) and output:
        print(output, end='')


def cleanup(code):
    """Return code with all non-Brainfuck command characters removed."""
    bf_chars = ['>', '<', '+', '-', '[', ']', '.', ',']
    return [c for c in code if c in bf_chars]


def get_term_width():
    """Get terminal width, default to 80."""
    try:
        width = int(check_output(['tput', 'cols'], stderr=DEVNULL))
    except (ValueError, CalledProcessError):
        width = 80

    # Subtract 2 for 1 column padding on either side
    return width - 2


@contextmanager
def open_script(fn):
    """Open file fn, opening sys.stdin for files named "-"."""
    if fn == '-':
        script = sys.stdin
    else:
        script = open(fn, 'r')

    try:
        yield script
    finally:
        if script is not sys.stdin:
            script.close()


def main(args):
    """Do some error checking, then interpret all Brainfuck code."""
    use_user_in = False if args.input is None else True
    user_in = [] if args.input is None else list(args.input)

    # Terminal width is too small for even 1 cell
    if args.width < 7:
        err_out('terminal is not wide enough')

    # Auto set delay if --show-tape and delay wasn't changed by user
    if args.delay is None:
        args.delay = 125 if args.show_tape else 0

    infiles = args.infiles  # Filenames passed as arguments
    to_eval = []  # Code of each script to be executed

    for fn in infiles:
        # Read the contents of each file into to_eval
        try:
            with open_script(fn) as script:
                to_eval.append(cleanup(script.read()))
        except FileNotFoundError:
            err_out('cannot open file ' + fn)

    if not to_eval:
        if sys.stdin.isatty():
            err_out('no input given')
        # Read from stdin
        to_eval.append(cleanup(sys.stdin.read()))

    # Combine config variables into one namespace
    config = Namespace(width=args.width, delay=args.delay,
                       dump_tape=args.dump_tape, show_tape=args.show_tape,
                       use_user_in=use_user_in)

    # Evaluate all code
    for code in to_eval:
        evaluate(code, user_in, config)


if __name__ == '__main__':
    desc = 'Executes one or more scripts written in Brainfuck.'
    h_help = 'Show this help message and exit.'
    c_help = 'Read Brainfuck code from stdin.'
    f_help = 'Read Brainfuck script filenames from stdin.'
    d_help = 'The delay, in milliseconds, between the execution of each ' + \
             'Brainfuck command.'
    dump_help = 'Output the tape after script execution.'
    show_help = 'Show the tape during script execution.'
    i_help = "The input for Brainfuck's , command."
    w_help = 'The maximum width for the output.'
    file_help = 'One or more names of Brainfuck scripts. Filenames are ' + \
                'read from both the command line and from stdin.'

    parser = ArgumentParser(description=desc, add_help=False)
    parser.add_argument('-h', '--help', action='help', default=SUPPRESS,
                        help=h_help)
    stdin_type = parser.add_mutually_exclusive_group()
    stdin_type.add_argument('-c', '--stdin-code', action='store_true',
                            help=c_help)
    stdin_type.add_argument('-f', '--stdin-filenames', action='store_true',
                            help=f_help)
    parser.add_argument('-d', '--delay', type=int, default=None, help=d_help)
    tape_g = parser.add_mutually_exclusive_group()
    tape_g.add_argument('--dump-tape', action='store_true', help=dump_help)
    tape_g.add_argument('--show-tape', action='store_true', help=show_help)
    parser.add_argument('-i', '--input', default=None, help=i_help)
    parser.add_argument('-w', '--width', type=int, default=get_term_width(),
                        help=w_help)
    # nargs='*' so that filenames or code can be read from stdin
    parser.add_argument('infiles', nargs='*', default=[], metavar='FILE',
                        help=file_help)

    # Set delay_changed to False by default
    main(parser.parse_args())
