# :clipboard: Prerequisites

## :simple-vaultwarden: Vaultwarden

A standard Unix-like (preferably Linux) host running [Vaultwarden][1].

!!! note

    I'm running this in Proxmox and so I've used the [ProxmoxVE community script][2]

```shell
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/vaultwarden.sh)"
```

## :alarm_clock: Cron Daemon

A [`cron`](https://en.wikipedia.org/wiki/Cron) daemon. This is used to run
backup actions on a scheduled basis.

   ```shell
   sudo apt install cron
   ```

## :simple-sqlite: Sqlite

An [`sqlite3`](https://sqlite.org/cli.html) binary. This is used to back up
the SQLite database. This can be installed via the `sqlite3` package on
Debian/Ubuntu or the `sqlite` package on RHEL/CentOS/Fedora.

```shell
sudo apt install sqlite3
```

## :simple-rclone: rclone

An [`rclone`](https://rclone.org/) binary. This is used to copy the backup
archives to cloud storage. This can be installed via the `rclone` package
on Debian/Ubuntu and RHEL/CentOS/Fedora ([EPEL](https://fedoraproject.org/wiki/EPEL)
required for RHEL/CentOS), but as rclone changes more rapidly, it's probably
best to just use the latest binary from https://rclone.org/downloads/.

```shell
sudo apt install rclone
```

## :cloud: Cloud Storage

An account at one or more cloud storage services
[supported](https://rclone.org/overview/) by `rclone`. If you don't have one
yet, here are a few cloud storage services that offer a free tier:

* [Backblaze B2](https://www.backblaze.com/b2/cloud-storage.html) (10 GB)
* [Box](https://www.box.com/pricing/individual) (10 GB)
* [Cloudflare R2](https://www.cloudflare.com/products/r2/) (10 GB)
* [Dropbox](https://www.dropbox.com/basic) (2 GB)
* [Google Drive](https://www.google.com/drive/) (15 GB)
* [Microsoft OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage) (5 GB)
* [Oracle Cloud](https://www.oracle.com/cloud/free/) (10 GB)

I am using [Google Drive](https://rclone.org/drive/) with the remote named `drive`.

I am also using a headless server and so I needed to use [this method](https://rclone.org/remote_setup/) to authenticate.

## :lock: gpg (optional)

[`gpg`](https://gnupg.org/) (GnuPG 2.x) to encrypt the archive. This can be
installed via the `gnupg` package on Debian/Ubuntu or the `gnupg2` package
on RHEL/CentOS/Fedora.

## :lock: age (optional)

[`age`](https://github.com/FiloSottile/age) to encrypt the archive. This option
requires a [custom version](https://github.com/jjlin/age/tree/passphrase-from-env)
of the tool that supports reading the passphrase from an environment variable.

## :incoming_envelope: apprise (optional)

[`apprise`](https://github.com/caronc/apprise) can be used to send notifications with the job status.

```shell title="Installation"
sudo apt install apprise # bookworm
# or
pipx install apprise # other
```

!!! success "Send test email"

    ```shell
    apprise -vv -t 'my title' -b 'my notification body' 'mailto://email:passkey@gmail.com'
    ```

[1]: <https://www.vaultwarden.net/>
[2]: <https://community-scripts.github.io/ProxmoxVE/scripts?id=vaultwarden>
