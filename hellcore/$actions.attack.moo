@args #222:"_start" this none this
@program #222:_start
who = args[1];
obv_dobj = args[2][1];
if (!is_a(obv_dobj, $creature))
  return E_NONE;
endif
dobj = obv_dobj:effective_target(who);
if (!is_a(dobj, $creature))
  return E_NONE;
endif
with = args[2][2];
bodypart = (length(args[2]) > 2) ? args[2][3] | dobj:random_bodypart();
if (who.location != dobj.location)
  return E_INVARG;
endif
who.location:broadcast_event(1, this, @args);
whocover = who in who.location.covering;
dobjcover = dobj in dobj.location.covering;
bonus = 1;
if (is_a(with, #102))
  canreach = $rpg:reach(who, dobj, tostr("You come out from behind cover to attack with your ",
with:name(), "."), tostr(who:dnamec(), "'s furious charge drives you out of your hiding place."));
else
  canreach = 1;
endif
who.last_dodge_time = 0;
if (!(canreach && with:can_attack(who, dobj)))
  return {4.0, E_INVARG};
endif
bonus = who:base_attack(bonus, with, dobj);
if ((dark = who.location:darkness(0, who)) && ((!who:can_see_in_dark()) || (dark < 0)))
  bonus = bonus - (dark * 3);
endif
if ((dark < 2) || dobj:can_see_in_dark())
  bonus = dobj:base_dodge(bonus, with, who);
endif
check = with:check_skill(who, bonus, 1);
if ((!with:start_attack(who, dobj, check, bodypart)) || ((!dobj:reachable_by(who)) &&
(!is_a(who:weapon(), #284))))
  who.fighting = setremove(who.fighting, obv_dobj);
  return {max(6.0 - (tofloat($skills.cool:total(who)) / 8.0), 2.0), E_INVARG};
endif
speed = with:speed(who);
speed = (speed + 0.5) - (tofloat(random(10)) / 10.0);
return {speed, {check, bodypart}};
.

@args #222:"_finish" this none this
@program #222:_finish
who = args[1];
obv_target = args[2][1];
if (!is_a(obv_target, $creature))
  return;
endif
target = obv_target:effective_target(who);
if (!is_a(target, $creature))
  return E_NONE;
endif
with = args[2][2];
if ((((who.location != target.location) || (typeof(args[3]) == ERR)) || is_a(target, $corpse)) ||
(!is_a(with, $weapon)))
  return;
endif
result = args[3][1];
bodypart = args[3][2];
power = (length(args[3]) > 2) ? args[3][3] | 0;
tv_msg = "";
with.skill:possibly_improve(who, result);
if (result < 0)
  msg = with:miss_msg(who, target, result, 0, bodypart);
  msg = this:render(who, target, power, ($ansi.bold_on + $ansi.blue) + "/", $su:ps(msg, who, with,
bodypart, target));
else
  result = target:dodge_or_parry(who, with, result, bodypart);
  if (typeof(result) == STR)
    "...target actively defended...";
    msg = result;
  elseif (typeof(result) == LIST)
    "...target actively defended... (new format)";
    msg = this:render(who, target, power, ($ansi.yellow + $ansi.bold_on) + result[1], result[2]);
  elseif (typeof(damage = with:inflict_damage(target, result, bodypart, who, power)) == STR)
    "...it was absorbed by armor...";
    msg = this:render(who, target, power, ($ansi.blue + $ansi.bold_on) + "v", damage);
  else
    "...we scored a hit!";
    if ((is_a(with, $weapon) && is_a(with.noise, $noise)) && (random(100) < 10))
      who.location:make_noise(with.noise, who);
    endif
    meter = $rpg:mini_damage(damage, target.health_max);
    msg_mine = with:hit_msg(who, target, result, damage, bodypart);
    msg = $su:capitalize($su:ps(msg_mine, who, with, bodypart, target));
    if (is_a(bodypart, #25749) && (is_a(with, #135) || is_a(with, #842)))
      tv_msg = msg;
    endif
    msg = this:render(who, target, power, meter, msg);
  endif
endif
if (msg)
  if (tv_msg)
    #47065:report({$su:capitalize(tv_msg)});
  endif
  who:aat(msg);
endif
with:finish_attack(who, target);
who.location:broadcast_event(0, this, @args);
.

@args #222:"maybe_reattack" this none this
@program #222:maybe_reattack
who = args[1];
dobj = args[2];
with = args[3];
if (dobj.location == who.location)
  if (!who.action_queue)
    with:attack();
  endif
endif
.

@args #222:"_forbidden" this none this
@program #222:_forbidden
args[1].fighting = setremove(args[1].fighting, args[2][1]);
.

@args #222:"combat_report_name" this none this
@program #222:combat_report_name
who = args[1];
if (is_a(who, $player) && (!who.programmer))
  return (($ansi.green + $ansi.bold_on) + who.name[1]) + $ansi.reset;
elseif (is_a(who, $immortal) && who.code_name)
  return (($ansi.cyan + $ansi.bold_on) + who.code_name[1]) + $ansi.reset;
else
  return (($ansi.cyan + $ansi.bold_on) + who.name[1]) + $ansi.reset;
endif
.

@args #222:"render" this none this
@program #222:render
"Copied from code holder (#404418):render by Irony (#413385) Sun Aug  8 00:43:22 2010 CDT";
{who, target, power, symbol, msg} = args[1..5];
whoi = this:combat_report_name(who);
tari = this:combat_report_name(target);
health_color = $ansi.((is_a(target, $player) && (!who.programmer)) ? "green" | "cyan");
bracket_color = $ansi.(power ? "red" | "white") + $ansi.bold_on;
return tostr(((((((((bracket_color + "[") + $ansi.reset) + whoi) + symbol) + $ansi.reset) + tari) +
bracket_color) + "][") + health_color, $su:right((target.health < 1) ? 0 | max(1, 
toint((tofloat(target.healt