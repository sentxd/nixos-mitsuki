# Kopia home snapshots

Kopia snapshots `/home/sentinel` to an encrypted filesystem repository at
`/mnt/sara/sentinel/Kopia/mitsuki`. The destination is inside the existing NFS
automount. The hourly system service runs as `sentinel` and is skipped until
both the local password file and Kopia connection configuration exist.

The repository password is not managed by Nix. Keep a separate copy in a
password manager: losing it makes the snapshots unrecoverable.

## Apply the configuration

Build first, then switch only after reviewing the result:

```bash
sudo nixos-rebuild --impure build --flake /home/sentinel/nixos-mitsuki#mitsuki
sudo nixos-rebuild --impure switch --flake /home/sentinel/nixos-mitsuki#mitsuki
```

Create the root-readable environment file and enter one line in systemd
environment-file syntax, for example `KOPIA_PASSWORD='a long unique password'`:

```bash
sudo install -d -m 0700 /var/lib/kopia
sudo touch /var/lib/kopia/backup.env
sudo chmod 0600 /var/lib/kopia/backup.env
sudoedit /var/lib/kopia/backup.env
```

## Initialize or connect

These steps intentionally are not automated. Before initializing, inspect the
destination and connect instead if it already contains a Kopia repository:

```bash
ls -la /mnt/sara/sentinel/Kopia/mitsuki
```

Open a root shell, load the password, and define a helper that runs Kopia as
the owner of the files being backed up:

```bash
sudo -i
set -a
. /var/lib/kopia/backup.env
set +a
kopia-home() {
  sudo -u sentinel env \
    HOME=/home/sentinel \
    KOPIA_CONFIG_PATH=/home/sentinel/.config/kopia/repository.config \
    KOPIA_PASSWORD="$KOPIA_PASSWORD" \
    /run/current-system/sw/bin/kopia "$@"
}
```

For a new repository only, create the destination and initialize it. Do not run
this command over an existing repository:

```bash
install -d -o sentinel -g users /mnt/sara/sentinel/Kopia/mitsuki
kopia-home --no-persist-credentials repository create filesystem \
  --path=/mnt/sara/sentinel/Kopia/mitsuki
```

For an existing repository, connect without persisting its password:

```bash
kopia-home --no-persist-credentials repository connect filesystem \
  --path=/mnt/sara/sentinel/Kopia/mitsuki
```

Set and inspect the retention policy. Disabling `latest` and `annual` avoids
retaining additional snapshots beyond the requested categories:

```bash
kopia-home policy set /home/sentinel \
  --keep-latest=0 \
  --keep-hourly=24 \
  --keep-daily=14 \
  --keep-weekly=8 \
  --keep-monthly=12 \
  --keep-annual=0
kopia-home policy show /home/sentinel
```

Exit the root shell when setup is complete:

```bash
unset KOPIA_PASSWORD
exit
```

## Operate and restore

Take an initial snapshot and inspect timer status:

```bash
sudo systemctl start kopia-home-snapshot.service
systemctl status kopia-home-snapshot.service
systemctl list-timers kopia-home-snapshot.timer
```

For commands that read the repository, recreate the `kopia-home` helper from
the setup section. List snapshots and their IDs:

```bash
kopia-home snapshot list /home/sentinel --manifest-id
```

Restore the latest version of a file or directory to a separate location:

```bash
kopia-home snapshot restore \
  /home/sentinel/Documents/example \
  /home/sentinel/Restore/example
```

Use the root object ID shown by `snapshot list` to restore from one exact
snapshot:

```bash
kopia-home snapshot restore kROOT_OBJECT_ID/Documents/example \
  /home/sentinel/Restore/example
```

Check snapshot structure and referenced storage, then optionally download,
decrypt, and verify all file contents. The full check can be expensive:

```bash
kopia-home snapshot verify
kopia-home snapshot verify --verify-files-percent=100
```

Inspect recent automated runs with:

```bash
journalctl -u kopia-home-snapshot.service
```

KopiaUI is installed as `kopia-ui`. It may be connected interactively using
the same repository path and password; do not enable credential persistence
unless storing the password in the desktop keyring is intentional.
