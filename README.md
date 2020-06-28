# Dotsync

Straightforward dotfiles management

### How does it work?

TODO: scheme

Dotsync uses a hidden `.dotfiles` git repository in your `$HOME` folder. This
softwate makes it easy to add, remove, and synchronize files.

### Usage

Initialize dotsync with an already existing dotfiles repository (create an
empty one if you don't already have one):
`dotsync init REMOTE-REPOSITORY`


Add a file to `.dotfiles`:
`dotsync add FILE`

Remove a file from `.dotfiles`:
`dotsync remove FILE`

Copy files from `.dotfiles` to their respective location:
`dotsync apply`

Copy files from their original location to `.dotfiles`:
`dotsync save`

Get latest changes to the dotfiles and update them:
`dotsync update`
