.program $creature:tell
notify(this, tostr(@args));
.

.program $creature:say
txt = args[1] || "...";
m = $english_utils:quote(this, txt);
this:announce_action_text(m);
.

.program $creature:l*ook
.