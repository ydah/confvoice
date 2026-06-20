# ConfVoice

ConfVoice is a Rails application for collecting conference session feedback from QR codes. Organizers can review submissions in real time and share only moderated feedback with speakers.

## Requirements

- Ruby 4.0.x
- Rails 8.1.x
- PostgreSQL 16+
- Docker, for the production/Kamal deployment flow

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Use `bin/dev` for local development so the Rails server and Tailwind watcher run together. If you run `bin/rails server` directly after cleaning assets, rebuild styles with `bin/rails tailwindcss:build`.

The seed data creates:

- Admin: `admin@example.com / confvoice-local-password`
- Organizer: `organizer@example.com / confvoice-local-password`
- Speaker: `speaker@example.com / confvoice-local-password`

Set `CONFVOICE_SEED_PASSWORD` to override the local seed password. Seeds are blocked in production unless `ALLOW_PRODUCTION_SEEDS=true` is set for an intentional one-time bootstrap.

## Environment

Copy `.env.example` and set production values in your deployment environment.

Required in production:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `APP_HOST`

Common optional settings:

- `MAIL_FROM`
- `SMTP_ADDRESS`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `ACTIVE_STORAGE_SERVICE`
- `RAILS_ASSUME_SSL`
- `RAILS_FORCE_SSL`
- `CONFVOICE_SELF_REGISTRATION_ENABLED`

## Features

- Conference and session management
- Anonymous feedback submission with duplicate prevention
- Quick reactions
- QR code pages for sessions
- Organizer dashboard with charts, reaction counts, and word cloud
- Speaker invite links with a read-only live portal
- CSV export with UTF-8 BOM for Excel
- PDF slide attachment per session
- Japanese/English locale switching
- Rack::Attack rate limits
- Solid Queue, Solid Cache, and Solid Cable
- Kamal deployment template

## Tests

```bash
bin/rails test
bin/rails zeitwerk:check
```

## Deployment

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

The Docker entrypoint runs `bin/rails db:prepare` before starting the Rails server, so the initial deploy and later migrations are applied at boot. For higher-traffic production use, move migrations to a paid Render pre-deploy command instead of running them during boot.

`ACTIVE_STORAGE_SERVICE` defaults to `local`. Render service filesystems are ephemeral, so configure an external Active Storage service before relying on uploaded PDF attachments in production.

### Kamal

`config/deploy.yml` is prepared for Kamal 2. Replace the placeholder host, image, registry user, and secrets before running:

```bash
kamal setup
kamal deploy
```

For production email notification, configure SMTP-related environment variables.
