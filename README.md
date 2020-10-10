# ![Image](https://img.tedomum.net/data/dotrs_logo_32-b1fd1b.png) dotrs

*Straightforward dotfiles management*

## What does dotrs do?

dotrs uses a hidden git repository, placed in your `$HOME` folder to store
the dotfiles you want to keep synchronized. Then it creates links to them in
your file system at the right location.

## Installation

dotrs is installed as a Ruby gem. To install dotrs, use the following commands:

```
git clone https://github.com/Sevodric/dotrs && cd dotrs
gem build dotrs.gemspec
gem install dotrs
```

## Setup

dotrs needs a remote repository for managing your dotfiles. Create an empty one
on GitHub (or other) if you don't already have one. Afterward, use the following
command to initialize dotrs :

`$ dotrs init REMOTE-URL`

## Usage

### Adding files and saving changes

Add a file to the source repository with the `add` command. This will cause
dotrs to keep track of the file:

`$ dotrs add ~/.bashrc`

Similarly, use `remove` to stop dotrs from tracking a file.

Once files have been added or modified, save the changes with:

`$ dotrs push`

### Retrieving changes

Get the last changes from the remove:

`$ dotrs pull`

Link any new missing file with:

`$ dotrs apply`

### Checking for tracked files

Use the `list` command to view all currently tracked files.
