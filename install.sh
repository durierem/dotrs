#!/usr/bin/bash

# install.sh: install dotrs:
#   - if the option '--local' is active, dotrs is installed in '$HOME/.local/'.
#   Otherwise, the script requires escalated privileges and installs dotrs
#   in '/usr/local/'.
#   - any previous inststallation will be removed before installing the new one.

# ------------------------------------------------------------------------------

# exit_on_error: exit with exit code 1 if the previous command has gone wrong.
exit_on_error () {
  if [[ $? -ne 0 ]]; then
    echo 'An error occured while installing :('
    exit 1
  fi
}

# Determine the installation mode
if [[ $1 == '--local' ]]; then
  privileged=false
else
  if [[ $EUID -ne 0 ]]; then
    echo 'Error: this script requires root privileges to install dotrs.'
    echo 'Run with sudo or use `--local`.'
    exit 1
  fi
  privileged=true
fi

# Determine the installation directories
if [[ $privileged ]]; then
  srcdir=/usr/local/src/dotrs
  bindir=/usr/local/bin
else
  srcdir=$HOME/.local/src/dotrs
  bindir=$HOME/.local/bin
fi

# Source files and binary to create
src=(*.rb src LICENSE)
bin=dotrs
binpath=$bindir/$bin

# Remove potential previous installation
if [[ -d $srcdir ]]; then
  echo -n 'Removing previous installation...'
  rm -r $srcdir
  rm $binpath
  exit_on_error
  echo 'done'
fi

# Create installation directories if they do not exist.
if [[ ! -d $srcdir ]]; then
  mkdir -p $srcdir
  exit_on_error
fi
if [[ ! -d $bindir ]]; then
  mkdir -p $bindir
  exit_on_error
fi

# Copy source files to their destination
echo -n 'Copying files...'
for file in ${src[@]}; do
  cp -r $file $srcdir/$file
  exit_on_error
done
echo 'done'

# Make the executable
chmod +x $srcdir/dotrs.rb
ln -s $srcdir/dotrs.rb $binpath
exit_on_error

echo 'Installation completed.'
