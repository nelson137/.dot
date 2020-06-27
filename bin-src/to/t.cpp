#include <iostream>
#include <string>
#include <vector>

using namespace std;


template<typename... Strings>
void die(int code, Strings... msg) {
    vector<string> tokens = { msg... };
    if (tokens.size()) {
        auto it = tokens.cbegin();
        cerr << *it++;
        for (; it!=tokens.cend(); it++)
            cerr << ' ' << *it;
    }
    cerr << endl;
    // exit(code);
    cout << "exit(" << code << ")" << endl;
}


template<typename... Strings>
void die(const string& m, Strings... msg) {
    die(1, m, msg...);
}


void die() {
    die(1);
}


int main() {
    die();

    die("A");
    die("B", "C");

    die(2);
    die(2, "D");
    die(2, "E", "F");

    return 0;
}
