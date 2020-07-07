#!/usr/bin/bash

echo "Installing dotrs..."

if [[ $1 == "--local" ]]; then
  bin_dir=$HOME/.local/bin
  lib_dir=$HOME/.local/share/dotrs
  mkdir -p $bin_dir
  mkdir -p $lib_dir
else
  if [[ $EUID -ne 0 ]]; then
    echo "Error: this script requires root privileges to install dotrs."
    echo "Run with sudo or use '--local'."
    exit 1
  fi
  bin_dir=/usr/bin
  lib_dir=/usr/lib/dotrs
  mkdir -p $lib_dir
fi

cp *.rb $lib_dir
chmod +x $lib_dir/dotrs.rb
ln -s $lib_dir/dotrs.rb $bin_dir/dotrs
echo "dotrs has been installed."
