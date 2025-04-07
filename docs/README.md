# :lock: Vaultwarden Backup :floppy_disk:
[![task](https://img.shields.io/badge/Task-Enabled-brightgreen?style=for-the-badge&logo=task&logoColor=white)](https://taskfile.dev/#/)
[![ci](https://img.shields.io/github/actions/workflow/status/nicholaswilde/vaultwarden-backup/ci.yaml?label=ci&style=for-the-badge&branch=main)](https://github.com/nicholaswilde/vaultwarden-backup/actions/workflows/ci.yaml)

A simple setup for backing up Vaultwarden (formerly bitwarden_rs) data/config to cloud storage.

## :pushpin: TL;DR

```shell
sudo apt install rclone
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

---

## :arrow_right_hook: Deviations

The deviations of this fork are:

1. `apprise` notifications.
2. Additional documentation and variables in `backup.conf`.
3. Use `gpg` and `age` keys in addition to passphrases.

---

## :book: Documentation

Documentation can be found [here][1].

---

## :open_hands: Contributing

For the most part, I'm not looking for contributions or feature requests, as
this repo is only intended to implement my own backup requirements. I may be
willing to make some minor generalizations to make it easier for people to
use the repo without modification, but aside from that, feel free to fork and
modify this setup to fit your own needs.

---

## :clipboard: ToDo

- [ ] Test apprise disable by making variable not set.
- [ ] Document backup restoration.
- [ ] Evaluate if app paths are needed.
- [ ] Do work in `/tmp` rather than `backup` dir.
- [X] ~Auto detection of gpg version for pinentry.~
- [X] ~Move documentation to wiki.~
- [X] ~Change from passphrases to encryption keys.~
- [X] ~Add logs to standard log folder.~

---

<!-- spellchecker-disable -->
## :balance_scale: License
<!-- spellchecker-enable -->

[License](./LICENSE)

---

## :pencil: Author

This project was forked in 2025 by [Nicholas Wilde](https://github.com/nicholaswilde/).

[1]: <https://www.vaultwarden.net/>
[2]: <https://community-scripts.github.io/ProxmoxVE/scripts?id=vaultwarden>
[3]: <https://nicholaswilde.io/vaultwarden-backup>
