#include "prog.hpp"


string LANG_NAMES[] = { "NoLang", "ASM", "C", "C++" };



void Prog::auto_bin_name() {
    this->bin_name = this->src_name[0] == '/' ? "" : "./";
    this->bin_name += this->src_name + ".to";
}


void Prog::set_lang(string lang) {
    transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
    if (lang == "s" || lang == "asm" || lang == "assembly")
        this->lang = LANG_ASM;
    else if (lang == "c")
        this->lang = LANG_C;
    else if (lang == "cpp" || lang == "c++")
        this->lang = LANG_CPP;
    else
        die("Language not recognized:", lang);
}


void Prog::auto_lang() {
    size_t pos = this->src_name.rfind(".");
    string lang;
    if (pos != string::npos)
        lang = this->src_name.substr(pos+1);
    this->set_lang(lang);
}


void Prog::parse_args(int argc, char *argv[]) {
    this->commands = 0;
    this->lang = NO_LANG;
    bool show_help = false;

    queue<string> pos_args;

    string arg;
    for (int i=1; i<argc; i++) {
        arg = string(argv[i]);

        if (arg == "-h" || arg == "--help")
            show_help = true;
        else if (arg == "--")
            ;  // Do nothing
        else
            pos_args.push(arg);
    }

    if (argc < 3 || show_help)
        help();

    // Make sure there are at least commands and an src_name
    if (pos_args.size() < 2)
        usage();

    // Parse commands
    for (char c : pos_args.front()) {
        switch (c) {
            case 'a': this->commands |= ASSEMBLE; break;
            case 'c': this->commands |= COMPILE;  break;
            case 'e': this->commands |= EXECUTE;  break;
            case 'f': this->commands |= FORCE;    break;
            case 'x': this->commands |= LANG;     break;
            case 'o': this->commands |= OUTFILE;  break;
            case 'r': this->commands |= REMOVE;   break;
            default:  die("Command not recognized:", string(1, c));  break;
        }
    }
    pos_args.pop();

    // Error check commands
    if (this->commands == 0)
        die("No commands were given");

    this->src_name = pos_args.front();
    pos_args.pop();
    // Make sure src_name isn't an empty string
    if (this->src_name.empty())
        die("Infile cannot be an empty string");
    // Make sure src_name exists
    if (! file_exists(this->src_name))
        die("Infile does not exist:", this->src_name);

    if (HAS_OUTFILE(this->commands)) {
        if (!pos_args.size())
            usage();  // print error message?
        this->bin_name = pos_args.front();
        pos_args.pop();
    }

    if (HAS_LANG(this->commands)) {
        if (!pos_args.size())
            usage();  // print error message?
        this->set_lang(pos_args.front());
        pos_args.pop();
    } else {
        this->auto_lang();
    }

    if (HAS_EXECUTE(this->commands) && HAS_ASSEMBLE(this->commands)
            && !HAS_COMPILE(this->commands))
        die("Execution requires compilation (the 'c' command)");

    // Get object file name
    this->obj_name = this->src_name + ".o";

    // Determine the binary filename if it wasn't specified by the user
    if (this->bin_name.empty())
        this->auto_bin_name();

    this->exec_args.reserve(1 + pos_args.size());
    this->exec_args.push_back(this->bin_name);
    while (!pos_args.empty()) {
        this->exec_args.push_back(pos_args.front());
        pos_args.pop();
    }
}


void help() {
    cout << USAGE << endl;
    puts("");
    puts("Note");
    puts("  All arguments after the last positional argument (outfile if the");
    puts("  outfile command (o) was given, lang if the lang command (x) was");
    puts("  given, otherwise infile) will be passed to the program if the");
    puts("  execute command (e) was given.");
    puts("");
    puts("Options");
    puts("  -h, --help   Print this help message and exit");
    puts("");
    puts("Positional Arguments");
    puts("  commands     A single word consisting of command characters in");
    puts("               any order");
    puts("  infile       The source file for a single-file C, C++, or Linux");
    puts("               x86 Assembly program");
    puts("  lang         The language to compile for");
    puts("  outfile      The name of the outfile");
    puts("");
    puts("Commands");
    puts("  a            Assemble the program (gcc -c)");
    puts("  c            Compile the program");
    puts("  d            Print out the commands that would be executed,");
    puts("               output is suitable for use in a shell");
    puts("  e            Execute the compiled program");
    puts("  f            Do not prompt before overwriting files");
    puts("  o            What to name the binary");
    puts("  r            Remove the binary and all compilation files");
    puts("  x            The language of the infile");
    exit(0);
}


void usage() {
    cerr << USAGE << endl;
    cerr << "See `to --help` for more information" << endl;
    die();
}
