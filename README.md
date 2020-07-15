# myserver

Debian webserver deployment for
[the Codex of the Damned](https://github.com/lionel-panhaleux/codex-of-the-damned)
and [KRCG](https://github.com/lionel-panhaleux/krcg)

## Initial setup

Create a `.vault-password-file.txt` in this directory

```bash
touch .vault-password-file.txt
```

Generate a strong password and put it in there.

```bash
ansible-playbook --user <provided_user> initial.yml -k
```

Use the user and password you received by e-mail after your server setup.

You should now be able to log to the server. Get its public RSA key:

```bash
ssh krcg.org
$> cd ~/.ssh
$> cat id_rsa.pub
```

And add it to the `Deploy Keys` (Settings > Deploy Keys) of the
[KRCG Github repository](https://github.com/lionel-panhaleux/krcg).

## Other setup steps

### Setup packages

```bash
ansible-playbook setup.yml
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

## Setup the Codex website

```bash
ansible-playbook codex.yml
```

Use the `make deploy` command in the codex repository
to deploy the website on the server.
