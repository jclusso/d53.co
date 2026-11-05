# Agents

- `bin/setup --skip-server` installs gems and prepares the database.
- `bin/ci` runs the lint, security and test checks. CI also builds and boots the production Docker image.
- Tests replay DNS responses from `test/dns_recordings`. Run them with `RECORD_DNS=1` to query the live servers and re-record.

## Dependabot review workflow

`.github/workflows/dependabot-review.md` runs in a sandbox where:

- Postgres is running and `DATABASE_URL` points at it.
- Public DNS is blocked. Tests replay recorded DNS responses, so they still run.
- System tests can't start a browser. CI runs them on the same commit.
- `playwright-cli` can drive the running app in a browser.
