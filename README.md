# myserver

Debian webserver deployment for
[the Codex of the Damned](https://github.com/lionel-panhaleux/codex-of-the-damned)
and [KRCG](https://github.com/lionel-panhaleux/krcg)

## Initial setup

List the target server in the inventory file `hosts.ini`

Copy your SSH key to the target server.
Use the user and password you received by e-mail after your server setup.

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<hostname_or_ip>
```

You should be able to connect to the server without password

```bash
ssh <username>@<hostname_or_ip>
```

Install required Ansible packages

```
ansible-galaxy install -r requirements.yml
```

Now run the initial setup, maybe limit to the server you're installing

```bash
ansible-playbook --user <provided_user> initial.yml -l krcg_gra
```

## Other setup steps

### Setup packages and SSH key

```bash
ansible-playbook setup.yml
```

You can now get the server public RSA key in case you need it:

```bash
ssh krcg.org
$> cd ~/.ssh
$> cat id_rsa.pub
```

### Setup a deployment public key

You might need an additional public key for deployments.
It is used by Github automation to deploy purely static websites, like `static.krcg.org`
and `lackey.krcg.org`. Generate _another_ SSH key, upload the private key to Github,
and the public key to your server, like this:

```bash
ansible-playbook add-pubkey.yml -e "pubkey_file=~/.ssh/deploy_key.pub"
```

You might also need to update Giuthub secrets accordingly, including the host pubkey.
Just run this command locally, and paste one of the keys as your Github secret.

```bash
ssh-keyscan krcg.org
```

### Setup the KRCG API

You need a personal token for the codex-krcg Github user,
use `ansible-vault` to encode it:

```bash
ansible-vault encrypt_string '<github_token>' --name 'GITHUB_TOKEN'
```

Copy the resulting string to `krcg-api.yaml` (replace the old `GITHUB_PASSWORD:` value).
You can now deploy:

```bash
ansible-playbook krcg-api.yml
```

### Setup the KRCG Discord Bot

You need to get the bot token from discord and use `ansible-vault` to encode it:

```bash
ansible-vault encrypt_string '<bot_token>' --name 'DISCORD_TOKEN'
```

Copy the resulting string to `krcg-bot.yaml` (replace the old `DISCORD_TOKEN:` value).
You can now deploy:

```bash
ansible-playbook krcg-bot.yml
```

### Setup the Timer Discord Bot

You need to get the bot token from discord and use `ansible-vault` to encode it:

```bash
ansible-vault encrypt_string '<bot_token>' --name 'DISCORD_TOKEN'
```

Copy the resulting string to `timer-bot.yaml` (replace the old `DISCORD_TOKEN:` value).
You can now deploy:

```bash
ansible-playbook timer-bot.yml
```

### Archon Bot database operations

Get a backup of the Archon database:

```bash
ansible-playbook archon-backup.yml
```

The backup is saved in your local `backups` folder. You can restore it with:

```bash
ansible-playbook archon-restore.yml -e "backup_file=2024-02-06-21:22:39/archon.dump.gz"
```

Note you should provide the backup file name _without_ the `backups/` folder prefix.

### Setup the Codex website

```bash
ansible-playbook codex-beta.yml
ansible-playbook codex.yml
```

## Updates

For a simple package update (no change on the service or webserver configurations), you can use the `deploy` tag:

```bash
ansible-playbook codex.yml --tags=deploy
```

If you only need to update TLS certificates, use:

```bash
ansible-playbook codex.yml --tags=certs
```
