#include <iostream>
#include <string>
#include <vector>

#include <termios.h>
#include <unistd.h>

#include "mylib.hpp"

using namespace std;


const string Listbox::DEFAULT_CURSOR = "*";
const string Listbox::NO_TITLE = "__NO_TITLE";


Listbox::Listbox(string title, vector<string>& choices, string cursor) {
    this->title = title;
    this->show_title = title != this->NO_TITLE;
    this->cursor = cursor;
    this->choices = choices;
}


int Listbox::run(bool show_instructs) {
    if (show_instructs) {
        cout << "Press k/j or up/down arrows to move up and down." << endl
             << "Press q to quit." << endl
             << "Press Enter to confirm the selection." << endl
             << endl;
    }

    const string cursor_spaces = string(this->cursor.length(), ' ');

    auto print = [&](string str, bool with_cursor=false){
        cout << (with_cursor ? this->cursor : cursor_spaces)
             << " " << str << endl;
    };

    if (this->show_title) {
        // Print the title
        print(this->title);
        // Print the underline
        print(string(this->title.length(), '-'));
    }

    auto draw = [&](unsigned current_i){
        for (unsigned i=0; i<this->choices.size(); i++)
            print(this->choices[i], i==current_i);
    };

    auto redraw = [&](unsigned current_i){
        // Go back to the top of the listbox output
        for (unsigned i=0; i<this->choices.size(); i++)
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
                if (current < this->choices.size()-1)
                    current++;
                else
                    will_redraw = false;
                break;

            // Bottom
            case 'J':
                current = this->choices.size() - 1;
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
