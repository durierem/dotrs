# ![Image](https://img.tedomum.net/data/dotrs_logo_32-b1fd1b.png) dotrs

*Straightforward dotfiles management*

## What does dotrs do?

dotrs uses a hidden git repository, placed in your `$HOME` folder to store a
copy of the dotfiles you want to keep synchronized.

The goal here is to provide a way of managing your dotfiles with a git hosting
service such as GitHub without the mess created by other common solutions
(`$HOME` folder as a git repository or use of soft links to the actual files).

## Installation

To install dotrs system-wide:

`$ sudo bash install.sh`

To install dotrs locally (without root access):

`$ bash install.sh --local`

## Setup

dotrs needs a remote repository for managing your dotfiles. Create an empty one
on GitHub (or other) if you don't already have one. Use the following command to
initialize dotrs :

`$ dotrs init REMOTE-URL`

## Usage

### Adding files and saving changes

Add a file to the source repository with the `add` command. This will cause
dotrs to keep track of the file:

`$ dotrs add ~/.bashrc`

Similarly, use `remove` to stop dotrs from tracking a file.

Once files have been added or modified, save the changes with:

`$ dotrs save`

It will copy all the tracked files to the source repository and push to remote.

### Retrieving files and applying

To pull the latest changes from the remote repository and replace all your
currently tracked files, simply use:

`$ dotrs apply`

### Checking for tracked files

Use the `list` command to view all currently tracked files.
