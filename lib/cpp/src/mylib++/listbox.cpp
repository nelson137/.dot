#include <iostream>
#include <string>
#include <vector>

#include <termios.h>
#include <unistd.h>

#include "mylib++.hpp"

using namespace std;


const string Listbox::DEFAULT_CURSOR = "*";
const string Listbox::NO_TITLE = "__NO_TITLE";


void Listbox::print_instructs() {
    cout << "Press k/j or up/down arrows to move up and down." << endl;
    cout << "Press q to quit." << endl;
    cout << "Press Enter to confirm the selection." << endl;
    cout << endl;
}


string Listbox::cursor_spaces() {
    return string(this->cursor.length(), ' ');
}


void Listbox::print(string str, bool with_cursor) {
    cout << (with_cursor ? this->cursor : this->cursor_spaces());
    cout << " " << str << endl;
}


void Listbox::print_title() {
    // Print the title
    this->print(this->title);
    // Print the underline
    this->print(string(this->title.length(), '-'));
}


void Listbox::save_term_attrs() {
    this->oldt = {0};
    tcgetattr(STDIN_FILENO, &this->oldt);
}


void Listbox::setup_term() {
    this->save_term_attrs();
    struct termios newt = {0};
    // Copy the old settings
    newt = this->oldt;
    // Disable canonical mode and echo
    newt.c_lflag &= ~(ICANON|ECHO);
    // Minimum number of character to read
    newt.c_cc[VMIN] = 1;
    // Block until read is performed
    newt.c_cc[VTIME] = 0;
    // Apply the new settings
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
}


void Listbox::restore_term() {
    tcsetattr(STDIN_FILENO, TCSANOW, &this->oldt);
}


void Listbox::draw(unsigned current_i) {
    for (unsigned i=0; i<this->choices.size(); i++)
        this->print(this->choices[i], i==current_i);
}


void Listbox::redraw(unsigned current_i) {
    // Go back to the top of the listbox output
    for (unsigned i=0; i<this->choices.size(); i++)
        // Clear each line
        cout << "\33[A\33[2K";
    // Draw the listbox
    this->draw(current_i);
}


Listbox::Listbox(string title, vector<string>& choices, string cursor) {
    this->title = title;
    this->show_title = title != this->NO_TITLE;
    this->cursor = cursor;
    this->choices = choices;
}


int Listbox::run(bool show_instructs) {
    if (show_instructs)
        this->print_instructs();

    if (this->show_title)
        this->print_title();

    this->setup_term();

    char c;
    bool will_redraw, quit = false;
    unsigned current = 0;

    this->chosen = -1;
    this->draw(current);

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
                this->chosen = current;
                will_redraw = false;
                quit = true;
                break;

        }

        if (will_redraw)
            this->redraw(current);
    } while (quit == false);

    this->restore_term();
    return this->chosen;
}
