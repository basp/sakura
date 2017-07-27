.program #7:_start
who = args[1];
player:aat(who:name(), " starts fooing.");
return {3, 0};
.

.program #7:_finish
who = args[1];
player:aat(who:name(), " finishes fooing.");
.

.program #7:_abort
who = args[1];
player:aat(who:name(), " stops fooing.");
.

.program #7:doing_msg
return "fooing";
.