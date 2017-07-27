@args #359:"_start" this none this
@program #359:_start
who = args[1];
exit = args[2][1];
penalty = 0;
if (typeof(exitstr = exit) == STR)
  exit = who.location:match_exit(exitstr);
  if (!valid(exit))
    who:tell("You can't go '", exitstr, "' from here.");
    who:clear_queue();
    return 0;
  else
    who:prequeue_action(this, {exit}, 1, "", 1);
    return E_NONE;
  endif
endif
if (!valid(exit))
  return 0;
endif
player = who;
if ((e = (random(100) < 50) ? who:tell_encumbrance() | who:encumbrance()) < -3)
  who:tell("You're too weighted down to go anywhere.");
  return E_NONE;
endif
exit_try = exit:try_me(who);
if (exit_try)
  time = `exit:speed(who) + ((e < -2) ? 1.0 | 0.0) ! ANY => 0.0';
  who.location:broadcast_event(1, this, @args);
  return {time, 1};
else
  return E_NONE;
endif
.

@args #359:"_finish" this none this
@program #359:_finish
who = args[1];
exit = args[2][1];
if (typeof(exitstr = exit) == STR)
  exit = who.location:match_exit(exitstr);
  if (!is_a(exit, $exit))
    return 0;
  endif
endif
if (exit:try_me(who, 1))
  return exit:move(who);
endif
.

@args #359:"doing_msg" this none this
@program #359:doing_msg
who = args[1];
if ((args[2] && (typeof(args[2][1]) == OBJ)) && gamevalid(args[2][1]))
  return "moving to " + args[2][1]:dname();
else
  return "moving";
endif
.