.program $root:announce_action_text
this.location:announce_all(@args);
.

.program $root:name
return this.name;
.

.program $root:dname
return tostr("the ", this:name());
.

.program $root:iname
name = this:name();
if (has_property(this, "article"))
    return tostr(this.article, " ", name);
endif
return tostr($english_utils:article_for(name), " ", name);
.

.program $root:dnamec
return $string_utils:capitalize(this:dname());
.

.program $root:inamec
return $string_utils:capitalize(this:iname());
.

.program $root:title
return this:name();
.