.program $room:say
player:say(argstr);
.

.program $room:announce_all
for x in (this.contents)
    `x.listening ! ANY => 0' && x:tell(@args);
endfor
.

.program $room:announce_all_but
":announce_all_but(LIST objects_to_ignore, text)";
{ignore, @text} = args;
contents = this.contents;
for x in (ignore)
    contents = setremove(contents, x);
endfor
for x in (contents)
    `x.listening ! ANY => 0' && x:tell(@text);
endfor
.