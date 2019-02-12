#ifndef __MYLIBPP_H

#define __MYLIBPP_H


#include <ios>
#include <iostream>
#include <string>
#include <vector>

#include <termios.h>

using namespace std;


struct PRet {
    int exitstatus;
    string out;
    string err;
};


bool file_exists(string);

string trim_whitespace(string);

string join(vector<string>, string=" ");

vector<string> split(string, string=" ");


class any {

private:
    enum type {Char, Int, Float, Double, Size_t, String};
    char   CHAR;
    int    INT;
    float  FLOAT;
    double DOUBLE;
    size_t SIZE_T;
    string STRING;

public:
    type m_type;

    any(char   c) { this->m_type = Char;   this->CHAR   = c; }
    any(int    i) { this->m_type = Int;    this->INT    = i; }
    any(float  f) { this->m_type = Float;  this->FLOAT  = f; }
    any(double d) { this->m_type = Double; this->DOUBLE = d; }
    any(size_t s) { this->m_type = Size_t; this->SIZE_T = s; }
    any(string s) { this->m_type = String; this->STRING = s; }

    string str() {
        switch (this->m_type) {
            case Char:   return string(1, this->CHAR);
            case Int:    return to_string(this->INT);
            case Float:  return to_string(this->FLOAT);
            case Double: return to_string(this->DOUBLE);
            case Size_t: return to_string(this->SIZE_T);
            case String: return this->STRING;
        }
    }

};


void die(int=1);


template<typename T, typename... Ts>
void die(int code, T t, Ts... ts) {
    vector<string> tokens = {any(t).str(), any(ts).str()...};
    cerr << join(tokens) << endl;
    die(code);
}


template<typename T, typename... Ts>
void die(T t, Ts... ts) {
    die(1, t, ts...);
}


bool read_fd(int, string&);

int execute(PRet&, vector<string>&, bool=false);

PRet easy_execute(vector<string>&, bool=false);


class Listbox {

private:
    struct termios oldt;

    bool show_title;
    string title;
    string cursor;
    vector<string> choices;

    void print_instructs();
    string cursor_spaces();
    void print(string, bool=false);
    void print_title();
    void save_term_attrs();
    void setup_term();
    void restore_term();
    void draw(unsigned const&);
    void redraw(unsigned const&);

public:

    static const string df_cursor;
    static const string df_title;

    int chosen;

    Listbox(vector<string>&, string=df_title, string=df_cursor);

    int run(bool=true);

};


#endif
