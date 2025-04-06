# :stethoscope: Troubleshooting

## :lock: gpg

Most errors using gpg keys are related either to the gpg key or subkey being expired or the key or subkey is not trusted.

### :handshake: [Trust Key][1]

```shell
gpg --edit-key <key-id>
Secret key is available.
gpg> trust
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
gpg> save
```

### :hourglass: [Change Expiry Date][2]

Identify the sub key that needs the expiry date changed.

```shell
gpg --edit-key <key-id>
gpg> list

sec  rsa2048/AF4RGH94ADC84
     created: 2019-09-07  expires: 2020-11-15  usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa2048/56ABDJFDKFN
     created: 2019-09-07  expired: 2019-09-09  usage: E
[ultimate] (1). Jill Doe (CX) <jilldoe@mail.com>
```

Select the sub key (`ssb`)

```shell
gpg> key 1

sec  rsa2048/AF4RGH94ADC84
     created: 2019-09-07  expires: 2020-11-15  usage: SC
     trust: ultimate      validity: ultimate
ssb*  rsa2048/56ABDJFDKFN
     created: 2019-09-07  expired: 2019-09-09  usage: E
[ultimate] (1). Jill Doe (CX) <jilldoe@mail.com>

gpg> expire
...
Changing expiration time for a subkey.
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
      
Key is valid for? (0) 2y
Key expires at Wed 9 Sep 16:20:33 2021 GMT
Is this correct? (y/N) y
gpg> save
```

## :simple-rclone: rclone

Upload a test file.

```
rclone --syslog -vv --no-check-dest copy test.txt "drive:vaultwarden"
```

## :incoming_envelope: apprise

Send test email.

```shell
apprise -vv -t 'my title' -b 'my notification body' 'mailto://email:passkey@gmail.com'
```

## :file_folder: Logs

Logs can be shown by running the following

```shell
sudo journalctl -t rclone --no-pager
sudo journalctl -t vaultwarden-backup --no-pager
```

[1]: <https://security.stackexchange.com/a/129477>
[2]: <https://unix.stackexchange.com/a/552708/93726>
