#include <stdio.h>    // printf, puts, getchar
#include <string.h>   // strlen
#include <termios.h>  // termios, ICANON, ECHO, TCSANOW
#include <unistd.h>   // STDIN_FILENO


// Terminal settings variable for stdin
static struct termios oldt;


// Draw the listbox choices with the cursor on the selected choice
void lb_draw(char *choices[], int n_choices, int current, char *cursor) {
    for (int i=0; i<n_choices; i++) {
        if (i == current)
            // Print the cursor
            printf("%s ", cursor);
        else
            // Print spaces where the cursor would be
            printf("%*c ", (int)strlen(cursor), ' ');
        puts(choices[i]);
    }
}


// Draw over an already printed listbox
void lb_redraw(char *choices[], int n_choices, int current, char *cursor) {
    // Go back to the top of the listbox output
    for (int i=0; i<n_choices; i++)
        printf("\33[A\33[2K");
    // Draw the listbox
    lb_draw(choices, n_choices, current, cursor);
}


int listbox(int show_instructions, char *title, char *choices[], int n_choices, char *cursor) {
    if (show_instructions) {
        // Print instructions
        puts("Press k/j or up/down arrow to move up and down.");
        puts("Press q to quit.");
        puts("Press Enter to confirm the selection.");
        puts("");
    }

    // Print the title and underline if it's not NULL
    if (title != NULL) {
        // Print the title
        printf("%*s %s\n", (int)strlen(cursor), "", title);

        // Print the title underline
        printf("%*s ", (int)strlen(cursor), "");
        for (int i=0; i<strlen(title); i++)
            printf("-");
        puts("");
    }

    // Get current settings for stdin
    tcgetattr(STDIN_FILENO, &oldt);

    // Copy the old terminal settings
    static struct termios newt;
    newt = oldt;
    // Disable ICANON and ECHO terminal flags
    newt.c_lflag &= ~(ICANON|ECHO);
    // Apply settings
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    int current = 0;
    lb_draw(choices, n_choices, current, cursor);

    int choice = -1;
    char c;
    int quit = 0;
    int will_redraw;
    do {
        c = getchar();
        will_redraw = 1;

        switch (c) {
            case 'k':
            case 'A':  // Up arrow
                if (current > 0)
                    current--;
                else
                    will_redraw = 0;
                break;
            case 'K':
                current = 0;
                break;
            case 'j':
            case 'B':  // Down arrow
                if (current < n_choices-1)
                    current++;
                else
                    will_redraw = 0;
                break;
            case 'J':
                current = n_choices-1;
                break;
            case '\n':
                choice = current;
                will_redraw = 0;
                quit = 1;
                break;
            case 'q':
                quit = 1;
                break;
        }

        if (will_redraw == 1)
            lb_redraw(choices, n_choices, current, cursor);
    } while (quit != 1);

    // Restore old settings
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

    return choice;
}
