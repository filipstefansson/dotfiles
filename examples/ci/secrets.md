# GitHub secrets checklist (set once per repo, or as org secrets)

These are referenced by `ios-release.yml` / `Fastfile`. Set them under
**Settings → Secrets and variables → Actions** on the repo (or the org, to share
across all private repos). Nothing here lives in the dotfiles repo.

## Apple code signing (iOS submission)

| Secret | What it is | Where to get it |
|---|---|---|
| `MATCH_PASSWORD` | Passphrase that decrypts the certs/profiles `fastlane match` stores | You choose it when running `fastlane match init` / `match appstore` the first time |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 `user:token` to read the private match storage repo | `echo -n "USER:PAT" \| base64` (PAT with repo read) |
| `ASC_KEY_ID` | App Store Connect API key ID | App Store Connect → Users and Access → Integrations → App Store Connect API |
| `ASC_ISSUER_ID` | Issuer ID for that API key | Same page (top of the Keys tab) |
| `ASC_KEY_P8` | Contents of the downloaded `AuthKey_XXXX.p8` | Paste the whole file body |

> One-time, on a Mac you control: `fastlane match init` then `fastlane match appstore`
> to generate + store the distribution cert and profile in your match storage repo.

## Push (if jobs commit/push back)

| Secret | What it is |
|---|---|
| `GH_PUSH_TOKEN` | Fine-grained PAT or GitHub App token with contents:write on the target repos. Use instead of the interactive 1Password SSH agent (which can't run headless). CI commits go unsigned — git commit signing is intentionally skipped on the runner. |

## AI-agent jobs

| Secret | What it is |
|---|---|
| `ANTHROPIC_API_KEY` | Dedicated key so Claude Code can run non-interactively in jobs. Scope/rotate independently of your personal login. |
