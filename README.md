# ![Image](https://img.tedomum.net/data/dotrs_logo_32-b1fd1b.png) Dotrs

![GitHub](https://img.shields.io/github/license/durierem/dotrs)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/durierem/dotrs)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![Inline docs](http://inch-ci.org/github/durierem/dotrs.svg?branch=master)](http://inch-ci.org/github/durierem/dotrs)

*Straightforward dotfiles management*

## What does Dotrs do?

Dotrs uses a hidden git repository, placed in your `$HOME` directory to store
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
command to initialize Dotrs:

`$ dotrs init REMOTE-URL`

## Usage

The following is an overview of the basic workflow with Dotrs.
For an exhaustive list of available commands and their options, see the
`--help` option.

### Workflow

Add files and save changes:

```
$ dotrs add ~/.bashrc   // Add ~/.bashrc to the local repository
$ dotrs push            // Push local changes
```

Get informations about tracked files:

```
$ dotrs list            // Check which files are currently tracked
$ dotrs diff            // Similar to git diff
```

Retrieve new changes:

```
$ dotrs pull            // Pull last changes from the remote repository
$ dotrs apply           // Link all tracked files to their location
```

### Commit messages

Dotrs adds pretty commit messages to help you find out what changed and when.

Sample, taken from my own dotfiles repository:

```
dotrs: push from 'aegolius'

Added:
	.config/kitty/gruvbox-dark-base.conf
	.config/kitty/gruvbox-dark-soft.conf

Changed:
	.config/fish/config.fish
	.config/kitty/gruvbox-dark-medium.conf
	.config/kitty/kitty.conf
	.config/nvim/init.vim

Deleted:
	.vimrc
```
