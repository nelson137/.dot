#ifndef __MYLIBPP_H

#define __MYLIBPP_H


#include <ios>
#include <iostream>
#include <string>
#include <vector>

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

        any(char   c) { this->m_type = Char;   this->CHAR   = c;         }
        any(int    i) { this->m_type = Int;    this->INT    = i;         }
        any(float  f) { this->m_type = Float;  this->FLOAT  = f;         }
        any(double d) { this->m_type = Double; this->DOUBLE = d;         }
        any(size_t s) { this->m_type = Size_t; this->SIZE_T = s;         }
        any(string s) { this->m_type = String; this->STRING = s;         }

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

        friend ostream& operator<<(ostream& os, any& a) {
            switch (a.m_type) {
                case Char:   os << a.CHAR;   break;
                case Int:    os << a.INT;    break;
                case Float:  os << a.FLOAT;  break;
                case Double: os << a.DOUBLE; break;
                case Size_t: os << a.SIZE_T; break;
                case String: os << a.STRING; break;
            }
            return os;
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


#endif
