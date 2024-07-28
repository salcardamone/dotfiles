#!/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir=~/.dotfiles_backup

mkdir -p $backup_dir
cd $dir

files="emacs.d"

for file in $files; do
    if [ -e ~/.$file ]; then
	if [ -e $backup_dir/.$file ]; then
	    echo "Backup for $file already exists. Removing $backup_dir/.$file"
	    rm -rf $backup_dir/.$file
	fi
	echo "Moving existing .$file dotfiles from /home/$USER to $backup_dir"
	cp -Lr ~/.$file $backup_dir
	rm -rf ~/.$file
    fi
    echo "Creating symlink to $dir/$file in /home/$USER/.$file"
    ln -s $dir/$file ~/.$file
done
