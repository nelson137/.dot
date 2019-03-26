#include <iostream>
#include <string>
#include <vector>

#include <termios.h>
#include <unistd.h>

#include "mylib.hpp"

using namespace std;


namespace listbox {


int run_listbox(LB lb) {
    if (lb.show_instructs) {
        cout << "Press k/j or up/down arrows to move up and down." << endl
             << "Press q to quit." << endl
             << "Press Enter to confirm the selection." << endl
             << endl;
    }

    if (lb.show_title) {
        // Print the title
        lb.print(lb.title);
        // Print the underline
        lb.print(string(lb.title.length(), '-'));
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
    lb.draw(current);

    do {
        switch (cin.get()) {
            // Up
            case 'k':
            case 'A':  // Up arrow
                if (current > 0)
                    lb.redraw(--current);
                break;

            // Top
            case 'K':
                lb.redraw(current = 0);
                break;

            // Down
            case 'j':
            case 'B':  // Down arrow
                if (current < lb.choices.size()-1)
                    lb.redraw(++current);
                break;

            // Bottom
            case 'J':
                lb.redraw(current = lb.choices.size() - 1);
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


int run_listbox(string title, vector<string>& choices, string cursor,
            bool show_instructs) {
    return run_listbox(LB(title, choices, cursor, show_instructs));
}


}  // namespace listbox
