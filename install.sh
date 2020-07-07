#!/usr/bin/bash

echo "Installing dotrs..."

if [[ $1 == "--local" ]]; then
  bin_dir=$HOME/.local/bin
  mkdir -p $bin_dir
else
  if [[ $EUID -ne 0 ]]; then
    echo "Error: this script requires root privileges to install dotrs."
    echo "Run with sudo or use '--local'."
    exit 1
  fi
  bin_dir=/usr/bin
fi

lib_dir=$HOME/.local/share/dotrs
mkdir -p $lib_dir
cp *.rb $lib_dir
chmod +x $lib_dir/dotrs.rb
ln -s $lib_dir/dotrs.rb $bin_dir/dotrs
echo "dotrs has been installed."
