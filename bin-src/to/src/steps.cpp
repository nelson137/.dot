#include "steps.hpp"


BuildStep::BuildStep(const string& of) : outfile(of) {
}


BuildStep::BuildStep(
    const string& of,
    const list<string>& l
) : BuildStep(of) {
    this->args = l;
}


BuildStep::BuildStep(
    const string& of,
    const initializer_list<string>& il
) : BuildStep(of) {
    this->args = il;
}


void BuildStep::add_arg(const string& a) {
    this->args.push_back(a);
}


string BuildStep::perform_step(const string& infile, bool force) {
    if (file_exists(this->outfile) && force == false) {
        cout << "Object file exists: " << this->outfile << endl;
        ask_rm_file(this->outfile);
    }

    this->add_arg(infile);

    int code = easy_execute(this->args);
    if (code != 0)
        die(code, "Could not compile file:", infile);

    return this->outfile;
}
