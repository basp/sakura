.program $player:look
if (!valid(player.location))
    player:tell("There is only darkness.");
elseif (valid(dobj))
    "The user is looking at a dobj so we'll describe that.";
    player:tell("It's ", dobj:iname(), ".");
elseif (dobjstr)
    "We couldn't find a valid dobj but the user gave us a dobjstr though.";
    player:tell("There's no '", dobjstr, "' here.");
else
    "We'll asume the user is just casually looking around the room.";
    player:tell(player.location:name());
endif
.