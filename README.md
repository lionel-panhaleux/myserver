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

Now run the initial setup

```bash
ansible-playbook --user <provided_user> initial.yml
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

### Setup the KRCG API

You need a personal token for the codex-krcg Github user,
use `ansible-vault` to encode it:

```bash
ansible-vault encrypt_string '<github_token>' --name 'GITHUB_TOKEN'
```

Copy the resulting string to `krcg-api.yaml` (replace the old `GITHUB_PASSWORD:` value).
You can now deploy:

```bash
ansible-playbook krcg-api-v1.yml
ansible-playbook krcg-api-v2.yml
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
