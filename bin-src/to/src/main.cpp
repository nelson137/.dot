#include "main.hpp"


int main(int argc, char *argv[]) {
    Prog prog;
    prog.parse_args(argc, argv);

    int exitstatus = 0;

    if (prog.should_compile())
        prog.compile();

    if (prog.should_execute())
        exitstatus = prog.execute();

    if (prog.should_remove())
        prog.remove();

    return exitstatus;
}
