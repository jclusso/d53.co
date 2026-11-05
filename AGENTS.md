# Agents

- `bin/setup --skip-server` installs gems and prepares the database.
- `bin/ci` runs the lint, security and test checks. CI also builds and boots the production Docker image.

## Dependabot review workflow

`.github/workflows/dependabot-review.md` runs in a sandbox where:

- Postgres is running and `DATABASE_URL` points at it.
- Public DNS is blocked, so tests that need live DNS skip themselves (`SKIP_LIVE_DNS`).
- System tests can't start a browser. CI runs them on the same commit.
- `playwright-cli` can drive the running app in a browser.
