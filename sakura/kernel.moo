.program here:eval
answer = eval("return " + argstr + ";");
if (answer[1])
    notify(player, tostr("=> ", toliteral(answer[2])));
else
    for line in (answer[2])
        notify(player, line);
    endfor
endif
.