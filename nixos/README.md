After nixos installation and config files in place, run the `../install-new-desktop.sh` script to put in place all the config files (vim,nvim,tmux,i3,etc)

Go back to a previous generation:
```
# list stored generations
sudo nixos-rebuild list-generations

# go to generation number 42
sudo nix-env --switch-generation 42 -p /nix/var/nix/profiles/system

# use it
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch

# go back to the latest generation (suppose is 84)
sudo nix-env --switch-generation 82 -p /nix/var/nix/profiles/system

# to quickly go back just one step:
sudo nixos-rebuild rollback
```

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
