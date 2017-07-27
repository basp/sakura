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
Utils are orthogonally useful in variety of ways. A typical utility method is *pure* (it doesn't mess with state). In some other languages there's the concept of a `static` method. Things that would be *publically* `static` would probably be suitable for a utils class. 

> The concept of `static` doesn't exist in **LambdaMOO** though.

#### $english_utils
A set of utilities that help dealing with the English language.

#### $string_utils
A set of utilities that help dealing with strings.

### Libraries
#### $actions
Every action should be registered with this object as a *property* so that it is easy to lookup and queue. This is mostly a placeholder object for some general help.