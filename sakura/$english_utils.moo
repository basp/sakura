.program $english_utils:quote
":quote(OBJ who, STR text, [BOOL real_name, [STR override_name]]) => 'Who says, \"text\".'";
{who, text} = args;
name = who:title();
if (text)
    if (text[$] == "?")
        return tostr(name, " asks, \"", text, "\"");
    elseif (text[$] == "!")
        return tostr(name, " exlaims, \"", text, "\"");
    else
        return tostr(name, " says, \"", text, "\"");
    endif
else
    return name;
endif
.

.program $english_utils:article_for
":article_for(STR string)";
string = args[1];
if (!string)
    return "a";
endif
for i in [1..length(string)]
    if (index($string_utils.alphabet, string[i]))
        if (index("aeiou", string[i]))
            return "an";
        else
            return "a";
        endif
    endif
endfor
return "a";
.