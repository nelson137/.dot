#define _DEFAULT_SOURCE
#define _GNU_SOURCE

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

#define ARRLEN(x) sizeof(x)/sizeof(x[0])
#define MAX 512

#define POS_ARG             0
#define LONG_OPT            1
#define SHORT_OPT           2
#define COMPOUND_SHORT_OPT  3

// Bitflags for options
#define HELP      1  // 0b000001
#define QUIET     2  // 0b000010
#define COMPILE   4  // 0b000100
#define EXECUTE   8  // 0b001000
#define REMOVE   16  // 0b010000
#define DRYRUN   32  // 0b100000

enum Lang {
    LangUnknown,
    LangASM,
    LangC,
    LangCPP
};

typedef struct {
    char **argv;
    int argc;
    int parsing_opts;
    int parsing_sub_args;
    int flags;
    char *forced_lang;
    char *outfile;
} Options;

typedef struct {
    int exited;
    int exitstatus;
    int signaled;
    int termsig;
    int coredump;
    int stopped;
    int stopsig;
    int continued;
    char out[MAX];
    char err[MAX];
} PRet;

char *USAGE = "Usage: to [-h] [-q] [-d] [-c] [-e] [-r] [-l LANG] <infile>\n"
              "       [-o OUTFILE] [-x [ARGS...]]\n";


/*************************************************
 * Utility Functions
 ************************************************/


/**
 * Print an error message to stderr and exit with code 1.
 */
void error(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
}


void help() {
    printf("%s", USAGE);
    puts("");
    puts("Positional Arguments");
    puts("  infile          The source file for a single-file C, C++, or x86");
    puts("                  Assembly program");
    puts("");
    puts("Command Options");
    puts("  -c, --compile   Compile the program");
    puts("  -e, --execute   Execute the compiled program");
    puts("  -r, --remove    Remove the binary and any compilation files");
    puts("");
    puts("Options");
    puts("  -h, --help      Print this help message and exit");
    puts("  -o, --outfile OUTFILE");
    puts("                  What name to give the binary");
    puts("  -q, --quiet     Suppress OUTPUT and END OUTPUT messages");
    puts("  -l, --lang LANGUAGE");
    puts("                  Set the language to compile for");
    puts("  -d, --dry-run   Print out the commands that would be executed in");
    puts("                  response to the -c, -e, and -r options");
    exit(0);
}


void print_args(char *args[], int len) {
    for (int i=0; i<len-1; i++)
        printf(
            "%s%s",
            i > 0 ? " " : "",
            args[i]);
    printf("\n");
}


void read_yesno(char response[], int size, char *prompt) {
    int index = 0;
    char c;

    printf("%s", prompt);

    do {
        c = getchar();
        if (c == '\n')
            break;
        if (index < size-1)
            response[index++] = c;
    } while (1);

    response[index] = '\0';
}


/**
 * Convert the string to lowercase.
 */
char *lower(char *str) {
    for (int i=0; str[i]; i++)
        if ('A' <= str[i] && str[i] <= 'Z')
            str[i] += 32;
    return str;
}


/**
 * Return whether the first string matches any of the following strings.
 */
int strMatchesAny(char *str, char *a, ...) {
    if (strcmp(str, a) == 0)
        return 1;

    va_list strings;
    va_start(strings, a);

    char *arg;
    do {
        arg = va_arg(strings, char*);
        if (arg == NULL)
            break;
        if (strcmp(str, arg) == 0)
            return 1;
    } while (1);

    va_end(strings);

    return 0;
}


/**
 * Return a pointer to the extension of the given filename.
 * Return an empty string if no extension can be determined.
 */
char *getExt(char *fn) {
    char *lastdot = strrchr(fn, '.');
    if (!lastdot || lastdot == fn)
        return "";
    return lastdot + 1;
}


int execute(PRet *ret, char *argv[], int len, int capture_output) {
    // Make sure argv ends with NULL sentinel
    if (argv[len-1] != NULL) {
        strcpy(ret->err, "Last argument of argv must be a null pointer\n");
        return -1;
    }

    int pipes[2][2];
    int *out_pipe = pipes[0];
    int *err_pipe = pipes[1];

    if (capture_output) {
        if (pipe(out_pipe) < 0) {
            strcpy(ret->err, "Could not create pipe for stdout\n");
            return -2;
        }
        if (pipe(err_pipe) < 0) {
            strcpy(ret->err, "Could not create pipe for stderr\n");
            return -2;
        }
    }

    int parent_out_fd = out_pipe[0];
    int parent_err_fd = err_pipe[0];
    int child_out_fd = out_pipe[1];
    int child_err_fd = err_pipe[1];

    int pid = fork();

    if (pid == -1) {
        strcpy(ret->err, "Could not fork\n");
        return -3;
    } else if (pid == 0) {
        /**
         * Child
         */

        if (capture_output) {
            dup2(child_out_fd, STDOUT_FILENO);
            dup2(child_err_fd, STDERR_FILENO);

            close(parent_out_fd);
            close(parent_err_fd);
            close(child_out_fd);
            close(child_err_fd);
        }

        execv(argv[0], argv);
        _exit(1);
    } else {
        /**
         * Parent
         */

        if (capture_output) {
            // Child's end of the pipes are not needed in the parent
            close(child_out_fd);
            close(child_err_fd);
        }

        // Wait for child to complete
        int status;
        waitpid(pid, &status, 0);

        ret->exited = WIFEXITED(status);
        ret->exitstatus = WEXITSTATUS(status);
        ret->signaled = WIFSIGNALED(status);
        ret->termsig = WTERMSIG(status);
        ret->coredump = WCOREDUMP(status);
        ret->stopped = WIFSTOPPED(status);
        ret->stopsig = WSTOPSIG(status);
        ret->continued = WIFCONTINUED(status);

        if (capture_output) {
            int count;
            char out[MAX], err[MAX];

            // Read child's stdout
            count = read(parent_out_fd, out, sizeof(out)-1);
            if (count == -1) {
                strcpy(ret->err, "Could not read child's stdout\n");
                return -4;
            }
            out[count] = '\0';
            strcpy(ret->out, out);

            // Read child's stderr
            count = read(parent_err_fd, err, sizeof(err)-1);
            if (count == -1) {
                strcpy(ret->err, "Could not read child's stderr\n");
                return -4;
            }
            err[count] = '\0';
            strcpy(ret->err, err);

            close(parent_out_fd);
            close(parent_err_fd);
        } else {
            strcpy(ret->out, "");
            strcpy(ret->err, "");
        }
    }

    return 0;
}


/*************************************************
 * Core Functions
 ************************************************/


/**
 * Return the flag corresponding to the language to compile for.
 */
enum Lang determineLang(char *lang) {
    if (strMatchesAny(lang, "s", "asm", "assembly", "x86", "x86_64", NULL))
        return LangASM;
    else if (strMatchesAny(lang, "c", NULL))
        return LangC;
    else if (strMatchesAny(lang, "cpp", "c++", NULL))
        return LangCPP;
    else
        return LangUnknown;
}


/**
 * Return the flag corresponding to the language indicated by the filename.
 */
int autoDetermineLang(char *fn) {
    char *ext = getExt(fn);
    return strcmp(ext, "") == 0 ? LangUnknown : determineLang(ext);
}


/**
 * Compile the program for assembly.
 */
int compile_asm(int dryrun, char *src_name, char *obj_name, char *bin_name) {
    char *nasm_args[] = {
        "/usr/bin/nasm", "-f", "elf64", src_name, "-o", obj_name, NULL};
    char *ld_args[] = {
        "/usr/bin/ld", obj_name, "-o", bin_name, NULL};

    if (dryrun) {
        print_args(nasm_args, ARRLEN(nasm_args));
        print_args(ld_args, ARRLEN(ld_args));
    } else {
        PRet nasm_ret, ld_ret;

        execute(&nasm_ret, nasm_args, ARRLEN(nasm_args), 1);
        if (!nasm_ret.exited || nasm_ret.exitstatus != 0) {
            error("Could not create object file for infile: %s\n\n", src_name);
            error(nasm_ret.err);
            return nasm_ret.exitstatus;
        }

        execute(&ld_ret, ld_args, ARRLEN(ld_args), 1);
        if (!ld_ret.exited || ld_ret.exitstatus != 0) {
            error("Could not link object file: %s\n\n", obj_name);
            error(ld_ret.err);
            return ld_ret.exitstatus;
        }
    }

    return 0;
}


/**
 * Compile the program for C.
 */
int compile_c(int dryrun, char *src_name, char *bin_name) {
    // Get the cflags for the python library
    PRet pylibRet;
    char *pkgconfig_args[] = {
        "/usr/bin/pkg-config", "--cflags", "--libs", "python3", NULL};
    execute(&pylibRet, pkgconfig_args, ARRLEN(pkgconfig_args), 1);
    if (!pylibRet.exited || pylibRet.exitstatus != 0) {
        error("Could not get gcc flags for the python3 library\n");
        return pylibRet.exitstatus;
    }

    // Remove trailing newline
    char *nl = strrchr(pylibRet.out, '\n');
    if (nl && nl != pylibRet.out)
        *nl = '\0';

    // Split the pylibs string
    // Example string: "abc def ghi\0"
    int n = 1;
    for (int i=0; pylibRet.out[i]; i++) {
        if (pylibRet.out[i] == ' ') {
            n++;
            // Replace each space with '\0'
            pylibRet.out[i] = '\0';
        }
    }
    // Example string would now be: "abc\0def\0ghi\0"
    // Fill the flags array with a pointer to each null-terminated segment
    char *pylib_args[n];
    int pylib_args_len = 0;
    char *pointer = pylibRet.out;
    // array with example string will be: {"abc\0", "def\0", "ghi\0"}
    for (int i=0; i<n; i++) {
        pointer = strchr(pointer, '\0') + 1;
        if (strlen(pointer) > 0)
            pylib_args[pylib_args_len++] = pointer;
    }

    char *base_args[11] = {
        "/usr/bin/gcc",
        "-std=c11", "-O3", "-Wall", "-Werror",
        src_name, "-o", bin_name,
        "-lmylib", "-lm"};
    int base_args_len = 10;
    if (access("/usr/lib/x86_64-linux-gnu/libjson-c.a", F_OK) == 0)
        base_args[base_args_len++] = "-ljson-c";

    // Combine base_args, pylib_args, and NULL sentinel
    int args_len = base_args_len + pylib_args_len + 1;
    char *args[args_len];
    int count = 0;
    for (int i=0; i<base_args_len; i++)
        args[count++] = base_args[i];
    for (int i=0; i<pylib_args_len; i++)
        args[count++] = pylib_args[i];
    args[count] = NULL;

    if (dryrun) {
        print_args(args, args_len);
    } else {
        PRet ret;
        execute(&ret, args, args_len, 1);
        if (!ret.exited || ret.exitstatus != 0) {
            error("Could not compile infile: %s\n\n", src_name);
            error(ret.err);
            return ret.exitstatus;
        }
    }

    return 0;
}


/**
 * Compile the program for C++.
 */
int compile_cpp(int dryrun, char *src_name, char *bin_name) {
    char *args[] = {
        "/usr/bin/g++",
        "-std=c++11", "-O3", "-Wall", "-Werror",
        src_name, "-o", bin_name,
        NULL};

    if (dryrun) {
        print_args(args, ARRLEN(args));
    } else {
        PRet ret;
        execute(&ret, args, ARRLEN(args), 1);
        if (!ret.exited || ret.exitstatus != 0) {
            error("Could not compile infile: %s\n\n", src_name);
            error(ret.err);
            return ret.exitstatus;
        }
    }

    return 0;
}


/*************************************************
 * Argument Parsing
 ************************************************/


int arg_type(char *arg) {
    int len = strlen(arg);
    char first = arg[0];
    char second = arg[1];

    if (len < 2 || first != '-')
        return POS_ARG;

    if (len == 2)
        return SHORT_OPT;

    if (second == '-')
        return LONG_OPT;
    else
        return COMPOUND_SHORT_OPT;
}


int process_opt(int *i, char *arg, int type, Options *opts) {
    if (strcmp(opts->argv[*i], "--") == 0)
        opts->parsing_opts = 0;
    else if (strMatchesAny(arg, "-h", "--help", NULL))
        opts->flags |= HELP;
    else if (strMatchesAny(arg, "-q", "--quiet", NULL))
        opts->flags |= QUIET;
    else if (strMatchesAny(arg, "-c", "--compile", NULL))
        opts->flags |= COMPILE;
    else if (strMatchesAny(arg, "-e", "--execute", NULL))
        opts->flags |= EXECUTE;
    else if (strMatchesAny(arg, "-r", "--remove", NULL))
        opts->flags |= REMOVE;
    else if (strMatchesAny(arg, "-o", "--outfile", NULL))
        opts->outfile = opts->argv[++(*i)];
    else if (strMatchesAny(arg, "-l", "--language", NULL))
        opts->forced_lang = opts->argv[++(*i)];
    else if (strMatchesAny(arg, "-d", "--dry-run", NULL))
        opts->flags |= DRYRUN;
    else if (strMatchesAny(arg, "-x", "--args", NULL))
        opts->parsing_opts = 0, opts->parsing_sub_args = 1;
    else
        return -1;

    return 0;
}


/*************************************************
 * Main
 ************************************************/


int main(int argc, char *argv[]) {
    if (argc < 3) {
        error(USAGE, argv[0]);
        return 1;
    }

    int exitstatus = 0;

    /**
     * Parse arguments
     */

    Options opts = {
        .argv = argv,
        .argc = argc,
        .parsing_opts = 1,
        .parsing_sub_args = 0,
        .flags = 0,
        .forced_lang = NULL,
        .outfile = NULL,
    };

    char *src_name = NULL;
    int too_many_src_fns = 0;
    char **sub_args = malloc(sizeof(char*) * argc);
    int sub_args_i = 0;

    char temp_opt[] = "-X";
    int type;
    char *opt_err = "Option not recognized: %s\n";
    for (int i=1; i<argc; i++) {
        type = arg_type(argv[i]);

        if (opts.parsing_sub_args) {  // Sub arg
            sub_args[sub_args_i++] = argv[i];
        } else if (type == POS_ARG || !opts.parsing_opts) {  // Positional arg
            if (src_name == NULL)
                src_name = argv[i];
            else
                too_many_src_fns = 1;
        } else if (type == COMPOUND_SHORT_OPT) {  // Compound short option
            for (int j=1; j<strlen(argv[i]); j++) {
                temp_opt[1] = argv[i][j];
                if (process_opt(&i, temp_opt, SHORT_OPT, &opts) < 0) {
                    error(opt_err, temp_opt);
                    goto end1;
                }
            }
        } else {  // Long option
            if (process_opt(&i, argv[i], type, &opts) < 0) {
                error(opt_err, argv[i]);
                goto end1;
            }
        }
    }

    /**
     * Error messages and setup
     */

    if (opts.flags & HELP)
        help();

    if (! (opts.flags & (COMPILE|EXECUTE|REMOVE))) {
        error("No commands were given\n");
        goto end1;
    }

    // The -c, --compile option was not given
    if (! (opts.flags & COMPILE)) {
        error("Program requires compilation\n");
        goto end1;
    }

    // None or more than one src_name was given
    if (src_name == NULL || too_many_src_fns) {
        error(USAGE, argv[0]);
        goto end1;
    }

    if (access(src_name, F_OK) != 0) {
        error("Infile does not exist\n");
        goto end1;
    }

    // Get the programming language as an integer
    enum Lang lang;
    if (opts.forced_lang == NULL) {
        lang = autoDetermineLang(src_name);
        if (lang == LangUnknown) {
            error("Could not determine language from filename: %s\n",
                src_name);
            goto end1;
        }
    } else {
        if (strlen(opts.forced_lang) == 0) {
            error("Language cannot be empty string\n");
            goto end1;
        }
        lang = determineLang(lower(opts.forced_lang));
        if (lang == LangUnknown) {
            error("Language not recognized: %s\n", opts.forced_lang);
            goto end1;
        }
    }

    // Get the executable filename
    char *bin_name;
    if (opts.outfile == NULL) {
        if (src_name[0] == '/') {
            bin_name = malloc(strlen(src_name) + 3 + 1);
            sprintf(bin_name, "%s.to", src_name);
        } else {
            bin_name = malloc(2 + strlen(src_name) + 3 + 1);
            sprintf(bin_name, "./%s.to", src_name);
        }
    } else {
        bin_name = opts.outfile;
    }

    if (access(bin_name, F_OK) == 0) {
        char *fmt = "Executable file '%s' exists\nOverwrite it [y/n]? ";
        char prompt[strlen(fmt) - 2 + strlen(bin_name) + 1];
        sprintf(prompt, fmt, bin_name);

        char response[3];
        read_yesno(response, 3, prompt);
        lower(response);
        if (strcmp(response, "y") != 0)
            goto end2;
    }

    // Get the object file name
    // Only used for ASM
    char *obj_name;
    if (bin_name[0] == '/') {
        obj_name = malloc(strlen(bin_name) + 2 + 1);
        sprintf(obj_name, "%s.o", bin_name);
    } else {
        obj_name = malloc(2 + strlen(bin_name) + 2 + 1);
        sprintf(obj_name, "./%s.o", bin_name);
    }

    if (access(obj_name, F_OK) == 0) {
        char *fmt2 = "Object file '%s' exists, overwrite it [y/n]? ";
        char prompt2[strlen(fmt2) - 2 + strlen(obj_name) + 1];
        sprintf(prompt2, fmt2, obj_name);

        char response2[3];
        read_yesno(response2, 3, prompt2);
        lower(response2);
        if (strcmp(response2, "y") != 0)
            goto end3;
    }

    /**
     * Execute commands
     */

    int retstat = 0;
    if (lang == LangASM)
        retstat = compile_asm(opts.flags & DRYRUN, src_name, obj_name,
                              bin_name);
    else if (lang == LangC)
        retstat = compile_c(opts.flags & DRYRUN, src_name, bin_name);
    else if (lang == LangCPP)
        retstat = compile_cpp(opts.flags & DRYRUN, src_name, bin_name);

    if (retstat != 0) {
        exitstatus = retstat;
        goto end3;
    }

    if (opts.flags & EXECUTE) {
        if (! (opts.flags & QUIET))
            printf("===== OUTPUT =====\n");
        char *all_exec_args[1 + sub_args_i + 1];
        int exec_args_i = 0;
        all_exec_args[exec_args_i++] = bin_name;
        for (int i=0; i<sub_args_i; i++)
            all_exec_args[exec_args_i++] = sub_args[i];
        all_exec_args[exec_args_i++] = NULL;

        if (opts.flags & DRYRUN) {
            print_args(all_exec_args, exec_args_i);
        } else {
            PRet execRet;
            execute(&execRet, all_exec_args, ARRLEN(all_exec_args), 0);
            exitstatus = execRet.exitstatus;
        }
        if (! (opts.flags & QUIET))
            printf("===== END OUTPUT =====\n");
    }

    if (opts.flags & REMOVE) {
        char *rm_args[lang == LangASM ? 4 : 3];
        int rm_args_i = 0;
        rm_args[rm_args_i++] = "/bin/rm";
        if (lang == LangASM)
            rm_args[rm_args_i++] = obj_name;
        rm_args[rm_args_i++] = bin_name;
        rm_args[rm_args_i] = NULL;

        if (opts.flags & DRYRUN) {
            print_args(rm_args, ARRLEN(rm_args));
        } else {
            PRet rmRet;
            execute(&rmRet, rm_args, ARRLEN(rm_args), 1);
            if (!rmRet.exited || rmRet.exitstatus != 0) {
                if (lang == LangASM) {
                    error("Could not remove files: %s %s\n", obj_name,
                        bin_name);
                } else {
                    error("Could not remove executable: %s\n", bin_name);
                    goto end3;
                }
            }
        }
    }

    end3:
        free(obj_name);
    end2:
        free(bin_name);
    end1:
        free(sub_args);
        return exitstatus;
}
