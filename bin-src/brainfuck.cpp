#include <stdlib.h>
#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <algorithm>
#include <map>

using namespace std;

#define usage "usage: brainfuck infile"


map<int, int> get_bracemap(vector<char> code) {
    vector<int> temp_bm;
    map<int, int> bm;
    for (int i=0; i<code.size(); i++) {
        if (code[i] == '[') {
            temp_bm.push_back(i);
        } else if (code[i] == ']') {
            int start = temp_bm.back();
            temp_bm.pop_back();
            bm[start] = i;
            bm[i] = start;
        }
    }

    return bm;
}


void evaluate(vector<char> code, map<int, int> bm) {
    vector<int> cells;
    cells.push_back(0);

    int codeptr = 0;
    int cellptr = 0;

    char cmd;
    while (codeptr < code.size()) {
        cmd = code[codeptr];
        switch (cmd) {
            case '>':
                if (++cellptr == cells.size()) cells.push_back(0);
                break;
            case '<':
                cellptr = cellptr <= 0 ? 0 : --cellptr;
                break;
            case '+':
                cells[cellptr] = cells[cellptr] < 255 ? ++cells[cellptr] : 0;
                break;
            case '-':
                cells[cellptr] = cells[cellptr] > 0 ? --cells[cellptr] : 255;
                break;
            case '[':
                if (cells[cellptr] == 0) codeptr = bm[codeptr];
                break;
            case ']':
                if (cells[cellptr] != 0) codeptr = bm[codeptr];
                break;
            case '.':
                cout << (char)cells[cellptr];
                break;
            case ',':
                char c;
                cin >> c;
                cells[cellptr] = (int)c;
                break;
        }

        codeptr++;
    }
}


void execute(char* fn) {
    if (!fn) {
        cerr << usage << endl;
        exit(1);
    }

    vector<char> code;
    
    ifstream file(fn);
    if (file.is_open()) {
        char bf_chars_arr[] = {'<', '>', '+', '-', '[', ']', '.', ','};
        vector<char> bf_chars(bf_chars_arr, bf_chars_arr + sizeof(bf_chars_arr) / sizeof(bf_chars_arr[0]));
        
        string line;
        while (getline(file, line)) {
            for (char c : line) {
                if (find(bf_chars.begin(), bf_chars.end(), c) != bf_chars.end()) {
                    code.push_back(c);
                }
            }
        }

        file.close();

        evaluate(code, get_bracemap(code));
    } else {
        cerr << "Unable to open file " << fn << endl;
        exit(1);
    }
}


int main(int argc, char* argv[]) {
    if (argc == 2) {
        execute(argv[1]);
        return 0;
    } else {
        cout << usage << endl;
        return 1;
    }
}
