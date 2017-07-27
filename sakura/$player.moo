.program $player:l*ook
if (!valid(player.location))
    player:tell("There is only darkness.");
endif
player:tell(player.location:name());
.