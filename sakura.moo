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

.program #1:name
return this.name;
.

.program #1:dname
return tostr("the ", this:name());
.

.program #1:iname
name = this:name();
if (has_property(this, "article"))
    return tostr(this.article, " ", name);
endif
return tostr($english_utils:article_for(name), " ", name);
.

.program #1:title
return this:name();
.

.program #7:_start
who = args[1];
who:tell("You start fooing.")
return {3, $nothing};
.

.program #7:_finish
who = args[1];
who:tell("You finish fooing.");
.

.program #7:_abort
who:tell("You stop fooing.");
.

.program #7:doing_msg
return "fooing";
.

.program $actor:process_queue
":process_queue()";
continuation = {};
while (this.queue || continuation)
    this.preemptible = 0;
    if (continuation)
        {action, args, int, cmd} = spec = continuation;
        startverb = "_continue";
        continuation = {};
    else
        {action, args, int, cmd} = spec = this.queue[1];
        startverb = "_start";
        this.queue = listdelete(this.queue, 1);
    endif
    this.executing = {@spec, 0};
    try
        result = action:(startverb)(this, args);
    except e (ANY)
        if (e[1] == E_NONE)
            result = E_NONE;
        else
            result = E_INVARG;
        endif
    endtry
    status = this.executing[5];
    this.executing[5] = 1;
    if (status in {2, 3})
        this:cancel_current_action(status == 3);
    elseif (typeof(result) != ERR)
        {duration, pass_to_finish} = result;
        suspend(duration);
        if (has_callable_verb(action, "_finish"))
            this.executing[5] = 4;
            try
                continuation = action:_finish(this, args, pass_to_finish);
            except e (ANY)
                if (e[1] != E_NONE)
                    "Notify someone or something of exception.";
                endif
            endtry
            status = this.executing[5];
        endif
    endif
    this.executing = {};
    if (status in {2, 3})
        "Something called the action while we were running _finish, so abort instead of queuing continuation.";
        continuation = {};        
    endif
endwhile
this.preemptible = 1;
.

.program $actor:fork_process_queue
":fork_process_queue()";
force = args ? args[1] | 0;
if ((!force) && task_valid(this.process_queue))
    return;
endif
fork pq_task (0)
    this:process_queue();
endfork
this.process_queue = pq_task;
this.preemptible = 0;
this.executing = {};
.

.program $actor:queue_action
":queue_action(OBJ action, LIST args, BOOL int, STR cmd)";
{action, args, int, cmd} = spec = args;
if (length(this.queue) > 25)
    this:tell($ansi.cyan, "[ Sorry -- can't queue ", action.name, " (", cmd, "), more than 25 actions! ]", $ansi.reset);
    return;
endif
this.queue = listappend(this.queue, spec);
if (task_valid(this.process_queue))
    if (this.preemptible)
        this:cancel_current_action();
    else
        this:tell($ansi.cyan, "[ queued '", cmd, "' ]", $ansi.reset);
    endif
else
    this:fork_process_queue();
endif
.

.program $actor:cancel_current_action
":cancel_current_action([INT dontabort])";
{?dontabort = 0} = args;
if (this.executing)
    if (this.executing[5] == 0)
        "We are in _start, set a flag telling :process_queue to stop the action.";
        this.executing[5] = 2 + dontabort;
        return;
    elseif (this.executing[5] in {2, 3})
        "Already asked to abort, nothing to do...";
        return;
    elseif (this.executing[5] == 4)
        "Doing _finish, so we can't really cancel now, but if it's a continuing action it might still want to do something.";
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
    old_pq = this.process_queue;
    if (this.queue)
        "Calling with a 1 to force it.";
        this:fork_process_queue(1);
    endif
    if (task_valid(old_pq))
        kill_task(old_pq);
    endif
endif
.

.program $actor:clear_queue
":clear_queue()";
this.queue = {};
this:cancel_current_action(1);
this.preemptible = 1;
.

.program $actor:queue
if (dobjstr && player.programmer)
    if (!valid(dobj))
        player:tell("queue who?");
        return;
    endif
    if (!is_a(dobj, $actor))
        player:tell("You can't queue that.");
    endif
    player:tell("Showing queue for ", toliteral(dobj), ":");
else   
    dobj = this;
endif
if ((!dobj.queue) && (!dobj.executing))
    player:tell("You've got nothing to do.");
else
    if (dobj.executing)
        player:tell("At the moment, you're ", dobj:doing_msg(), ".");
    endif
    for x in (dobj.queue)
        player:tell("  --> ", x[4]);
    endfor
    player:tell("  --> (end of queue)");
endif
.

.program $actor:doing_msg
if (this.executing)
    if (is_a(this.executing[1], $action))
        return this.executing[1]:(verb)(this, this.executing[2]);
    endif
    return "";
endif
.

.program $creature:tell
notify(this, tostr(@args));
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

.program $english_utils:quote
":quote(OBJ who, STR text)
.

.program $english_utils:article_for
":article_for(STR s)";
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

";add_property($ansi, "esc", "", {#3, "r"});";
;add_property($ansi, "reset", tostr($ansi.esc, "[0m"), {#3, "r"});
;add_property($ansi, "bold_on", tostr($ansi.esc, "[1m"), {#3, "r"});
;add_property($ansi, "bold_off", tostr($ansi.esc, "[22m"), {#3, "r"});
;add_property($ansi, "black", tostr($ansi.esc, "[30m"), {#3, "r"});
;add_property($ansi, "red", tostr($ansi.esc, "[31m"), {#3, "r"});
;add_property($ansi, "green", tostr($ansi.esc, "[32m"), {#3, "r"});
;add_property($ansi, "yellow", tostr($ansi.esc, "[33m"), {#3, "r"});
;add_property($ansi, "blue", tostr($ansi.esc, "[34m"), {#3, "r"});
;add_property($ansi, "magenta", tostr($ansi.esc, "[35m"), {#3, "r"});
;add_property($ansi, "cyan", tostr($ansi.esc, "[36m"), {#3, "r"});
;add_property($ansi, "white", tostr($ansi.esc, "[37m"), {#3, "r"});
;add_property($ansi, "black_bg", tostr($ansi.esc, "[40m"), {#3, "r"});
;add_property($ansi, "red_bg", tostr($ansi.esc, "[41m"), {#3, "r"});
;add_property($ansi, "green_bg", tostr($ansi.esc, "[42m"), {#3, "r"});
;add_property($ansi, "yellow_bg", tostr($ansi.esc, "[43m"), {#3, "r"});
;add_property($ansi, "blue_bg", tostr($ansi.esc, "[44m"), {#3, "r"});
;add_property($ansi, "magenta_bg", tostr($ansi.esc, "[45m"), {#3, "r"});
;add_property($ansi, "cyan_bg", tostr($ansi.esc, "[46m"), {#3, "r"});
;add_property($ansi, "white_bg", tostr($ansi.esc, "[47m"), {#3, "r"});