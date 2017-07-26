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