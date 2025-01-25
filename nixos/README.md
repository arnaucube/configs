After nixos installation and config files in place, run the `../install-new-desktop.sh` script to put in place all the config files (vim,nvim,tmux,i3,etc)


From time to time run the following commands to remove stuff from old generations
```
# list old generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# remove old generations
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations 9 10 11 12 13 X...

# remove old generations except the last 5 generations
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5


# update
`sudo nix-channel --update`
`sudo nixos-rebuild switch`

# to remove old programs
nix-collect-garbage --delete-old
```

When stting up the config files in a system, remember to rename either the file `thinkpad-configuration.nix` or `surface-configuration.nix` files into `configuration.nix`.
