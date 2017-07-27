.program $root:announce_action_text
this.location:announce_all(@args);
.

.program $root:name
return this.name;
.

.program $root:dname
"Definitive name";
return tostr("the ", this:name());
.

.program $root:iname
"Infinitive name";
name = this:name();
if (has_property(this, "article"))
    return tostr(this.article, " ", name);
endif
return tostr($english_utils:article_for(name), " ", name);
.

.program $root:dnamec
"Definitive name capitalized.";
return $string_utils:capitalize(this:dname());
.

.program $root:inamec
"Infinitive name capitalized.";
return $string_utils:capitalize(this:iname());
.

.program $root:title
"The thing's special title.";
return this:name();
.