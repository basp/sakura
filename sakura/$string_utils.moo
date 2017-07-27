.program $string_utils:capitalize
":capitalize(STR string)";
if (string = args[1])
    ansi = 0;
    for i in [1..length(string)]
        if (string[i] == "~")
            ansi = 1;
        elseif (ansi && string[i] == "m")
            ansi = 0;
        elseif (!ansi)
            if (testi = index("abcdefghijklmnopqrstuvwxyz", string[i], 0))
                string[i] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[testi];
                return string;
            endif
        endif
    endfor
    return string;
endif
.