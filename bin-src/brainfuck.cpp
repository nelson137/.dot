#include <algorithm>
#include <array>
#include <chrono>
#include <cstdarg>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>
#include <termios.h>
#include <thread>
#include <vector>

#include <unistd.h>

#include <sys/ioctl.h>

using namespace std;


typedef struct {
    // Width of the terminal
    int width;
    // Delay, in milliseconds, between each command's evaluation
    int delay;
    // Print the tape after the program's evaluation
    bool dump_tape;
    // Show the tape during the program's evaluation
    bool show_tape;
    // Whether or not to use the input vector
    bool use_input;
    // The user input to use during program evaluation
    vector<char> input;
} Options;


/**
 * Print a message to stderr then exit.
 * This function is a wrapper for vfprintf, meaning that the first argument
 * can be a format string with a variable number of subsequent arguments
 * corresponding to the number of format specifiers in the format string.
 */
void die(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
    exit(1);
}


/**
 * Print this program's usage then exit.
 */
void help() {
    string help[24] {
        "usage: brainfuck-py [-h] [-c | -f] [-d DELAY] [--dump-tape | --show-tape]",
        "                    [-i INPUT] [-w WIDTH]",
        "                    [FILE [FILE ...]]",
        "",
        "Executes one or more scripts written in Brainfuck.",
        "",
        "positional arguments:",
        "  FILE                  One or more names of Brainfuck scripts. Filenames are",
        "                        read from both the command line and from stdin.",
        "",
        "optional arguments:",
        "  -h, --help            Show this help message and exit.",
        "  -c, --stdin-code      Read Brainfuck code from stdin.",
        "  -f, --stdin-filenames",
        "                        Read Brainfuck script filenames from stdin.",
        "  -d DELAY, --delay DELAY",
        "                        The delay, in milliseconds, between the evaluation of",
        "                        each Brainfuck command.",
        "  --dump-tape           Output the tape after script evaluation.",
        "  --show-tape           Show the tape during script evaluation.",
        "  -i INPUT, --input INPUT",
        "                        The input for Brainfuck's , command.",
        "  -w WIDTH, --width WIDTH",
        "                        The maximum width for the output."
    };

    for (string line : help)
        cout << line << endl;

    exit(1);
}


/**
 * Print out cells.
 * The cell that the Brainfuck program's cell pointer (ptr) is pointing to is
 * suddrounded by parentheses. This function is meant to be called many times
 * during the Brainfuck program's evaluation. It uses ANSI escape codes to
 * overwrite the previous print_cells output. The terminals's width (width) is
 * used to wrap the cells so that the cells get printed correctly.
 */
int print_cells(vector<int> raw_cells, int width, int ptr) {
    vector<string> cells;
    for (int cell : raw_cells)
        cells.push_back(to_string(cell));

    // Format cells
    int i;
    for (auto it = cells.begin(); it != cells.end(); it++) {
        i = distance(cells.begin(), it);
        if (i != -1 && i == ptr) {
            cells[i] = '(' + cells[i];
            while (cells[i].length() < 4)
                cells[i] += ' ';
            cells[i] += ')';
        } else {
            cells[i] = ' ' + cells[i];
            while (cells[i].length() < 5)
                cells[i] += ' ';
        }
    }

    // Number of cells per line
    int nc = (width+1) / 6;

    // Split cells into lines with a max of nc cells per line
    vector<string> lines;
    string l;
    for (int i=0; i<(int)cells.size();) {
        l = "";
        for (int j=0; j<nc; j++) {
            if (i == (int)cells.size()) break;
            if (j != 0) l += ' ';
            l += cells[i];
            i++;
        }
        lines.push_back(l);
    }

    // Output lines
    for (string l : lines) {
        cout << "\r\33[K";  // Clear line
        cout << ' ' << l << endl << flush;
    }

    // Return number of lines so the cursor can be reset at the top
    return lines.size();
}


/**
 * Return one character read from stdin.
 * The user is prompted for input; this prompt is cleared after the user
 * presses a key.
 */
char getch() {
    struct termios t;
    struct termios t_saved;

    // Set terminal to single character mode
    tcgetattr(fileno(stdin), &t);
    t_saved = t;
    t.c_lflag &= (~ICANON & ~ECHO);
    t.c_cc[VTIME] = 0;
    t.c_cc[VMIN] = 1;
    if (tcsetattr(fileno(stdin), TCSANOW, &t) < 0)
        die("Unable to set terminal to single character mode");

    cout << "Input: ";

    // Read single character from cin
    char c;
    streambuf *pbuf = cin.rdbuf();
    c = pbuf->sbumpc();

    // Clear line
    cout << "\r\33[K";

    // Restore terminal mode
    if (tcsetattr(fileno(stdin), TCSANOW, &t_saved) < 0)
        die("Unable to restore terminal mode");

    return c;
}


map<int, int> build_bracemap(vector<char> code) {
    vector<int> brace_stack;
    map<int, int> bracemap;
    for (int i=0; i<(int)code.size(); i++) {
        if (code[i] == '[') {
            brace_stack.push_back(i);
        } else if (code[i] == ']') {
            int start = brace_stack.back();
            brace_stack.pop_back();
            bracemap[start] = i;
            bracemap[i] = start;
        }
    }

    return bracemap;
}


/**
 * Execute Brainfuck code.
 * The code is evaluated character by character according to the Brainfuck
 * specification (https://en.wikipedia.org/wiki/Brainfuck#Commands).
 *
 * Usage of each member of the Options struct:
 *     The width integer is used to make sure the cells are printed correctly
 *         if the --dump-tape or --show-tape options are used.
 *     The delay integer is the number of milliseconds to sleep for between
 *         each command's evaluation.
 *     The dump_tape bool indicates whether of not the program's tape should be
 *         printed after the program finishes evaluation.
 *     The show_tape bool indicates whether or not the program's tape should be
 *         shown while the program is being evaluation.
 *     The use_input bool indicates whether or not to use the input character
 *         vector.
 *     The input character vector is is used for the Brainfuck program's input
 *         if use_input is true.
 */
void evaluate(vector<char> code, vector<char> input, Options *options) {
    string output;
    map<int, int> bracemap = build_bracemap(code);
    vector<int> cells;
    cells.push_back(0);
    int codeptr = 0;
    int cellptr = 0;

    char cmd;
    int n_lines = 0;
    while (codeptr < (int) code.size()) {
        if (options->show_tape)
            n_lines = print_cells(cells, options->width, cellptr);

        cmd = code.at(codeptr);
        switch (cmd) {
            case '>':
                if (++cellptr == (int) cells.size())
                    cells.push_back(0);
                break;
            case '<':
                cellptr = cellptr <= 0 ? 0 : cellptr-1;
                break;
            case '+':
                if (cells[cellptr] < 255)
                    cells.at(cellptr) = ++cells[cellptr];
                else
                    cells.at(cellptr) = 0;
                break;
            case '-':
                if (cells[cellptr] > 0)
                    cells.at(cellptr) = --cells[cellptr];
                else
                    cells.at(cellptr) = 255;
                break;
            case '[':
                if (cells.at(cellptr) == 0)
                    codeptr = bracemap.at(codeptr);
                break;
            case ']':
                if (cells.at(cellptr) != 0)
                    codeptr = bracemap.at(codeptr);
                break;
            case '.':
                if (options->dump_tape || options->show_tape)
                    output += (char)cells.at(cellptr);
                else
                    cout << (char)cells.at(cellptr) << flush;
                break;
            case ',':
                if (options->use_input) {
                    if (input.size() == 0)
                        die("runtime error: not enough input was given");
                    cells.at(cellptr) = (int)input.at(0);
                    input.erase(input.begin());
                } else {
                    cells.at(cellptr) = (int)getch();
                }
                break;
        }

        if (options->show_tape)
            for (int i=0; i<n_lines; i++)
                cout << "\33[A";

        codeptr++;
        this_thread::sleep_for(chrono::milliseconds(options->delay));
    }

    if (options->dump_tape)
        // Pass illegal value -1 as ptr because ptr is not needed here
        print_cells(cells, options->width, -1);
    else if (options->show_tape)
        print_cells(cells, options->width, cellptr);

    if (output.size() > 0 && (options->dump_tape || options->show_tape))
        cout << output;
}


/**
 * Return terminal width, default to 80.
 */
int get_term_width() {
    struct winsize w;
    int ret = ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    int margin = 2;
    return ret == 0 ? w.ws_col-margin : 80-margin;
}


vector<char> cleanup(string dirty_code) {
    char chars[] = { '<', '>', '+', '-', '[', ']', '.', ',' };
    vector<char> bf_chars(chars, chars+8);

    vector<char> clean_code;
    for (char c : dirty_code)
        if (find(bf_chars.begin(), bf_chars.end(), c) != bf_chars.end())
            clean_code.push_back(c);

    return clean_code;
}


int get_num(string str, const char *err) {
    int num;
    istringstream ss(str);
    if (! (ss >> num))
        die(err);
    return num;
}


vector<string> split_options(vector<string> args) {
    vector<string> split;
    for (string arg : args) {
        if (arg == "--")
            return split;
        if (arg.substr(0,2) == "--")
            split.push_back(arg);
        else if (arg[0] == '-' && arg.length() > 1)
            for (int j=1; j<(int)arg.length(); j++)
                split.push_back('-' + string(1, arg[j]));
        else
            split.push_back(arg);
    }

    return split;
}


int main(int argc, char **argv) {
    // Split options -abc into -a -b -c
    vector<string> orig_args(argv, argv+argc);
    vector<string> args = split_options(orig_args);

    Options options = {
        .width = get_term_width(),
        .delay = 0,
        .dump_tape = false,
        .show_tape = false,
        .use_input = false,
    };

    vector<string> infiles;
    bool read_code = false;
    bool delay_changed = false;
    vector<char> input;

    string cmd;
    bool parsing_opts = true;
    for (int i=1; i<(int)args.size(); i++) {
        cmd = args[i];
        // Argument is a filename or "--" has been parsed
        if (cmd[0] != '-' || !parsing_opts) {
            infiles.push_back(cmd);
            continue;
        }

        if (cmd == "--") {
            // All subsequent arguments are filenames
            // Or code if "-r" has been parsed
            parsing_opts = false;
        } else if (cmd == "-h" || cmd == "--help") {
            help();
        } else if (cmd == "-r" || cmd == "--read-code") {
            read_code = true;
        } else if (cmd == "-d" || cmd == "--delay") {
            const char *err = "Option -d/--delay requires an integer";
            // If there are no arguments after "-d"
            if (++i == argc)
                die(err);
            options.delay = get_num(argv[i], err);
            delay_changed = true;
        } else if (cmd == "--dump-tape") {
            options.dump_tape = true;
        } else if (cmd == "--show-tape") {
            options.show_tape = true;
        } else if (cmd == "-i" || cmd == "--input") {
            options.use_input = true;
            if (++i == argc)
                die("Option -i/--input requires a value");
            // TODO: is this broken? can this be improved?
            for (int j=0; argv[i][j] != '\0'; j++)
                input.push_back(argv[i][j]);
        } else if (cmd == "-w" || cmd == "--width") {
            const char *err = "Option -w/--width requires an integer";
            if (++i == argc)
                die(err);
            options.width = get_num(argv[i], err);
        } else {
            die("Unknown option: %s", cmd);
        }
    }

    // Terminal width is too small for even 1 cell
    if (options.width < 7)
        die("Terminal is not wide enough");

    // --dump-tape and --show-tape were both given
    if (options.dump_tape && options.show_tape)
        die("Options --dump-tape and --show-tape cannot be used together");

    // -i/--input was given without --show-tape
    if (options.use_input && !options.show_tape)
        die("Option -i/--input can only be used with --show-tape");

    // Auto set delay if --show-tape and delay wasn't changed by user
    if (options.show_tape && !delay_changed)
        options.delay = 125;

    // All code to evaluate
    vector<vector<char>> to_eval;

    // If something is being piped in
    if (!isatty(STDIN_FILENO)) {
        // Read code from stdin into in_code
        string in_code;
        for (string in_line; getline(cin, in_line);)
            in_code += in_line;
        if (in_code.size())
            to_eval.push_back(cleanup(in_code));
    }

    if (read_code) {
        // Each element of infiles is code, append it to to_eval
        for (string code : infiles)
            to_eval.push_back(cleanup(code));
    } else {
        // Read code from each infile into to_eval
        for (string fn : infiles) {
            ifstream bf_script(fn);
            if (bf_script.is_open()) {
                string code, code_line;
                while (getline(bf_script, code_line))
                    code += code_line;
                to_eval.push_back(cleanup(code));
                bf_script.close();
            } else {
                die("Cannot open file: %s", fn);
            }
        }
    }

    // No code or filenames were given
    if (!to_eval.size())
        help();

    // Evaluate all code
    for (vector<char> code : to_eval)
        evaluate(code, input, &options);

    return 0;
}
