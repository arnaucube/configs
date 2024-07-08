from time to time run the following commands to remove stuff from old generations
```
# list old generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# remove old generations
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations 9 10 11 12 13 X...


# to remove old programs
nix-collect-garbage --delete-old
```
