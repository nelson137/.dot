#include "exec.hpp"


exec_ret::operator int() {
    return this->exitstatus;
}


char *ExecArgs::string_copy(string& str) {
    char *s = new char[str.size()+1];
    strcpy(s, str.c_str());
    s[str.size()] = '\0';
    return s;
}


ExecArgs::~ExecArgs() {
    for (char *s : this->args)
        delete[] s;
}


void ExecArgs::push_back(string str) {
    this->args.insert(this->args.end()-1, this->string_copy(str));
}


char **ExecArgs::get() {
    return this->args.data();
}


bool read_fd(int fd, string& dest) {
    int count;
    char buff[128];

    do {
        count = read(fd, buff, sizeof(buff)-1);
        if (count == -1)
            return false;
        buff[count] = '\0';
        dest += buff;
    } while (count > 0);

    return true;
}
