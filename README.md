# dotrs

*Straightforward dotfiles management*

## What does dotrs do?

dotrs uses a hidden git repository, placed in your `$HOME` folder to store a copy of the dotfiles you want to keep synchronized.

The goal here is to provide a way of managing your dotfiles with a git hosting service such as GitHub without the mess created by other common solutions (`$HOME` folder as a git repository or use of soft links to the actual files).

## Installation

To install dotrs system-wide in `/usr/bin/` :

`sudo sh install.sh`

To install dotrs locally in `$HOME/.local/bin/` (without root access) :

`sh install.sh --local`

## Setup

dotrs needs a remote repository for managing your dotfiles. Create an empty one on GitHub (or other) if you don't already have one. Use the following command to initialize dotrs :

`dotrs init REMOTE-URL`

## Usage

`dotrs add [OPTION]... FILE...`
`dotrs remove [OPTION]... FILE...`
`dotrs save [OPTION]... [--copy-only | --push-only]`
`dotrs apply [OPTION]... [--pull-only | --copy-only]`

Use the `add`/`remove` commands to add/remove files from the local repository. This will cause dotrs to keep/lose track of a specific file.

Use the `save` command to copy all tracked files to the local repository and push it to the remote one. You can use the `--copy-only` or `--push-only` options to perform either one of these actions individually.

Use the `apply` command to pull the latest changes from the remote repository and replace all your currently tracked dotfiles by the new ones. Similarly to the `save` command, you can also use `--pull-only` or `--copy-only`.

All these commands can be flagged with `-v` or `--verbose` to print out what is being done.
