# Nixos Update

We are using flakes in NixOS so we periodically will need to "`nix flake update`" to ensure apps don't break.

In general the process is as follows:

1. Create a new branch
2. Run "`nix flake update`"
3. Add to branch and commit
4. Run "`nixos-rebuild switch`"
5. Reboot
6. Merge branch to master

Detailed steps below.

## Create New Branch

Go to `~/nixos-mitsuki`. This is the repo for this nix configuration for Mitsuki.

You can either open VSCode and create a branch there or in nixos-mitsuki run: `git branch flake-update-<yyyymmdd>` 

```bash
git branch flake-update-20260606
git switch flake-update-20260606
```

This will create the branch "`flake-update-20260606`" and switch to it. Now we can make changes to the config and update the flake.

## nix flake update

We need to update the flake next using "`nix flake update`". I have an alias to do this "`nfu`", however the full command is below

```bash
nix flake update --flake /home/sentinel/nixos-mitsuki
```

This will pull updated packages into the `flake.nix`.

We should then add and commit the changes to the branch

```
git add .
git commit -m "flake update 20260606"
```

## nixos-rebuild switch

After the flake has been updated we need to rebuild NixOS which will download and install all the package updates. It's at this stage some errors may be thrown during the rebuild and you may need to modify `configuration.nix` if there are packages that need exclusion or special parameters.

To kick off the rebuild I have an alias "`nxr`".

```bash
sudo nixos-rebuild --impure switch --flake /home/sentinel/nixos-mitsuki#mitsuki
```

If there are no more errors to resolve we can reboot.

## Reboot and Merge Branch

```bash
reboot
```

Once rebooted, if we are happy with the update, we can merge the new configuration to the master branch. 

```bash
git switch master
git merge flake-update-20260606
git push
```

This will switch to the `master` branch and merge all the changes from `flake-update-20260606` and push it to the remote repo on github.

### Rollback

If we want to rollback, it may be possible by switching back to the master branch and `nixos-rebuild switch` again on the old version of the configuration.

```bash
git switch master
nxr
reboot
```

