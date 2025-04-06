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

## :scales: License

​[LICENSE](./LICENSE)

## :pencil:​Author

​This project was forked in 2025 by [​Nicholas Wilde​][1].

## :link: References

[1]: <https://www.vaultwarden.net/>
[2]: <https://github.com/jjlin/vaultwarden-backup>
