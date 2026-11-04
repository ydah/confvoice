# ConfVoice

ConfVoice is a Rails application for collecting conference session feedback from QR codes. Organizers can review submissions in real time and share only moderated feedback with speakers.

## Requirements

- Ruby 4.0.x
- Rails 8.1.x
- PostgreSQL 16+
- libvips 8.13+ for image attachments
- Docker, for the production/Kamal deployment flow

## Setup

Start PostgreSQL and ensure your local database role can create databases, or export a `DATABASE_URL` for your local instance.

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Use `bin/dev` for local development so the Rails server and Tailwind watcher run together. If you run `bin/rails server` directly after cleaning assets, rebuild styles with `bin/rails tailwindcss:build`.

Development and tests do not need the maintainer's `config/master.key`; Rails generates a local secret when no credentials key is available.

The seed data creates:

- Admin: `admin@example.com / confvoice-local-password`
- Organizer: `organizer@example.com / confvoice-local-password`
- Speaker: `speaker@example.com / confvoice-local-password`

These accounts, sessions, and feedback are demonstration data. The sample event and speaker names do not represent an official conference schedule or actual attendee submissions.

Set `CONFVOICE_SEED_PASSWORD` to override the local seed password for newly created accounts. Re-running seeds does not change existing passwords. Production seeds require both `ALLOW_PRODUCTION_SEEDS=true` for an intentional one-time bootstrap and a nonblank `CONFVOICE_SEED_PASSWORD` different from the documented default. Never expose existing demo accounts with their default password.

## Environment

Use `.env.example` as a reference and export the values in your shell or configure them in your deployment environment. The application does not load `.env` files automatically.

Required in production:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `APP_HOST` (or `RENDER_EXTERNAL_HOSTNAME` on Render)

Common optional settings:

- `MAIL_FROM`
- `SMTP_ADDRESS`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `ACTIVE_STORAGE_SERVICE`
- `RAILS_ASSUME_SSL`
- `RAILS_FORCE_SSL`
- `CONFVOICE_SELF_REGISTRATION_ENABLED`
- `CONFVOICE_OGP_IMAGE_UPLOAD_ENABLED`

## Features

- Conference and session management
- Anonymous feedback submission with duplicate prevention
- Quick reactions
- QR code pages for sessions
- Organizer dashboard with charts, reaction counts, and feedback keywords
- Speaker invite links with a read-only live portal
- Conference-wide or per-speaker CSV export with UTF-8 BOM for Excel (sessions with the same speaker name are grouped within a conference)
- PDF slide attachment per session
- English interface
- Rack::Attack rate limits
- Solid Queue, Solid Cache, and Solid Cable
- Kamal deployment template

## Tests

```bash
bin/rails test
bin/rails zeitwerk:check
```

## Deployment

For a new deployment fork, replace the bundled `config/credentials.yml.enc` with your own credentials: remove that encrypted file, then run `EDITOR=vi bin/rails credentials:edit` to generate a new encrypted file and `config/master.key`. Keep the generated `secret_key_base`. Commit only the encrypted file and store the key in your deployment's `RAILS_MASTER_KEY`; never commit or share the key.

Do not replace credentials for an existing deployment without planning a key rotation. Local development does not require this step.

### Render

This repository includes `render.yaml` for a Docker-based Render Blueprint. It creates:

- One Docker web service
- One Render Postgres database
- `DATABASE_URL`, `CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, and `CABLE_DATABASE_URL` pointing at the same internal database
- Solid Queue running inside Puma for the single-service deployment

Deploy steps:

1. Push this repository to GitHub/GitLab/Bitbucket.
2. In Render, create a new Blueprint instance from this repository.
3. When prompted for `RAILS_MASTER_KEY`, paste the contents of `config/master.key`.
4. Deploy.

On Render, the app uses `RENDER_EXTERNAL_HOSTNAME` automatically for host authorization and mailer URLs. If you add a custom domain, set `APP_HOST` to that domain in the web service environment variables.

`CONFVOICE_OGP_IMAGE_UPLOAD_ENABLED` defaults to `false` in production. Keep it disabled on Render's free plan because the service filesystem is ephemeral. If you later configure durable Active Storage storage, set it to `true` to show the OGP image upload controls.

The Docker entrypoint runs `bin/rails db:prepare` before starting the Rails server, so the initial deploy and later migrations are applied at boot. For higher-traffic production use, move migrations to a paid Render pre-deploy command instead of running them during boot.

### Kamal

`config/deploy.yml` is prepared for Kamal 2. Replace the placeholder host, image, registry user, and secrets before running:

```bash
kamal setup
kamal deploy
```

For production email notification, configure SMTP-related environment variables.
