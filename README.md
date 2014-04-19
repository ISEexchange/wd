## Overview

This program acts as a watchdog timer to start other programs.
The other program must finish within a configurable timeout or
else the other program is killed.

It has been tested on Fedora, RHEL, and Mac OS X.
The source compiles without change on each of these OS's.

## Building

You need EiffelStudio to build this.
I use the GPL version available from http://www.eiffelstudio.com

See eiffelstudio.md for instructions if you want to install
EiffelStudio locally on Linux or Mac OSX.

### Use docker to build wd

The easiest way to use EiffelStudio on Linux is via Docker containers.
See http://www.docker.io/gettingstarted/ for tips.

Run the [EiffelStudio docker container](https://index.docker.io/u/jumanjiman/eiffelstudio/).
When you first run the container, docker will download it.
Subsequent startups are almost instantaneous.

    sudo docker run -i -t -v /tmp:/tmp jumanjiman/eiffelstudio 

For a more complete dev environment that still includes EiffelStudio,
try https://index.docker.io/u/jumanjiman/wormhole/

Clone this repo and build with tito...

    bash-4.2$ git clone https://github.com/jumanjiman/wd.git
    Cloning into 'wd'...
    remote: Counting objects: 75, done.
    remote: Compressing objects: 100% (42/42), done.
    remote: Total 75 (delta 27), reused 74 (delta 26)
    Unpacking objects: 100% (75/75), done.

    bash-4.2$ cd wd

    bash-4.2$ tito build --rpm
    Creating output directory: /tmp/tito
    -snip-
    Successfully built: /tmp/tito/wd-0.9-3.fc19.src.rpm /tmp/tito/x86_64/wd-0.9-3.fc19.x86_64.rpm /tmp/tito/x86_64/wd-debuginfo-0.9-3.fc19.x86_64.rpm

...or build `wd` from the command-line using the provided `Makefile`

    make finalize
