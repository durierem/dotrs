#!/usr/bin/bash

#   - If the option '--local' is active, the program is installed under
#   '$HOME/.local/'. Otherwise, this script requires escalated privileges and
#   installs the program under '/usr/local/'.
#   - Any previous installation will be removed before installing the new one.
#   - Across this script, the so called 'binary' is a simple soft link to the
#   entry file of the program.

# --- CONFIGURATION

# Program configuration
src=(*.rb src/* LICENSE)  # All source files
mainsrc=dotrs.rb          # Entry point of the program
bin=dotrs                 # Name of the binary
name=$bin                 # Name of the program (the source files will be copied
                          # under a directory of the same name)

# Determine the installation mode
if [[ $1 == '--local' ]]; then
  privileged=0
else
  if [[ $EUID -ne 0 ]]; then
    echo "$0: this script requires root privileges to install dotrs."
    echo "Run with sudo or use --local."
    exit 1
  fi
  privileged=1
fi

# Determine the installation directories
if [[ $privileged -eq 1 ]]; then
  srcdir=/usr/local/src/$name
  bindir=/usr/local/bin
else
  srcdir=$HOME/.local/src/$name
  bindir=$HOME/.local/bin
fi
binpath=$bindir/$bin

# --- INSTALLATION

# exit_failure: exit the program with an error message.
#   This function is made to be used as a test condition to check the return
#   status of a command
exit_failure() {
  echo "$0: an error occured while installing."
  exit 1
}

# Remove potential previous installation
echo -n "$0: removing any previous installation... "
if [[ -d $srcdir ]]; then
  rm -r "$srcdir" || exit_failure
fi
if [[ -h $binpath ]]; then
  rm "$binpath" || exit_failure
fi
echo 'done'

# Create installation directories if they do not exist
if [[ ! -d $srcdir ]]; then
  mkdir -p "$srcdir" || exit_failure
fi
if [[ ! -d $bindir ]]; then
  mkdir -p "$bindir" || exit_failure
fi

# Copy source files to their destination
echo -n "$0: copying files... "
for file in "${src[@]}"; do
  cp --parent "$file" "$srcdir" || exit_failure
done
echo 'done'

# Make the executable
echo -n "$0: creating executable... "
chmod +x "$srcdir"/"$mainsrc" || exit_failure
ln -s "$srcdir"/"$mainsrc" "$binpath" || exit_failure
echo 'done'

echo "$0: installation of $name completed."
