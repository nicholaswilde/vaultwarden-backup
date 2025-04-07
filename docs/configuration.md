# :gear: Configuration

## :sheep: Clone Repository

Start by cloning this repo to the directory containing your Vaultwarden
data directory, under the name `backup`. In my setup, it looks like this:

```shell
cd /opt/vaultwarden
git clone https://github.com/nicholaswilde/vaultwarden-backup.git backup
cd backup
```

```shell
/opt/vaultwarden  # Top-level Vaultwarden directory
├── backup         # This backup repo
└── data           # Vaultwarden data directory
```

## :hammer_and_wrench: `backup.conf` File

Copy the `backup.conf.tmpl` file to `backup.conf`.

```shell title="/opt/vaultwarden/backup"
cp backup.conf.tmpl backup.conf
```

## :lock: Encryption

If you want encrypted backup archives using `gpg`, set the
`GPG_PASSPHRASE` variable accordingly. If you want to encrypt using
`age` instead, set the `AGE_PASSPHRASE` variable. If both variables are
set, only `gpg` encryption will be performed. If you don't want
encryption at all, comment out both variables or set them to be blank.

This passphrase is used to encrypt the backup archives, which may
contain somewhat sensitive data in plaintext in `config.json` (the
password entries themselves are already encrypted by Bitwarden). It
should be something easy enough for you to remember, but complex enough
to deter, for example, any unscrupulous cloud storage personnel who
might be snooping around. As this passphrase is stored on disk in
plaintext, it definitely should not be your Bitwarden master passphrase
or anything similar.

Encryption keys may be used to encrypt the archives as well. Set 
`GPG_FINGERPRINT` for `gpg` or `AGE_FILE_PATH` for `age`.

`GPG_FINGERPRINT` should be in the format of `0x12345678`, where 1-8 are
the last 8 characters of the fingerprint.

```shell
gpg --fingerprint
```

!!! note

    gpg keys need to already be present in the key ring.

`AGE_FILE_PATH` is the location of `keys.txt`. My location is in the [SOPS config directory][1].

```ini
AGE_FILE_PATH=${HOME}/.config/sops/age/keys.txt
```

The order of precedence for the encryption is:

1. `GPG_FINGERPRINT`
2. `GPG_PASSPHRASE`
3. `AGE_FILE_PATH`
4. `AGE_PASSPHRASE` 

[rclone crypt](https://rclone.org/crypt/) is another option for encrypted
archives. If you prefer to use this method, just set `GPG_PASSPHRASE` to
be blank, configure rclone crypt appropriately, and use the crypt remote
in `RCLONE_DESTS`.

## :zap: Binary Paths

Binary paths can be changed by setting their respective variables in `backup.conf`.

  1. `SQLITE3`
  2. `RCLONE`
  3. `GPG`
  4. `AGE`
  5. `APPRISE`

```shell title="Find binary path"
which <binary>
```

## :simple-rclone: `rclone` Destinations

Change `RCLONE_DESTS` to your list of rclone destinations. You'll have
to [configure](https://rclone.org/docs/) rclone appropriately first.
      
!!! note

    `backup.conf` is simply sourced into the `backup.sh` script, so
    you can add arbitrary environment variables into `backup.conf` as needed.
    This can be useful for configuring any tools called from `backup.sh`,
    such as `rclone`.

## :bell: Notifications

`apprise` can be enabled by setting `APPRISE_EMAIL` in `backup.conf`.

## :alarm_clock: `crontab.tmpl`

Modify the `backup/crontab.tmpl` file as needed. This crontab actually
calls `cron.sh` to run the backup, rather than calling `backup.sh` directly.
Currently, `cron.sh` captures the output of the current run of `backup.sh`
to a `backup.log` file. It also saves a copy of this log file, named
according to whether the backup run was a success or failure. You can add
other custom logic to `cron.sh` if needed, such as signaling failure to a
cron monitoring service.

1. If `/opt/vaultwarden` isn't your top-level Vaultwarden directory, adjust
   the paths in this file accordingly.

2. Review the backup schedule. I generate backup archives hourly, but you
   might prefer to do this less frequently to save space.

3. Review the local backup archive retention policy. I delete archives
   older than 14 days (`-mtime +14`). Adjust this if needed.

4. Review the log file retention policy. I delete log files older than
   14 days (`-mtime +14`). Adjust this if needed.

5. Review the SQLite [VACUUM](https://sqlite.org/lang_vacuum.html) schedule,
   or remove the job if you don't want vacuuming. Vacuuming compacts the
   database file so that operations are faster and backups are smaller.

Install the crontab under a user (typically your normal login) that can
read your Vaultwarden data. In many cases, running `crontab -e` and pasting
the contents of the filled-in crontab template file should work. Note that
if your cron user doesn't have write permissions to the database, then you
must ensure it has write permissions to the Vaultwarden data directory,
as SQLite may need to create a `-wal` file for the database if it doesn't
already exist. If it's unable to do this, the backup will fail with an
`attempt to write a readonly database` error. (For more details, see
https://sqlite.org/wal.html#read_only_databases.)

=== "Automatic"

    ```shell
    (crontab -l 2>/dev/null; cat crontab.tmpl) | crontab -
    ```

=== "Manual"

    ```shell
    crontab -e
    ```

[1]: <https://github.com/getsops/sops?tab=readme-ov-file#23encrypting-using-age>
