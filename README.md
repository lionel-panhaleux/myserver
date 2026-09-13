# myserver

Legacy Debian server bootstrap for [KRCG](https://github.com/lionel-panhaleux/krcg):
initial setup, packages and deployment keys. It no longer deploys any site or
service: every app has moved to its own `ansible/` or `deploy/` directory,
consuming the `lionel_panhaleux.server_setup` collection where it needs its roles —
see "Not deployed from here" below.

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
and the `lackey.krcg.org` content. Generate _another_ SSH key, upload the private key to Github,
and the public key to your server, like this:

```bash
ansible-playbook add-pubkey.yml -e "pubkey_file=~/.ssh/deploy_key.pub"
```

You might also need to update Giuthub secrets accordingly, including the host pubkey.
Just run this command locally, and paste one of the keys as your Github secret.

```bash
ssh-keyscan krcg.org
```

## Not deployed from here

Each of these has a pipeline of its own. Its playbook, and any role only it used,
was removed from this repo once the replacement was confirmed live on the host.

### The KRCG Discord Bot

Its own pipeline in `lionel-panhaleux/krcg-bot` under `ansible/` ships a released
wheel to the same host and owns `krcg-bot.service`. Do not add a playbook for it
back here: a PyPI install would overwrite that deploy, and the package is archived
at 4.5.

### The Timer Discord Bot

`lionel-panhaleux/timer` under `ansible/` installs a PyPI release into a uv-provided
Python 3.13 on gravelines and owns `timer-bot.service`. The `python-worker` role went
with `timer-bot.yml`. Do not re-add either: it built its venv on the host's 3.11,
where pip skips every `>=3.13` release and still reports success, and it put the
token back inline in the unit.

### The rulings and Archon websites

`rulings.krcg.org` comes from `vtes-biased/rulings-website` and `archon.krcg.org`
from `vtes-biased/archon-vibe`, both under `ansible/`. The `quart-backend`,
`fastapi-backend` and `postgresql-database` roles went with their playbooks.

Do not re-add a rulings playbook in particular: v2 made a one-way schema change
to the shared `vtes-rulings` database, and the v1 app writes a corrupt row on its
first login against it.

### The KRCG API and the Codex

`api.krcg.org` (served by `v3.api.krcg.org`, alongside `v4.api.krcg.org`) comes from
`lionel-panhaleux/krcg-api`, and `codex-of-the-damned.org` / `codex-beta.krcg.org`
from `lionel-panhaleux/codex-of-the-damned`, both under `deploy/`. The
`flask-backend` and `backend-website` roles went with their playbooks.

Do not re-add either. The new services listen on different ports but claim the
same domains, and the old vhost files sort ahead of the new ones in
`sites-enabled` — nginx would route those domains back to rebuilt uWSGI services,
and `api.krcg.org` would stop following the `krcg_api_live` switch.

### The War Room app

`warroom.krcg.org` comes from `lionel-panhaleux/warroom-app` under `ansible/`, served
from `/var/www/warroom` by the collection's `nginx_site` role. The `pwa-website` role
went with `warroom.yml`. Do not re-add it: it would recreate the plain vhost files,
which claim the same domain as the role's vhost.

### The LackeyCCG plugin server

`lackey.krcg.org`'s vhost and certificate come from `lionel-panhaleux/vtes-lackeyccg`
under `ansible/` (the collection's `nginx_site` role, over HTTP and HTTPS). Its
`make deploy` still rsyncs the plugin into `projects/lackey.krcg.org/dist`.
`lackey-static.yml` went; do not re-add it, for the same reason as the War Room app.

### The KRCG static website

`static.krcg.org`'s vhost and certificate come from `lionel-panhaleux/krcg-static`
under `ansible/` (the collection's `nginx_site` role, as a public site over HTTP and
HTTPS). Its GitHub Actions still rsync the build into `projects/static.krcg.org/dist`.
`krcg-static.yml` went, and with it the `register-ssl` and `static-website` roles;
do not re-add them, for the same reason as the War Room app.
