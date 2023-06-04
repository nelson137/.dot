#!/usr/bin/env bash
#
# Print the ANSI 8-Bit Color Chart
# https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
#

################################################################################
### Printing utilities
################################################################################

# Usage: color BG_COLOR FG_COLOR [FMT]
#
# Print BG_COLOR with a foreground color of FG_COLOR and a background of
# BG_COLOR.
#
color() {
    local fmt="${3:- %03d}"
    printf "\x1b[48;5;${1}m\x1b[38;5;${2}m${fmt}\x1b[0m" "$1"
}

# Usage: w_color BG_COLOR [FMT]
#
# Print BG_COLOR with a foreground color of white and a background of BG_COLOR.
#
w_color() {
    local bg="$1"; shift
    color "$bg" 15 "$@"
}

# Usage: b_color BG_COLOR [FMT]
#
# Print BG_COLOR with a foreground color of black and a background of BG_COLOR.
#
b_color() {
    local bg="$1"; shift
    color "$bg" 0 "$@"
}

################################################################################
### Print the color blocks
################################################################################

simple_colors() {
    local i;
    for i in {0..7};  do w_color "$i" ' %02d'; done
    for i in {8..15}; do b_color "$i" ' %02d'; done
}

middle_colors_row() {
    local i
    for i in {0..5}; do w_color "$(( 16 + r + 36*i ))"; done
    for i in {0..5}; do b_color "$(( 34 + r + 36*i ))"; done
}

grayscale_color_row() {
    local i
    eval "for i in {$1..$2}; do $3" '"$i"; done'
}

################################################################################
### Print the chart
################################################################################

printf ' ╭──────────────────────────────────────────────────╮\n'
printf ' │  Standard colors         High-intensity colors   │\n'
printf ' │ '; simple_colors;                       printf ' │\n'
printf ' ╰──────────────────────────────────────────────────╯\n'

printf ' ╭──────────────────────────────────────────────────╮\n'
printf ' │  216 colors                                      │\n'
for r in {0..17}; do
printf ' │ '; middle_colors_row;                   printf ' │\n'
done
printf ' ╰──────────────────────────────────────────────────╯\n'
unset r

printf ' ╭──────────────────────────────────────────────────╮\n'
printf ' │  Grayscale colors                                │\n'
printf ' │ '; grayscale_color_row 232 243 w_color; printf ' │\n'
printf ' │ '; grayscale_color_row 244 255 b_color; printf ' │\n'
printf ' ╰──────────────────────────────────────────────────╯\n'
