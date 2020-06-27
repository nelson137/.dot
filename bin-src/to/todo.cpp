bool is_clean(char& c) {
    return (43 <= c && c <= 57)
        || c == 61
        || (64 <= c && c <= 90)
        || c == 95
        || (97 <= c && c <= 122);
}


bool is_clean(string& str) {
    for (char c : str)
        if (!is_clean(c))
            return false;
    return true;
}


string sanitize(string str) {
    if (is_clean(str))
        return str;

    char singleQuote = '\'';
    size_t pos = 0;

    do {
        if ((pos = str.find(singleQuote, pos)) == string::npos)
            break;
        str.insert(pos, "'\\'");
        pos += 4;
    } while (true);
    return '\'' + str + '\'';
}


void print_args(vector<string> args) {
    cout << sanitize(args[0]);
    for (unsigned i=1; i<args.size(); i++)
        cout << " " << sanitize(args[i]);
    cout << endl;
}
