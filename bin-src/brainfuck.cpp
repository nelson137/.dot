#include <algorithm>  // find
#include <chrono>  // sleep_for
#include <fstream>  // ifstream
#include <iomanip>  // setw
#include <iostream>
#include <map>
#include <sstream>
#include <termios.h>  // terminos, tcgetattr, ICANON, ECHO, VTIME, VMIN, TCSANOW
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


void print_err(string err) {
    string msg;
    if (err == "USAGE") {
        msg = "usage: brainfuck-py [-h] [-d DELAY] [--dump-tape | --show-";
        msg += "tape] [-i INPUT]\n                    [FILE [FILE ...]]";
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
        print_err("unable to set terminal to single character mode");

    // Read single character from cin
    char c;
    streambuf *pbuf = cin.rdbuf();
    c = pbuf->sbumpc();

    // Restore terminal mode
    if (tcsetattr(fileno(stdin), TCSANOW, &t_saved) < 0) {
        cerr << "Unable to restore terminal mode" << endl;
        exit(-1);
    }

    return c;
}


map<int, int> build_bracemap(vector<char> code) {
    vector<int> brace_stack;
    map<int, int> bracemap;
    for (int i=0; i<code.size(); i++) {
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


void evaluate(vector<char> code, bool dump_tape, bool show_tape, vector<char> input, int delay) {
    string output;
    map<int, int> bracemap = build_bracemap(code);
    vector<int> cells;
    cells.push_back(0);
    int codeptr = 0;
    int cellptr = 0;

    char cmd;
    while (codeptr < code.size()) {
        if (show_tape) print_cells_with_ptr(cells, cellptr);

        cmd = code.at(codeptr);
        switch (cmd) {
            case '>':
                if (++cellptr == cells.size()) cells.push_back(0);
                break;
            case '<':
                cellptr = cellptr <= 0 ? 0 : --cellptr;
                break;
            case '+':
                cells.at(cellptr) = cells[cellptr] < 255 ? ++cells[cellptr] : 0;
                break;
            case '-':
                cells.at(cellptr) = cells[cellptr] > 0 ? --cells[cellptr] : 255;
                break;
            case '[':
                if (cells.at(cellptr) == 0) codeptr = bracemap.at(codeptr);
                break;
            case ']':
                if (cells.at(cellptr) != 0) codeptr = bracemap.at(codeptr);
                break;
            case '.':
                if (dump_tape || show_tape)
                    output += (char)cells.at(cellptr);
                else
                    cout << (char)cells.at(cellptr) << flush;
                break;
            case ',':
                if (show_tape) {
                    if (input.size() == 0) {
                        cout << endl;
                        print_err("runtime error: not enough input was given");
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


vector<char> get_clean_code(string filename) {
    vector<char> code;

    ifstream file(filename);
    if (file.is_open()) {
        char chars[] = {'<', '>', '+', '-', '[', ']', '.', ','};
        vector<char> bf_chars(chars, chars+8);

        string line;
        while (getline(file, line)) {
            for (char c : line) {
                if (find(bf_chars.begin(), bf_chars.end(), c) != bf_chars.end()) {
                    code.push_back(c);
                }
            }
        }
        file.close();
    } else {
        print_err("cannot open file " + filename);
    }

    return code;
}


void help() {
    cerr << "usage: brainfuck-py [-h] [-d DELAY] [--dump-tape | --show-tape] [-i INPUT]" << endl;
    cerr << "                    [FILE [FILE ...]]" << endl;
    cerr << endl;
    cerr << "Executes one or more scripts written in brainfuck." << endl;
    cerr << endl;
    cerr << "positional arguments:" << endl;
    cerr << "  FILE                  The name or names of a brainfuck script. Filenames can" << endl;
    cerr << "                        be read from stdin; however, filenames should not be" << endl;
    cerr << "                        passed through stdin and the command line at the same" << endl;
    cerr << "                        time." << endl;
    cerr << endl;
    cerr << "optional arguments:" << endl;
    cerr << "  -h, --help            Show this help message and exit." << endl;
    cerr << "  -d DELAY, --delay DELAY" << endl;
    cerr << "                        The delay in milliseconds between each command." << endl;
    cerr << "  --dump-tape           Output tape after executing script." << endl;
    cerr << "  --show-tape           Show tape live during script execution." << endl;
    cerr << "  -i INPUT, --input INPUT" << endl;
    cerr << "                        Input for the , command." << endl;
    exit(1);
}


int main(int argc, char** argv) {
    vector<string> infiles;
    int delay = 10;
    bool dump_tape = false;
    bool show_tape = false;
    vector<char> input;
    for (int argi=1; argi<argc; argi++) {
        string cmd = argv[argi];
        if (cmd[0] == '-') {
            if (cmd == "-h" || cmd == "--help") {
                help();
            } else if (cmd == "-d" || cmd == "--delay") {
                string err = "-d/--delay requires an integer";
                if (++argi == argc)
                    print_err(err);
                else {
                    istringstream ss(argv[argi]);
                    if (! (ss >> delay)) print_err(err);
                }
            } else if (cmd == "--dump-tape") {
                dump_tape = true;
            } else if (cmd == "--show-tape") {
                show_tape = true;
            } else if (cmd == "-i" || cmd == "--input") {
                if (++argi == argc)
                    print_err("-i/--input requires a value");
                else {
                    // TODO: is this broken? can this be improved?
                    char* i_arg = argv[argi];
                    for (int i; i_arg[i] != '\0'; i++) {
                        input.push_back(i_arg[i]);
                    }
                }
            } else {  // Unknown option
                print_err("unknown option: " + cmd);
            }
        } else {  // Filename
            infiles.push_back(cmd);
        }
    }

    if (dump_tape && show_tape)  // --dump-tape and --show-tape were both passed
        print_err("arguments --dump-tape and --show-tape cannot be used together");

    if (show_tape && input.size() == 0)  // --show-tape without -i
        print_err("--show-tape requires -i/--input INPUT");
    if (input.size() > 0 && !show_tape)  // -i without --show-tape
        print_err("-i/--input is only for use with --show-tape");

    if (infiles.size() == 0) {  // If no filenames were passed
        for (string line; getline(cin, line);)  // Try reading from stdin
            infiles.push_back(line);
        if (infiles.size() == 0)  // If still none are passed
            print_err("at least one filename is required");
    }

    for (string fn : infiles) {
        vector<char> code = get_clean_code(fn);
        evaluate(code, dump_tape, show_tape, input, delay);
    }

    return 0;
}
