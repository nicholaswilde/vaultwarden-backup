# :pencil: Usage

Test the backup.

```shell title="/opt/vaultwarden/backup"
./backup.sh
```

If everything is working properly, you should see the following:

1. Backup archives generated under `backup/archives`.
2. Encrypted backup archives uploaded to your configured rclone destination(s).

!!! example

    ```shell
    /opt/vaultwarden/backup
    ├── archives
    │   ├── vaultwarden-20210101-0000.tar.xz
    │   ├── vaultwarden-20210101-0000.tar.xz.gpg
    │   ├── vaultwarden-20210101-0100.tar.xz
    │   ├── vaultwarden-20210101-0100.tar.xz.age
    │   └── ...
    ├── backup.conf
    ├── backup.conf.tmpl
    ├── backup.sh
    ├── crontab.tmpl
    ├── LICENSE
    └── README.md
    ```
