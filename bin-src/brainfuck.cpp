#include <algorithm>  // find
#include <chrono>  // sleep_for
#include <fstream>  // ifstream
#include <iomanip>  // setw
#include <iostream>
#include <map>
#include <sstream>
#include <termios.h>  // termios, tcgetattr, ICANON, ECHO, VTIME, VMIN, TCSANOW
#include <thread>  // this_thread
#include <vector>
using namespace std;


void print_cells(vector<int> cells) {
    cout << "\033[2K\r" << flush;
    for (int c : cells) {
        cout << setw(5) << c << flush;
    }
}


void print_cells_with_ptr(vector<int> cells, int ptr) {
    cout << "\033[2K\r" << flush;
    for (auto it = cells.begin(); it != cells.end(); it++) {
        int i = distance(cells.begin(), it);
        if (i == ptr) cout << setw(5) << '(' << cells.at(i) << ')';
        else cout << setw(5) << cells.at(i);
        cout << flush;
    }
}


void err_out(string err) {
    string msg;
    if (err == "USAGE") {
        msg = "usage: brainfuck [-h] [-c | -f] [-d DELAY] [--dump-tape | ";
        msg += "--show-tape]\n                 [-i INPUT] [FILE [FILE ...]]";
    } else
        msg = "brainfuck: " + err;
    cerr << msg << endl;
    exit(1);
}


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
        err_out("unable to set terminal to single character mode");

    // Read single character from cin
    char c;
    streambuf *pbuf = cin.rdbuf();
    c = pbuf->sbumpc();

    // Restore terminal mode
    if (tcsetattr(fileno(stdin), TCSANOW, &t_saved) < 0)
        err_out("unable to restore terminal mode");

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


void evaluate(vector<char> code, bool dump_tape, bool show_tape,
              vector<char> input, int delay) {
    string output;
    map<int, int> bracemap = build_bracemap(code);
    vector<int> cells;
    cells.push_back(0);
    int codeptr = 0;
    int cellptr = 0;

    char cmd;
    while (codeptr < (int) code.size()) {
        if (show_tape) print_cells_with_ptr(cells, cellptr);

        cmd = code.at(codeptr);
        switch (cmd) {
            case '>': if (++cellptr == (int) cells.size())
                          cells.push_back(0);
                      break;
            case '<': cellptr = cellptr <= 0 ? 0 : --cellptr;
                      break;
            case '+': if (cells[cellptr] < 255)
                          cells.at(cellptr) = ++cells[cellptr];
                      else
                          cells.at(cellptr) = 0;
                      break;
            case '-': if (cells[cellptr] > 0)
                          cells.at(cellptr) = --cells[cellptr];
                      else
                          cells.at(cellptr) = 255;
                      break;
            case '[': if (cells.at(cellptr) == 0)
                          codeptr = bracemap.at(codeptr);
                      break;
            case ']': if (cells.at(cellptr) != 0)
                          codeptr = bracemap.at(codeptr);
                      break;
            case '.': if (dump_tape || show_tape)
                          output += (char)cells.at(cellptr);
                      else
                          cout << (char)cells.at(cellptr) << flush;
                      break;
            case ',': if (show_tape) {
                          if (input.size() == 0) {
                              cout << endl;
                              err_out("runtime error: not enough input was given");
                          }
                          cells.at(cellptr) = (int)input.at(0);
                          input.erase(input.begin());
                      } else {
                          cells.at(cellptr) = (int)getch();
                      }
                      break;
        }

        codeptr++;
        this_thread::sleep_for(chrono::milliseconds(delay));
    }

    if (dump_tape) {
        print_cells(cells);
        cout << endl;
    } else if (show_tape) {
        print_cells_with_ptr(cells, cellptr);
        cout << endl;
    }

    if (output.size() > 0 && (dump_tape || show_tape))
        cout << output << endl;
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


void help() {
    vector<string> help {
        "usage: brainfuck [-h] [-c | -f] [-d DELAY] [--dump-tape | --show-tape]",
        "                 [-i INPUT] [FILE [FILE ...]]",
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
        "                        The delay, in milliseconds, between the execution of",
        "                        each Brainfuck command.",
        "  --dump-tape           Output the tape after script execution.",
        "  --show-tape           Show the tape during script execution.",
        "  -i INPUT, --input INPUT",
        "                        The input for Brainfuck's , command."
    };

    for (string line : help)
        cout << line << endl;

    exit(1);
}


int main(int argc, char** argv) {
    vector<string> orig_args(argv, argv+argc);
    orig_args.erase(orig_args.begin());  // Remove brainfuck call from args
    vector<string> args;
    for (string arg : orig_args) {
        if (arg.substr(0,2) == "--")
            args.push_back(arg);
        else if (arg[0] == '-')
            for (int j=1; j<(int)arg.length(); j++)
                args.push_back("-" + string(1, arg[j]));
        else
            args.push_back(arg);
    }

    vector<string> infiles;
    bool stdin_code = false;
    bool stdin_filenames = false;
    int delay = 0;
    bool delay_changed = false;
    bool dump_tape = false;
    bool show_tape = false;
    vector<char> input;
    for (int i=0; i<(int)args.size(); i++) {
        string cmd = args[i];
        if (cmd[0] == '-') {
            if (cmd == "-h" || cmd == "--help") {
                help();
            } else if (cmd == "-c" || cmd == "--stdin-code") {
                stdin_code = true;
            } else if (cmd == "-f" || cmd == "--stdin-filenames") {
                stdin_filenames = true;
            } else if (cmd == "-d" || cmd == "--delay") {
                string err = "-d/--delay requires an integer";
                if (++i == argc) {
                    err_out(err);
                } else {
                    istringstream ss(argv[i]);
                    if (! (ss >> delay)) err_out(err);
                    delay_changed = true;
                }
            } else if (cmd == "--dump-tape") {
                dump_tape = true;
            } else if (cmd == "--show-tape") {
                show_tape = true;
            } else if (cmd == "-i" || cmd == "--input") {
                if (++i == argc)
                    err_out("-i/--input requires a value");
                else {
                    // TODO: is this broken? can this be improved?
                    char* arg_i= argv[i];
                    for (int j=0; arg_i[j] != '\0'; j++) {
                        input.push_back(arg_i[j]);
                    }
                }
            } else {
                err_out("unknown option: " + cmd);
            }
        } else {  // Filename
            infiles.push_back(cmd);
        }
    }

    if (stdin_code && stdin_filenames)
        err_out("arguments -c/--stdin-code and -f/--stdin-filenames" \
                " cannot be used together");

    if (dump_tape && show_tape)  // --dump-tape and --show-tape were both passed
        err_out("arguments --dump-tape and --show-tape" \
                " cannot be used together");

    if (show_tape && input.size() == 0)  // --show-tape without -i
        err_out("--show-tape requires -i/--input INPUT");
    if (input.size() > 0 && !show_tape)  // -i without --show-tape
        err_out("-i/--input is only for use with --show-tape");

    // Auto set delay if --show-tape && delay wasn't changed by user
    if (show_tape && !delay_changed)
        delay = 125;

    // All code to evaluate
    vector<vector<char>> to_eval;

    // Read code or filenames from stdin
    if (stdin_code) {
        string in_code;
        for (string in_line; getline(cin, in_line);)
            in_code += in_line;
        if (in_code.size())
            to_eval.push_back(cleanup(in_code));
    } else if (stdin_filenames) {
        for (string in_line; getline(cin, in_line);)
            infiles.push_back(in_line);
    }

    // Add code from each Brainfuck script to to_eval
    for (string fn : infiles) {
        ifstream bf_script(fn);
        if (bf_script.is_open()) {
            string code, code_line;
            while (getline(bf_script, code_line))
                code += code_line;
            to_eval.push_back(cleanup(code));
            bf_script.close();
        } else {
            err_out("cannot open file " + fn);
        }
    }

    cout << "to_eval.size(): " << to_eval.size() << endl;
    if (!to_eval.size())
        err_out("no input given");
    // Evaluate all code
    for (vector<char> code : to_eval)
        evaluate(code, dump_tape, show_tape, input, delay);

    return 0;
}
