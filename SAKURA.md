## Sakura
This aims to be a complete guide to **Sakura**. 

This describes the **0.1** version of the **Sakura** database. You can inspect your database version by querying `$kernel.version` using the `eval` verb:

    ;$kernel.version
    => "0.1"

## Getting started (with minimal)
## Getting started (with sakura)
## Programming

## Reference
### Core
#### eval
Our basic `eval` method setup in the "The First Room". You might seriously want to consider changing this but *do make a backup* and think well before you do.

The `eval` method is essiental for doing any kind of low-level programming while we're still building the game. Most people use the *eval shortcut* `;` instead though. 

So: `eval 3 + 2` is equivalent to `;3 + 2`.

The `eval` verb is not limited to evaluating expressions though. It can maniupalate the MOO with all the rights you've been granted with. You can `add_verb`, `add_property`, `chowner` and who knows what if you have the right authorization.

#### $ansi
This has the ANSI codes to make fancy colors appear on terminal devices that support it.

> On devices that don't support this we'll be probably outputting garbage since we don't have any devices in place to strip the color codes from the output.

Here's the current list of display codes defined on the `$ansi` object:

##### Control
* `esc` (the ANSI escape character)
* `reset` (reset to default terminal style)
* `bold_on` (turn on bold or highlight)
* `bold_off` (turn off bold or highlight)

##### Foreground
* `black`
* `red`
* `green`
* `yellow`
* `blue`
* `magenta`
* `cyan`
* `white`

##### Background
* `black_bg`
* `red_bg`'
* `green_bg`
* `yellow_bg`
* `blue_bg`
* `magenta_bg`
* `cyan_bg`
* `white_bg`

You can also just inspect the properties on the `$ansi` object itself in case you forget:

    ;properties($ansi)
    => {"esc", "reset", "bold_on", "bold_off", "black", "red", "green", "yellow",
     "blue", "magenta", "cyan", "white", "black_bg", "red_bg", "green_bg", 
     "yellow_bg", "blue_bg", "magenta_bg", "cyan_bg", "white_bg"}

If you want to use these codes it's pretty easy, for example:

    ;player:tell($ansi.magenta, "foo", $ansi.cyan, "bar", $ansi.reset);

Nostalgia.

#### $kernel
TODO

#### $root
If an object doesn't have a clear ancestor it should be created from root:

    ;create($root);
    => #123;

The `$root` object has some convenient naming verbs:

    ;create($root);
    => #123
    
    ;#123.name = "flurb";
    => 0
    
    ;#123:dname();
    => "the flurb"
    
    ;#123:iname();
    => "a flurb"

    ;#123.name = "urghard";
    => 0

    ;#123:iname()
    => "an urghard";
    
    ;#123:dname()
    => "the urghard";

    ;#123:name();
    => "urghard";
    
    ;#123:title();
    => "urghard";    

There's also capitalized versions availabe in the form of `dnamec`, `inamec` etc. And all of these `*name` verbs are also opportunities for any child objects to override behaviour of those verbs. The core implementations are basically mostly stubs and are meant to be overridden in more specialized objects.

### Prototypical
#### $action
This is mostly a placeholder object (and *tag* for action objects) to hold some documentation.

#### $actor
This object contains the prototypical *action queue* implemenation that originates from the `hellcore.db` database (it's simplified and tweaked though).

#### $creature
This is an important proto that (will eventually) support(s) a lot of behavior that is important for gaming purposes.

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

### Action queue
Although this is mostly just some verbs on the `$actor` class it's useful to discuss this framework separately.

### Libraries
#### $actions
Every action should be registered with this object as a *property* so that it is easy to lookup and queue. This is mostly a placeholder object for some general help as well as the **main place** where all public actions can be found.

> Every public action should be defined as a readable property on the `$actions` object.

### FAQ
#### I'm a programmer and my `;` doesn't seem to be working
Your client might be *eating* (using) `;` as a command separator and thus it's not being send to the server. This causes the server to be confuzzled while trying to interpret your commands.

Look into your client settings. In **Mudlet** it's called "command separator" and by default it's set to `;` which causes a lot of problems for MOO type games. I usually set it to `|||` because if you're programming you probably don't need the command seperation from the client side anyway.