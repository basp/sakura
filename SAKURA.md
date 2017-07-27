## Sakura
This aims to be a complete guide to **Sakura**.

## Getting started (with minimal)
## Getting started (with sakura)
## Programming

## Reference
### Core
#### eval
OUr basic `eval` method setup in the "The First Room". You might seriously want to consider changing this but *do make a backup* and think well before you do.

#### $ansi
This has the ANSI codes to make fancy colors appear on terminal devices that support it.

> On devices that don't support this we'll be probably outputting garbage since we don't have any devices in place to strip the color codes from the output.

If you want to know what kinds of codes are supported you can just request the properties on the `$ansi` object:

    ;properties($ansi)
    => {"esc", "reset", "bold_on", "bold_off", "black", "red", "green", "yellow",
     "blue", "magenta", "cyan", "white", "black_bg", "red_bg", "green_bg", 
     "yellow_bg", "blue_bg", "magenta_bg", "cyan_bg", "white_bg"}

If you want to use these codes it's pretty easy, for example:

    ;player:tell($ansi.magenta, "foo", $ansi.cyan, "bar", $ansi.reset);

Nostalgia.

#### $root
If an object doesn't have a clear ancestor it should be created from root:

    ;create($root);
    => #123;

### Prototypical
#### $action
This is mostly a placeholder object (and *tag* for action objects) to hold some documentation.

#### $actor
This object contains the prototypical *action queue* implemenation that originates from the `hellcore.db` database (it's simplified and tweaked though).

#### $creature
This is an important proto that will eventuall support a lot of behavior that is important for gaming purposes.

#### $player
This proto deals mostly with user preferences and supports the basic behavior for players to be functional in the world.

#### $room
This proto is mostly responsible for describing the environment to its users.

#### $thing
There's a lot of random *things* in the world. If you are creating something not very significant, it's better to `create($thing)` than to `create($root)`. At the very least it makes it a lot easier to keep track of all the objects that *will* appear and their importance.

### Utils
Utils are orthogonally useful in variety of ways. A typical utility method is *pure* (it doesn't mess with shared state), gives a result based on its inputs (and **only** its inputs) and doesn't change its inputs either.

> In some other languages there's the concept of a `static` method. Things that would be *publically* `static` would probably be suitable for a utils class. The concept of `static` doesn't exist in **LambdaMOO** though we can easily *fake* it.

#### $english_utils
A set of utilities that help dealing with the English language.

#### $string_utils
A set of utilities that help dealing with strings.

### Libraries
#### $actions
Every action should be registered with this object as a *property* so that it is easy to lookup and queue. This is mostly a placeholder object for some general help.

### FAQ
#### I'm a programmer and my `;` doesn't seem to be working
Your client might be *eating* (using) `;` as a command separator and thus it's not being send to the server. This causes the server to be confuzzled while trying to interpret your commands.

Look into your client settings. In **Mudlet** it's called "command separator" and by default it's set to `;` which causes a lot of problems for MOO type games. I usually set it to `|||` because if you're programming you probably don't need the command seperation from the client side anyway.