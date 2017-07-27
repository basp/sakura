.program $player:look
if (!valid(player.location))
    player:tell("There is only darkness.");
elseif (valid(dobj))
    player:tell("It's ", dobj:iname(), ".");
elseif (dobjstr)
    player:tell("There's no '", dobjstr, "' here.");
else
    player:tell(player.location:name());
endif
.