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

.program $foo:_start
notify(player, "You start fooing.");
return {3, $nothing};
.

.program $foo:_finish
notify(player, "You finish fooing.");
.

.program $actor:process_action_queue
"Just return early if we're already processing the queue.";
if (valid(this.executing))
    return;
endif
"As long as there are any actions in the queue...";
while (length(this.action_queue) > 0)
    {action, args, description} = this.action_queue[1];
    this.action_queue = listdelete(this.action_queue, 1);
    this.executing = action;
    {duration, passToFinish} = this.executing:_start(args);
    suspend(duration);
    "Most actions can be stoppped so we need to make sure that didn't happen.";
    if(valid(this.executing))
        this.executing:_finish(passToFinish);
        this.executing = $nothing;
    endif
endwhile
.

.program $actor:stop
this.executing = $nothing;
this.action_queue = {};
.

.program $actor:queue_action
"Note that we are shadowing args here.";
{action, args, description} = spec = args[1];
this.action_queue = listappend(this.action_queue, spec);
this:process_action_queue();
.

