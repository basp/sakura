#107:l*ook   any any any
if (valid(dobj) && is_a(dobj, $exit) && dobjstr != "sky")
  dobj:look_self();
  return;
endif
if (args && dobjstr != "sky" && !this:can_see())
  if (is_a(this.location, $room))
    this:tell(this.location.too_dark_msg);
  else
    this:tell("It's too dark to see much of anything.");
  endif
  return;
endif
pad = player:check_pref("lookpad");
tit = player:check_pref("looktitle");
obv = 1;
if (is_a(dobj, #457204))
  obv = dobj:obvious();
endif
if (!valid(this.location))
  player:tell($ansi.cyan + "[ Something's gone wrong. An administrator will be notified, please wait
. ]" + $ansi.reset);
  $nets.prognet:announce(#-1, tostr("Warning: ", player.name, " is in #-1."), 1);
  return;
elseif (this.location == #742)
  this.location:look_self();
  return;
endif
if (dobjstr == "" && !prepstr)
  this.location:look_self();
elseif (dobjstr == "sky")
  pad && player:tell();
  this.location:look_sky();
elseif (prepstr != "in" && prepstr != "on")
  if (!dobjstr && prepstr == "at")
    dobjstr = iobjstr;
    iobjstr = "";
  else
    dobjstr = dobjstr + (prepstr && (dobjstr && " ") + prepstr);
    dobjstr = dobjstr + (iobjstr && (dobjstr && " ") + iobjstr);
  endif
  dobj = $match_utils:match(dobjstr, {@this.contents, @this.location.contents});
  if (is_a(this.location, #43226) && valid(this.location.probe) && is_a(this.location.probe.location
, $room))
    dobj = $match_utils:match(dobjstr, this.location.probe.location.contents);
  endif
  if (!valid(dobj) && `player.location:look_override(@args) ! E_VERBNF')
    return;
  endif
  if (!$command_utils:object_match_failed(dobj, dobjstr))
    if (`!dobj:is_hidden(player) ! E_VERBNF => 1')
      obv && pad && player:tell();
      obv && tit && player:tell($ansi.bold_on, dobj:title(), $ansi.reset);
      dobj:look_self();
    else
      return player:tell("I see no \"", dobjstr, "\" here.");
    endif
  endif
elseif (!iobjstr)
  player:tell(verb, " ", prepstr, " what?");
else
  iobj = $match_utils:match(iobjstr, {@this.contents, @this.location.contents});
  if (!$command_utils:object_match_failed(iobj, iobjstr))
    if (dobjstr == "")
      if (`!iobj:is_hidden(player) ! E_VERBNF => 1')
        pad && player:tell();
        tit && player:tell($ansi.bold_on, iobj:title(), $ansi.reset);
        iobj:look_self();
      else
        return player:tell("I see no \"", iobjstr, "\" here.");
      endif
    elseif (is_a(iobj, $container) && iobj.open == 0 && iobj.opaque)
      player:tell(iobj:dnamec(), " is closed - you can't tell what's inside it.");
    elseif (is_a(iobj, $container) || `iobj:can_look_into(this) ! ANY => 0' && valid(thing =
iobj:match_contents(dobjstr)))
      player:tell("You peer into ", iobj:dname(), "...");
      pad && player:tell();
      return thing:look_self();
    elseif ((thing = iobj:match(dobjstr)) == $failed_match)
      if (`!iobj:is_hidden(player) ! E_VERBNF => 0')
        player:tell("I don't see any \"", dobjstr, "\" ", prepstr, " ", iobj.name, ".");
      else
        return player:tell("I see no \"", dobjstr, "\" ", prepstr, " ", iobjstr, ".");
      endif
    elseif (thing == $ambiguous_match)
      player:tell("There are several things ", prepstr, " ", iobj.name, " one might call \"",
dobjstr, "\".");
    else
      if (`!thing:is_hidden(player) ! E_VERBNF => 1')
        pad && player:tell();
        tit && player:tell($ansi.bold_on, thing:title(), $ansi.reset);
        thing:look_self();
      else
        return player:tell("I see no \"", dobjstr, "\" ", prepstr, " ", iobj.name, ".");
      endif
    endif
  endif
endif