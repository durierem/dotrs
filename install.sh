#!/usr/bin/bash

# install.sh: install dotrs:
#   - if the option '--local' is active, dotrs is installed in '$HOME/.local/'.
#   Otherwise, the script requires escalated privileges and installs dotrs
#   in '/usr/local/'.
#   - any previous installation will be removed before installing the new one.

exit_failure() {
  echo 'An error occured while installing.'
  exit 1
}

# Determine the installation mode
if [[ $1 == '--local' ]]; then
  privileged=0
else
  if [[ $EUID -ne 0 ]]; then
    echo 'Error: this script requires root privileges to install dotrs.'
    echo 'Run with sudo or use --local.'
    exit 1
  fi
  privileged=1
fi

# Determine the installation directories
if [[ $privileged -eq 1 ]]; then
  srcdir=/usr/local/src/dotrs
  bindir=/usr/local/bin
else
  srcdir=$HOME/.local/src/dotrs
  bindir=$HOME/.local/bin
fi

# Source files and binary to create
src=(*.rb src/ LICENSE)   # All source files
mainsrc=dotrs.rb          # Entry point of the program
bin=dotrs                 # Name of the binary
binpath=$bindir/$bin      # Full path to binary

# Remove potential previous installation
if [[ -d $srcdir ]]; then
  echo -n 'Removing previous installation...'
  rm -r "$srcdir" || exit_failure
  rm "$binpath" || exit_failure
  echo 'done'
fi

# Create installation directories if they do not exist.
if [[ ! -d $srcdir ]]; then
  mkdir -p "$srcdir" || exit_failure
fi
if [[ ! -d $bindir ]]; then
  mkdir -p "$bindir" || exit_failure
fi

# Copy source files to their destination
echo -n 'Copying files...'
for file in "${src[@]}"; do
  cp -r "$file" "$srcdir/$file" || exit_failure
done
echo 'done'

# Make the executable
echo -n 'Creating executable...'
chmod +x "$srcdir"/"$mainsrc" || exit_failure
ln -s "$srcdir"/"$mainsrc" "$binpath" || exit_failure
echo 'done'

echo 'Installation completed.'
