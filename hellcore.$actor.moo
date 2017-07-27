@args #92:"process_queue" this none this
@program #92:process_queue
":process_queue()";
"Keep running actions until we don't have any to run.";
player = this;
next_action_delay = 0;
if (`this.location.no_actions ! ANY')
  this.queue = {};
  return;
endif
if ((!this.queue) && (this.health > 0))
  if (action = this:_suggest_next_action())
    this.queue = {action[1], @this.queue};
    next_action_delay = action[2];
  endif
endif
continuation = {};
while (this.queue || continuation)
  this.preemptible = 0;
  pass_to_finish = 0;
  if (this.queue || continuation)
    if (continuation)
      action = continuation;
      startverb = "_continue";
      continuation = 0;
    else
      action = this.queue[1];
      this.queue = listdelete(this.queue, 1);
      startverb = "_start";
    endif
    if (!is_a(action[1], #1))
      continue;
    endif
    this.last_action && (this.last_last_action = this.last_action);
    this.last_action = action;
    debugtext = $su:print(action[2..$]);
    "...sanity check...";
    if (((!action[2]) || (typeof(action[2][1]) != OBJ)) || (!is_a(action[2][1], $garbage)))
      if (is_a(this.location, $room) && (!this.location:check_forbid_action(this, @action)))
        "...nobody in here cancelled us...";
        this.executing = {@action, @{$action, {}, 1, "", 0}[length(action) + 1..$]};
        try
          result = action[1]:(startverb)(this, action[2]);
          if ($debug)
            $archwiz:tell($su:nn(this), " => ", $su:nn(action[1]));
          endif
        except e (ANY)
          if (e[1] == E_NONE)
            result = E_NONE;
          else
            extra_info = $su:nn(action[1]) + tostr(" args: ", toliteral(action[2]));
            $rpg:report_error(e, extra_info);
            result = E_INVARG;
          endif
        endtry
        status = this.executing[5];
        this.executing[5] = 1;
        if (status in {2, 3})
          "Something called the action while we were running _start, so abort now.";
          this:cancel_current_action(status == 3);
          "We're never going to end up here, as :cancel_current_action kills the task we are running
in.";
        elseif (typeof(result) != ERR)
          if (typeof(result) == LIST)
            if (length(result) > 1)
              pass_to_finish = result[2];
            else
              pass_to_finish = 0;
            endif
            do_continue = (length(result) > 2) ? result[3] | 0;
            durint = result[1];
            if (typeof(durint) == FLOAT)
              "slow down if lots of people are acting...";
              actors = -1;
              for x in (this.location:occupants($actor))
                if (`x.executing ! ANY => 0')
                  actors = actors + 1;
                endif
              endfor
              durint = durint * (1.0 + (tofloat(actors) * 0.2));
            endif
            durint = $math_utils:gil_float_to_int(durint);
          else
            durint = 0;
            pass_to_finish = result;
          endif
          suspend(abs(durint));
          if (!is_a(this, $actor))
            return;
          endif
          if (has_callable_verb(action[1], "_finish"))
            this.executing[5] = 4;
            try
              continuation = action[1]:_finish(this, action[2], pass_to_finish);
            except e (ANY)
              if (e[1] != E_NONE)
                extra_info = $su:nn(action[1]) + tostr(" args: ", toliteral(action[2]));
                if (pass_to_finish)
                  extra_info = {extra_info, tostr("pass_to_finish: ", toliteral(pass_to_finish))};
                endif
                $rpg:report_error(e, extra_info);
              endif
            endtry
            status = this.executing[5];
          endif
        endif
        `this._tohit_next = 0 ! ANY => 0';
        this.executing = {};
      else
        this:debug_tell("action", "forbid | ", $su:nn(action[1]), " ", debugtext);
        `action[1]:_forbidden(this, @action[2..$]) ! ANY => 0';
      endif
    endif
  endif
  data = action;
  if ((typeof(continuation) == LIST) && continuation)
    "...make it look like we're executing the continued action.  It'll execute back at the top.";
    this.executing = continuation = {@continuation, @{$action, {}, "", 1, 0}[length(continuation) +
1..$]};
    if (status in {2, 3})
      "Something called the action while we were running _finish, so abort instead of queuing
continuation.";
      this:cancel_current_action(status == 3);
      continuation = 0;
    endif
  else
    continuation = 0;
  endif
  this.preemptible = next_action_delay > 0;
  suspend(next_action_delay);
  if (is_a(this, $garbage))
    "we died...";
    return;
  endif
  this.preemptible = 0;
  data = action;
  if (((!continuation) && (!this.queue)) && (!`this.possessors ! ANY => 0'))
    "...no more queued actions, do we have an auto-action?...";
    if (has_callable_verb(this, "_suggest_next_action") && (result = this:_suggest_next_action()))
      action = result[1];
      if (((action[1] in $rpg.repeatable_actions) || is_player(this)) || (action != this
.last_action))
        next_action_delay = result[2];
        "...add our auto-action to the queue...";
        this.queue = {action, @this.queue};
      endif
    endif
  else
    next_action_delay = 0;
  endif
  this.action_count = this.action_count + 1;
  if ((this.action_count >= 90) && (!`this.no_action_warn ! ANY => 0'))
    next_action_delay = max(next_action_delay, 1);
    if (((time() - $nets.prognet.last_action_warning) > 10) && (!is_player(this)))
      debug_info = tostr($su:nn(data[1]), " args: ", $su:sv(data[2]), @pass_to_finish ? {" pass: " +
toliteral(pass_to_finish)} | {});
      $nets.bugnet:announce(#-1, tostr($su:nn(this), " reached action count of ", this.action_count,
"!"), 1);
      $nets.bugnet:announce(#-1, tostr("with: ", debug_info), 1);
      $nets.prognet.last_action_warning = time();
      if (`this.heart ! ANY' == 0)
        $heart:register(this);
      endif
    endif
  endif
endwhile
this.preemptible = 1;
.

@args #92:"fork_process_queue" this none this
@chmod #92:fork_process_queue rx
@program #92:fork_process_queue
":fork_process_queue()";
"Fork off a process_queue task.";
"If args[1], do it even if there's a valid one already.";
force = args ? args[1] | 0;
if ((!force) && task_valid(this.process_queue))
  return;
endif
fork pq_task (0)
  player = this;
  this:process_queue();
endfork
this.process_queue = pq_task;
this.preemptible = 0;
this.executing = {};
.

@args #92:"queue_action" this none this
@program #92:queue_action
":queue_action(OBJ action, LIST callback_args[, BOOL interruptable, STR command_strin])";
"Add an action to the queue, and start the queue if needed.";
action = args[1];
cargs = args[2];
inter = (length(args) > 2) ? args[3] | 1;
cmd = (length(args) > 3) ? args[4] | "";
if (length(this.queue) > 25)
  this:tell($ansi.cyan + "[ Sorry -- can't queue ", action.name, " (", cmd, "), more than 25
actions! ]" + $ansi.reset);
  return;
endif
if (this.programmer)
  `this:debug_tell("action", "queue  | " + $su:nn(action)) ! ANY => 0';
endif
queue_item = {action, cargs, inter, cmd};
this.queue = {@this.queue, queue_item};
if (task_valid(this.process_queue))
  if (this.preemptible)
    "...we're already running a low-priority paused-before-action, so kill it...";
    this:cancel_current_action();
  else
    if (cmd)
      this:tell((($ansi.cyan + ("[ queued '" + args[4])) + "' ]") + $ansi.reset);
    endif
  endif
else
  this:fork_process_queue();
endif
.

@args #92:"suggest_next_action" this none this
@program #92:suggest_next_action
return;
.

@args #92:"qu*eue" any none none
@chmod #92:queue rxd
@program #92:queue
if (dobjstr && player.programmer)
  if (!valid(dobj))
    dobj = $su:match_player(dobjstr);
    if (!valid(dobj))
      player:tell("queue who?");
      return;
    endif
  endif
  if (!is_a(dobj, $actor))
    player:tell("You can't queue that.");
    return;
  endif
  player:tell("Showing queue for ", $su:nn(dobj), ":");
else
  dobj = this;
endif
if ((!dobj.queue) && (!dobj.executing))
  player:notify("You've got nothing to do.");
else
  if (dobj.executing)
    player:notify(("At the moment, you're " + tostr(dobj:doing_msg())) + ".");
  endif
  for x in (dobj.queue)
    player:notify("  --> " + x[4]);
  endfor
  player:notify("  --> (end of queue)");
endif
.

@args #92:"doing_msg" this none this
@program #92:doing_msg
if (this.executing)
  if (this.executing[1] == this)
    return "doing something";
  elseif (is_a(this.executing[1], $action))
    return this.executing[1]:(verb)(this, this.executing[2]);
  elseif ($ou:has_verb(this.executing[1], "action_" + verb))
    return this.executing[1]:("action_" + verb)(this, this.executing[2]);
  else
    doingverb = is_a(this.executing[1], $action) ? "doing_msg" | "action_doing_msg";
    $nets.gamenet:announce(#2, tostr($su:nn(this.executing[1]), " lacks a :", doingverb, "() => ",
toliteral(this.executing)), 1);
    return "using " + this.executing[1]:iname();
  endif
  return "";
endif
.

@args #92:"clear_queue" this none this
@program #92:clear_queue
":clear_queue()";
"Kill all queued actions.";
this.queue = {};
this:cancel_current_action(1);
this.preemptible = 1;
.

@args #92:"cancel_current_action" this none this
@program #92:cancel_current_action
":cancel_current_action([INT dontabort])";
"If we're currently executing an action, abort it and immediately start our next action.";
{?dontabort = 0} = args;
if (this.executing && (length(this.executing) >= 5))
  if (this.executing[5] == 0)
    "We are in _start, set a flag telling :process_queue to stop the action.";
    this.executing[5] = 2 + dontabort;
    return;
  elseif (this.executing[5] in {2, 3})
    "Already asked to abort, nothing to do...";
    return;
  elseif (this.executing[5] == 4)
    "Doing _finish, so we can't really cancel now, but if it a continuing action it might still want
to do something...";
    this.executing[5] = 2 + dontabort;
    return;
  elseif (this.executing[5] == 1)
    "We are between _start and _finish, cancel and move on.";
    if ((!dontabort) && has_callable_verb(this.executing[1], "_abort"))
      this.executing[1]:_abort(this, @this.executing[2..4]);
    endif
    this.executing = {};
    "It is intentional that this case doesn't return.";
  endif
endif
old_pq = this.process_queue;
if (this.queue)
  "Calling with a 1 to force it.";
  this:fork_process_queue(1);
endif
if (task_valid(old_pq))
  kill_task(old_pq);
endif
.

@args #92:"jumpstart" this none this
@program #92:jumpstart
"See if we have an action from :suggest_next_action().  If so, throw it on the queue and fire it up
.";
"Don't do anything if we already have a valid process_queue.";
if (!this.f)
  if (!task_valid(this.process_queue))
    if (this.queue)
      this.owner:tell($ansi.yellow, "  Restarting dead queue for ", $su:nn(this), ".", $ansi.reset);
      this.owner:tell($ansi.yellow, $su:from_list(this.queue[1], " "), $ansi.reset);
      this:fork_process_queue();
    elseif (r = this:suggest_next_action())
      this.queue = {r[1]};
      this:fork_process_queue();
    endif
  endif
endif
.

@args #92:"prequeue_action" this none this
@program #92:prequeue_action
":prequeue_action(OBJ action, LIST callback_args, BOOL interruptable, STR command_string, [INT
no_cancel_current])";
"Insert an action at the head of the queue for immediate next execution, cancelling any action
currently being executed (or not, with 5 args).";
if ((length(args) < 5) || (!args[5]))
  if (!`this.executing[1].unstoppable ! ANY')
    this:cancel_current_action();
  endif
endif
if (!this.queue)
  this:queue_action(@args);
else
  action = args[1];
  cargs = args[2];
  inter = (length(args) > 2) ? args[3] | 1;
  cmd = (length(args) > 3) ? args[4] | "";
  this.queue = {{action, cargs, inter, cmd}, @this.queue};
endif
.

@args #92:"backup_queue" this none this
@program #92:backup_queue
"Copied from generic actor (#716):queue by Gilmore (#98) Tue Aug  7 19:37:24 2007 CDT";
if ((!this.queue) && (!this.executing))
  player:notify("You've got nothing to do.");
else
  if (this.executing)
    player:notify(("At the moment, you're " + this:doing_msg()) + ".");
  endif
  for x in (this.queue)
    player:notify("  --> " + x[4]);
  endfor
  player:notify("  --> (end of queue)");
endif
.

@args #92:"is_doing" this none this
@program #92:is_doing
if (this.executing)
  doing = this.executing;
elseif (this.queue)
  doing = this.queue[1];
else
  return args ? 0 | #-1;
endif
if (!args)
  return doing[1];
else
  {?action = #-1, ?target = #-1} = args;
endif
doing_target = `doing[2][1] ! ANY => #-1';
if (doing[1] == action)
  if (valid(target))
    if (target == doing_target)
      return 1;
    else
      return 0;
    endif
  endif
  return 1;
endif
return 0;
.

@args #92:"cancel_if_possible" this none this
@program #92:cancel_if_possible
if (this.executing)
  if (!`this.executing[1].unstoppable ! ANY')
    return this:cancel_current_action();
  endif
endif
.

@args #92:"take_damage" this none this
@args #92:"iname" this none this
@program #92:iname
name = this:name();
if (!name)
  return "";
endif
if (this.f)
  name = strsub(name, "generic ", "");
endif
if ((this.article == "") || (has_property(this, "has_proper_name") && this.has_proper_name))
  return name;
elseif (!this.article)
  if (index("aeiou", name[1]))
    return "an " + name;
  elseif (index("bcdfghjklmnpqrstvwxyz", name[1]))
    return "a " + name;
  else
    return ($english_utils:article_for(name) + " ") + name;
  endif
else
  return (this.article + " ") + name;
endif
.

@args #92:"floats" this none this
@program #92:floats
"Copied from generic thing (#5):floats by Gilmore (#98) Sat Jun 27 05:19:29 2009 CDT";
return this.floats;
.