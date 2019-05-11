#ifndef MYLIB_CPP_H
#define MYLIB_CPP_H


#include <algorithm>
#include <any>
#include <ios>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include <string.h>
#include <sys/stat.h>
#include <termios.h>
#include <unistd.h>
#include <wait.h>

using namespace std;


template<typename T>
struct is_string_castable {

private:
    typedef true_type yes;
    typedef false_type no;

    template<typename U>
    static auto test(char c) -> decltype(string(declval<U>()), yes());

    template<typename C>
    static no test(...);

public:
    using type = decltype(test<T>(0));
    static constexpr bool value = is_same<type,yes>::value;

};


struct exec_ret {
    int exitstatus;
    string out;
    string err;

    operator int() { return this->exitstatus; }
};


void catchSig(int, void *(int));

bool file_exists(string);

bool file_executable(string);

string trim_whitespace(string);

/**
 * Join the given vector with delim.
 * The default delim is a space.
 * Example:
 *     vector<string> v = {"a", "b", "c"};
 *     join(v);  // "a b c"
 */
template<typename T>
string join(vector<T> tokens, string delim=" ") {
    ostringstream str;

    if (tokens.size()) {
        str << tokens[0];
        for (unsigned i=1; i<tokens.size(); i++)
            str << delim << tokens[i];
    }

    return str.str();
}

vector<string> split(string, string=" ");


ostream& operator<<(ostream& os, any& a) {
    const type_info& type = a.type();

    if (type == typeid(char))
        os << string(1, any_cast<char>(a));
    else if (type == typeid(int))
        os << to_string(any_cast<int>(a));
    else if (type == typeid(float))
        os << to_string(any_cast<float>(a));
    else if (type == typeid(double))
        os << to_string(any_cast<double>(a));
    else if (type == typeid(size_t))
        os << to_string(any_cast<size_t>(a));
    else if (type == typeid(string))
        os << any_cast<string>(a);
    else
        throw bad_any_cast();

    return os;
}


ostream& operator<<(ostream& os, any&& a) {
    return operator<<(os, a);
}


void die(int=1);


template<typename... T>
void die(int code, string t, T... ts) {
    vector<any> tokens = {any(t), any(ts)...};
    if (tokens.size()) {
        cerr << tokens[0] << endl;
        for (int i=0; i<tokens.size(); i++)
            cerr << tokens[i];
    }
    die(code);
}


template<typename T, typename... Ts>
void die(T t, Ts... ts) {
    die(1, t, ts...);
}


bool read_fd(int, string&);


class ExecArgs {

private:
    vector<char*> args;

    char *string_copy(string& str) {
        char *s = new char[str.size()+1];
        strcpy(s, str.c_str());
        s[str.size()] = '\0';
        return s;
    }

public:
    char *bin;

    template<template<typename,typename> typename T>
    void init(string bin, T<string,allocator<string>> args) {
        this->bin = this->string_copy(bin);
        this->args = {this->bin, nullptr};

        this->args.reserve(this->args.size() + args.size());
        for (auto it=args.begin(); it!=args.end(); it++)
            this->push_back(*it);
    }

    template<template<typename,typename> typename T>
    ExecArgs(string bin, T<string,allocator<string>> args) {
        init(bin, args);
    }

    template<
        typename... Str,
        typename = enable_if_t<(... && std::is_convertible_v<Str, string>)>
    >
    ExecArgs(string bin, const Str... strs) {
        init(bin, vector<string>{strs...});
    }

    template<template<typename,typename> typename T>
    ExecArgs(T<string,allocator<string>> args) {
        string bin;
        if (args.size()) {
            bin = args[0];
            args.erase(args.begin());
        }
        init(bin, args);
    }

    ~ExecArgs() {
        for (char *s : this->args)
            delete[] s;
    }

    void push_back(string str) {
        this->args.insert(this->args.end()-1, this->string_copy(str));
    }

    char **get() {
        return this->args.data();
    }

};


template<typename T>
int execute(exec_ret& er, const T& args, bool capture_output=false) {
    ExecArgs ea(args);

    int pipes[2][2];
    int *out_pipe = pipes[0];
    int *err_pipe = pipes[1];

    // Create the stdout and stderr pipes
    if (capture_output) {
        if (pipe(out_pipe) < 0)
            die("Could not create pipe for stdout");
        if (pipe(err_pipe) < 0)
            die("Could not create pipe for stderr");
    }

    int child_out_fd = out_pipe[1];
    int child_err_fd = err_pipe[1];
    int parent_out_fd = out_pipe[0];
    int parent_err_fd = err_pipe[0];

    int pid = fork();

    if (pid == -1) {
        die("Could not fork");

    } else if (pid == 0) {
        /**
         * Child
         */

        if (capture_output) {
            dup2(child_out_fd, STDOUT_FILENO);
            dup2(child_err_fd, STDERR_FILENO);
        }

        close(child_out_fd);
        close(child_err_fd);
        close(parent_out_fd);
        close(parent_err_fd);

        execv(ea.bin, ea.get());
        _exit(0);
    } else {
        /**
         * Parent
         */

        // Child's end of the pipes are not needed
        close(child_out_fd);
        close(child_err_fd);

        // Wait for child to complete
        int status;
        waitpid(pid, &status, 0);

        er.exitstatus = WEXITSTATUS(status);

        if (capture_output) {
            // Read child's stdout
            if (! read_fd(parent_out_fd, er.out))
                die("Could not read stdout");
            // Read child's stderr
            if (! read_fd(parent_err_fd, er.err))
                die("Could not read stderr");
        }

        close(parent_out_fd);
        close(parent_err_fd);
    }

    return er.exitstatus;
}


template<typename T>
exec_ret easy_execute(const T& args, bool capture_output=false) {
    exec_ret er;
    execute(er, args, capture_output);
    return er;
}


namespace listbox {


extern string LB_CURSOR;
extern bool   LB_SHOW_INSTRUCTS;


const string NO_TITLE = "__NO_TITLE";
const string D_CURSOR = "*";


template<typename T,
         typename = std::enable_if_t<is_string_castable<T>::value>>
int run_listbox(string title, vector<T>& choices) {
    const string cursor_spaces = string(LB_CURSOR.size(), ' ');

    auto print = [&] (string str, bool prefix_cursor=false) {
        cout << (prefix_cursor ? LB_CURSOR : cursor_spaces)
             << " " << str << endl;
    };

    auto draw = [&] (unsigned current_i) {
        for (unsigned i=0; i<choices.size(); i++)
            print(string(choices[i]), i==current_i);
    };

    auto redraw = [&] (unsigned current_i) {
        // Go back to the top of the listbox output, clearing each line
        for (unsigned i=0; i<choices.size(); i++)
            cout << "\33[A\33[2K";
        draw(current_i);
    };

    if (LB_SHOW_INSTRUCTS) {
        cout << "Press k/j or up/down arrows to move up and down." << endl
             << "Press q to quit." << endl
             << "Press Enter to confirm the selection." << endl
             << endl;
    }

    if (title != NO_TITLE) {
        // Print the title
        print(title);
        // Print the underline
        print(string(title.length(), '-'));
    }

    // Save the current terminal settings
    struct termios oldt = {0};
    tcgetattr(STDIN_FILENO, &oldt);

    // Copy the old settings
    struct termios newt = oldt;
    // Disable canonical mode and echo
    newt.c_lflag &= ~(ICANON|ECHO);
    // Minimum number of character to read
    newt.c_cc[VMIN] = 1;
    // Block until read is performed
    newt.c_cc[VTIME] = 0;
    // Apply the new settings
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    bool quit = false;
    unsigned current = 0;

    int chosen = -1;
    draw(current);

    do {
        switch (cin.get()) {
            // Up
            case 'k':
            case 'A':  // Up arrow
                if (current > 0)
                    redraw(--current);
                break;

            // Top
            case 'K':
                redraw(current = 0);
                break;

            // Down
            case 'j':
            case 'B':  // Down arrow
                if (current < choices.size()-1)
                    redraw(++current);
                break;

            // Bottom
            case 'J':
                redraw(current = choices.size() - 1);
                break;

            // Quit
            case 'q':
                quit = true;
                break;

            // Confirm selection
            case '\n':
                chosen = current;
                quit = true;
                break;
        }
    } while (quit == false);

    // Restore term
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

    return chosen;
}


template<typename T,
         typename = std::enable_if_t<is_string_castable<T>::value>>
T run_listbox_critical(string title, vector<T>& choices) {
    int i = run_listbox(title, choices);
    if (i < 0)
        exit(1);
    return choices[i];
}


}  // namespace listbox


template<typename T>
ostream& operator<<(ostream& os, const vector<T*>& vec) {
    os << "{";
    if (vec.size()) {
        os << '"' << vec[0] << '"';
        for (unsigned i=1; i<vec.size(); i++)
            os << ", \""
               << (vec[i] == nullptr ? "(null)" : vec[i])
               << '"';
    }
    os << "}";
    return os;
}


template<typename T>
ostream& operator<<(ostream& os, const vector<T*>&& vec) {
    return operator<<(os, vec);
}


template<typename T>
ostream& operator<<(ostream& os, const vector<T>& vec) {
    os << "{";
    if (vec.size()) {
        os << '"' << vec[0] << '"';
        for (unsigned i=1; i<vec.size(); i++)
            os << ", \"" << vec[i] << '"';
    }
    os << "}";
    return os;
}


template<typename T>
ostream& operator<<(ostream& os, const vector<T>&& vec) {
    return operator<<(os, vec);
}


template<typename T>
vector<T> operator+(vector<T> a, vector<T> b) {
    vector<T> v;
    v.reserve(a.size() + b.size());
    v.insert(v.end(), a.begin(), a.end());
    v.insert(v.end(), b.begin(), b.end());
    return v;
}


template<typename L, typename R>
void append(L& l, R const& r) {
    l.insert(l.end(), r.begin(), r.end());
}


#endif
