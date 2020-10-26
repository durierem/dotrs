# ![Image](https://img.tedomum.net/data/dotrs_logo_32-b1fd1b.png) Dotrs

*Straightforward dotfiles management*

## What does dotrs do?

Dotrs uses a hidden git repository, placed in your `$HOME` folder to store
the dotfiles you want to keep synchronized. Then it creates links to them in
your file system at the right location.

## Installation

Dotrs is installed as a Ruby gem. To install dotrs, use the following commands:

```
$ git clone https://github.com/Sevodric/dotrs && cd dotrs
$ gem build dotrs.gemspec
$ gem install dotrs
```

## Setup

Dotrs needs a remote repository for managing your dotfiles. Create an empty one
on GitHub (or other) if you don't already have one. Afterward, use the following
command to initialize dotrs:

`$ dotrs init REMOTE-URL`

## Usage

The following is an overview of the basic workflow with Dotrs.
For an exhaustive list of available commands and their options, see

`$ dotrs --help`

### Workflow

Add files and save changes:

```
$ dotrs add ~/.bashrc   // Add ~/.bashrc to the local repository
$ dotrs push            // Push local changes
```

Get informations about tracked files:

```
$ dotrs list            // Check which files are currently tracked
$ dotrs list --tree     // Show the files in a tree-like structure
$ dotrs diff            // Similar to git diff
$ dotrs diff --short    // Show file names only
```

Retrive new changes:

```
$ dotrs pull            // Pull last changes from the remote repository
$ dotrs apply           // Link all tracked files to their location
```
