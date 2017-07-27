## Sakura
The central repository for both the **Sakura** `Dockerfile` (to build a development image) and the *current* database required to bootstrap your environment.

## Why?
You will only need this if you are on Windows and wanna do some local MOO hacking without relying on a machine in the cloud. This `Dockerfile` should compile a Docker image that you can boot up to start hacking on a variety of MOO databases straightaway.

## Prerequisites
Either [Docker for Windows](https://www.docker.com/docker-windows) or [Docker Toolbox](https://www.docker.com/products/docker-toolbox).

## Getting started
After cloning this repo somewhere you'll end up with `Dockerfile` and this is the thing that contains all the instructions on how to build your development container.

You'll need to build the container first. Make sure to give it a tag that you can remember:

    docker build -t your_repo:and_tag .

If you execute this from the `sakura` repo directory that you just cloned, it will compile the container. After it's done building the image you can make sure it's actually there:

    docker image list

And you should see the `your_repo:and_tag` image in the list of images. 

As this is supposed to be a development container it's expected that you'll launch it interactively. Also, we need to make sure to map the *exposed* 7999 port to the container's host, in this case we'll map port 7999 from the container to port 4000 on the host operating system:

    docker run -it -p 4000:7999 your_repo:and_tag /bin/bash

> As an aside, in the command above, the `i` and `t` flags we are gonna run this container in interactive mode and with a **tty** (terminal attached) attached.j The `p` flag is our port mapping. Finally we specify the `repository:tag` image to run and the main command (in this case we startup `bash` the prototypical command-line executable on Ubuntu).

This should bring you into Ubuntu and you should've ended up in the `/app` directory. From here we can launch the MOO:

    ./moo database.db database.db.new &

You'll have to substitute `database.db` with any of the available `.db` files in the `/app` directory though.

## Testing it out
The best way to test it out is to install a so called "MUD Client", I recommend [Mudlet](https://www.mudlet.org/) but there are alternatives. You could also try `telnet` if you're comfortable with that. On *nx based systems `nc` works great as well.

    > nc 127.0.0.1 4000
    ** connected **

If you get the `**connected**` response you're good to go. What you can do at this point depends on the database you're using.

## Sakura database
If you load the `sakura.db` database:

    ./mooo sakura.db sakura.db.new

Then there will be some things already implemented. The most basic thing you could try is:

    ;3 + 2
    => 5

By typing `;` you'll invoke the eval command. It's the same as typing:

    eval 3 + 2

The `=>` is the result of the expression you *evaluated*. When evaluating a statement (or command) such as `notify` it will often be `0` which means there wasn't a real result (equivalent to `void` in imperative and `unit` in function programming languages).

### Action queue
One of the core concepts that we wanna get right is the *action queue*. This is a concept that is very well implemented in HellMOO and as for gameplay, it offers a lot of oppurtunities.

Currently we have a very rudimentary action queue implementation. The prototypical object is implemented as `$actor` and its public API is pretty simple (so far).

You can invoke `$actor:queue_action(spec)` to add an action to any actors `action_queue`. If that actor is not already processing it's `action_queue` it will start to do so immediately.

#### Example
Say you just compiled the container and got the `**connected**` prompt.. What now?

First see if this secnario works:

    ;3 + 2
    => 5

So you type `;3 + 2` (including the `;`) and the system responds with `=> 5`. If you got that working then you are good to go.

Now, as far as the **action queue** goes, we don't actually push actions but we push so called *action specs* onto the queue. An *action spec* is basically a `{action, args, description}` tuple.

Now we could use the `$actor` object directly:

    ;$actor:queue_action({$actions.foo, [], "foo"});

Which would work but we can also do a bit better by creating a new `$actor` object:

    ;create($actor);
    => #12

Your response will vary because we're creating a new object here. The result we get back is the new object id, in the example above it's `#12` but it's very likely you got a different number.

What we just did is create a new object with the characteristics of the `$actor` object but we can play with it without worrying about messing up the prototypical `$actor` itself.

So with that new object (`#12`) we can try out the action qaueue. Remember, we need to queue *specs* and not actions so:

    ;#12:queue_action({$actions.foo, [], "foo"});

And you should see some output about starting and stopping fooing.

If you queue a lot of actions they will *stack* as if it really was a queue. For now, and for development purposes you can pretty easily cancel a whole queue by calling the `stop` verb:

    ;#12:stop();

And that will cancel the execution of the current action as well as any actions queued up in the queue. If you're done playing with that actor object it's good practice to `recycle` it:

    ;recycle(#12);

This will free up some space on disk as well as in memory.

## TODO
* Long actions, continue the same action over and over.
* (Or perhaps) continue from one action into the next.
* Smooth output on continuations (e.g. "You continue...")