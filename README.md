# Recording terminal demos

This repo contains scripts for Project Calico demos.

Recording these demos isn't trivial because the actions is happening across multiple hosts.

It's based around a couple of useful pieces of technology
* "Docker in Docker" - to simulate multiple hosts
* tmux to show the connections to both hosts in a single terminal

Running these demos is based around a Makefile. 

## Workflow
* `make create-hosts` - Creates the DinD hosts and sets them up for running Calico
* `make create-tmux` - Creates a `tmux` session with two panes. They are connected to the two DinD hosts
* `make attach` - Attaches to the tmux session.

These can be chained together - `make create-hosts create-tmux attach`

`make create-hosts` can be slow (it has to load the calico-node images onto the hosts), so instead use `make clean-hosts`
* `make create-hosts create-tmux attach`

## Recording demos
The demos can be recorded using one of the many terminal recording programs that are available. Asciinema is a very good option.

In one terminal run

  make clean-hosts create-tmux resize
  asciinema rec -y -c "tmux a" -t "Calico and libnetwork" libnetwork
  
Then in another run

  ./libnetwork-demo.sh

### Playback of recordings
`asciinema play libnetwork`
### Uploading demos
`asciinema upload libnetwork`


## Converting to gif
See https://github.com/tomdee/asciinema2gif

These instructions are based around asciinema - it provides a way to record terminal sessions and store those recordings in a machine (and human-ish) readable format.

Using asciinema solves _most_ of the problem. This repo helps to solve the other parts.

Ensuring a consistent terminal size is used
Handling recordings of multiple windows
Providing a way of scripting recordings
Providing the recordings in multiple output formats.

Before recording, run `resize -s 30 120` to set your terminal size.



