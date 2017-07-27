# I got sick of trying to find out how to *get* the ANSI ESC character.
# This script will write a text file that contains the ANSI ESC character.
# Have fun copy pasting it into your MOO database! :P
f = open("ansi_escape.txt", "w");
f.write(u"\u001b");
f.close();