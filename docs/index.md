# :lock: Vaultwarden Backup :floppy_disk:

[![task](https://img.shields.io/badge/Task-Enabled-brightgreen?style=for-the-badge&logo=task&logoColor=white)](https://taskfile.dev/#/)
[![ci](https://img.shields.io/github/actions/workflow/status/nicholaswilde/vaultwarden-backup/ci.yaml?label=ci&style=for-the-badge&branch=main)](https://github.com/nicholaswilde/vaultwarden-backup/actions/workflows/ci.yaml)

A simple setup for backing up [Vaultwarden][1] (formerly bitwarden_rs) data/config to cloud storage.

!!! note

    This is a fork of Jeremy Lin's [Vaultwarden Backup][2]

## :pushpin: TL;DR

```shell
sudo apt install rclone sqlite3
sudo apt install apprise # bookworm
# or
pipx install apprise # other
```

Setup `rclone`

```shell
cd /opt/vaultwarden
git clone https://github.com/nicholaswilde/vaultwarden-backup.git backup
cd backup
cp backup.conf.tmpl backup.conf
(crontab -l 2>/dev/null; cat crontab.tmpl) | crontab -
```

Edit `backup.conf`

```shell
./backup.sh
```

## :frame_with_picture: Overview

!!! note

    Vaultwarden was formerly known as bitwarden_rs.

This repo contains my automated setup for SQLite-based [Vaultwarden][1]
backups. It's designed solely to meet my own backup requirements (i.e.,
not to be general purpose):

1. Generate a single archive with a complete backup of all Vaultwarden data
   and config on a configurable schedule.

2. Retain backup archives on the local Vaultwarden host for a configurable
   number of days.

3. Upload encrypted copies of the backup archives to one or more cloud
   storage services using [rclone](https://rclone.org/). The retention policy
   is configured/managed at the storage service level.

4. Return success when all backup archives are successfully uploaded,
   or failure if any uploads fail. This allows cron monitoring services like
   [Healthchecks.io](https://healthchecks.io/), [Cronitor](https://cronitor.io/),
   or [Dead Man’s Snitch](https://deadmanssnitch.com/) to provide notification
   of backup failures.

!!! tip

    This single-archive backup scheme isn't space-efficient if your vault
    includes large file attachments, as they will be re-uploaded with each backup.
    If this is an issue, you might consider modifying the script to use
    [restic](https://restic.net/) instead.

## :arrow_right_hook: Deviations

The deviations of this fork are:

1. `apprise` notifications.
2. Additional documentation and variables in `backup.conf`.
3. Enable `GPG` or `age` encryption if passphrase is blank.
4. Use `gpg` and `age` keys rather than passphrases.

## :open_hands: Contributing

For the most part, I'm not looking for contributions or feature requests, as
this repo is only intended to implement my own backup requirements. I may be
willing to make some minor generalizations to make it easier for people to
use the repo without modification, but aside from that, feel free to fork and
modify this setup to fit your own needs.

## :scales: License

​[LICENSE](./LICENSE)

## :pencil:​Author

​This project was forked in 2025 by [​Nicholas Wilde​][1].

## :link: References

[1]: <https://www.vaultwarden.net/>
[2]: <https://github.com/jjlin/vaultwarden-backup>
