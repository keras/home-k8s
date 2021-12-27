# home k8s things

**Install:**
```
make repo-update install-all
```

## Authentication

`traefik-forward-auth` is used for OAuth2 based authentication.

Go to GCP console, `APIs & Services` -> `Credentials`. Create OAuth client ID for a web application and add the client id and secret to config & secret.
Add your email to `ALLOWED_EMAILS`.


## secret.md:

Secrets can be populated to `secret.md`

```
install-traefik-forward-auth: export GOOGLE_AUTH_SECRET = <OAuth client Secret>
install-traefik-forward-auth: export ALLOWED_EMAILS = some.body@gmail.com

install-photoprism: export PHOTOPRISM_ADMIN_PASSWORD = <some password>
```

