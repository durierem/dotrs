# [![Image](https://img.tedomum.net/data/thumb/dotrs_logo_144-6252ff.png)](https://img.tedomum.net/data/dotrs_logo_144-6252ff.png) dotrs

*Straightforward dotfiles management*

## What does dotrs do?

dotrs uses a hidden git repository, placed in your `$HOME` folder to store a
copy of the dotfiles you want to keep synchronized.

The goal here is to provide a way of managing your dotfiles with a git hosting
service such as GitHub without the mess created by other common solutions
(`$HOME` folder as a git repository or use of soft links to the actual files).

## Installation

To install dotrs system-wide in `/usr/bin/` :

`sudo sh install.sh`

To install dotrs locally in `$HOME/.local/bin/` (without root access) :

`sh install.sh --local`

## Setup

dotrs needs a remote repository for managing your dotfiles. Create an empty one
on GitHub (or other) if you don't already have one. Use the following command to
initialize dotrs :

`$ dotrs --init REMOTE-URL`

## Usage

### Adding files and saving changes

Add a file to the local repository with `--add` (`-a`). This will cause dotrs
to keep track of the file:

`$ dotrs --add ~/.bashrc`

Similarly, use `--remove` (`-r`) to stop dotrs from tracking a file.

Once files have been added or modified, save the changes with:

`$ dotrs --save`

It will copy all the tracked files to the local repository and push to remote.

### Retrieving all files

To pull the latest changes from the remote repository and replace all your
currently tracked files, simply use:

`$ dotrs --apply`

### Checking for tracked files

Use `--list` (`-l`) to view all currently tracked files.
