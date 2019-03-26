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

    auto print = [&](string str, bool with_cursor=false){
        cout << (with_cursor ? lb.cursor : lb.cursor_spaces)
             << " " << str << endl;
    };

    if (lb.show_title) {
        // Print the title
        print(lb.title);
        // Print the underline
        print(string(lb.title.length(), '-'));
    }

    auto draw = [&](unsigned current_i){
        for (unsigned i=0; i<lb.choices.size(); i++)
            print(lb.choices[i], i==current_i);
    };

    auto redraw = [&](unsigned current_i){
        // Go back to the top of the listbox output
        for (unsigned i=0; i<lb.choices.size(); i++)
            // Clear each line
            cout << "\33[A\33[2K";
        // Draw the listbox
        draw(current_i);
    };

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

    char c;
    bool will_redraw, quit = false;
    unsigned current = 0;

    int chosen = -1;
    draw(current);

    do {
        c = cin.get();
        will_redraw = true;

        switch (c) {

            // Up
            case 'k':
            case 'A':  // Up arrow
                if (current > 0)
                    current--;
                else
                    will_redraw = false;
                break;

            // Top
            case 'K':
                current = 0;
                break;

            // Down
            case 'j':
            case 'B':  // Down arrow
                if (current < lb.choices.size()-1)
                    current++;
                else
                    will_redraw = false;
                break;

            // Bottom
            case 'J':
                current = lb.choices.size() - 1;
                break;

            // Quit
            case 'q':
                quit = true;
                break;

            // Confirm selection
            case '\n':
                chosen = current;
                will_redraw = false;
                quit = true;
                break;

        }

        if (will_redraw)
            redraw(current);
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
