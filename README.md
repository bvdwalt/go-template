# go-template

A GitHub template repository for Go projects, pre-configured with:

- **GoReleaser** — cross-platform builds (macOS, Linux, Windows) and GitHub releases
- **Docker** — multi-platform images published to Docker Hub and GHCR on every release
- **Homebrew tap** — automatic formula updates on release
- **Auto-tagging** — conventional commits drive version bumps via `svu`
- **justfile** — common development commands
- **Web app scaffold** (opt-in) — chi backend + Svelte/Vite frontend embedded into a single binary via `go:embed`, plus an opt-in SQLite data layer. Delete what you don't need — see [Web app scaffold](#web-app-scaffold).

## Using this template

1. Click **"Use this template"** on GitHub to create a new repo
2. Clone your new repo locally
3. Run the init script to replace placeholders:
   ```bash
   chmod +x init.sh
   ./init.sh <app-name> <github-owner> <module-path> "<description>"
   ```
   Example:
   ```bash
   ./init.sh mytool bvdwalt github.com/bvdwalt/mytool "A tool that does things"
   ```
4. Add the required secrets — see [Secrets setup](#secrets-setup) below
5. Start coding in `cmd/<app-name>/main.go`

## Secrets setup

One PAT is required. Create it at **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**.

### `HOMEBREW_TAP_GITHUB_TOKEN`

This allows GoReleaser to push the updated Homebrew cask to your tap repo after a release.

- **Resource owner:** your GitHub account
- **Repository access:** only `homebrew-tap`
- **Permissions:** Contents → Read and write

Add it to the repo at **Settings → Secrets and variables → Actions → New repository secret**, named `HOMEBREW_TAP_GITHUB_TOKEN`.

> If you already have this secret from another project, you still need to add it here — secrets are per repo.

### `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`

Required for GoReleaser to push images to Docker Hub. Create an access token at **Docker Hub → Account Settings → Security**.

Add both to the repo at **Settings → Secrets and variables → Actions**.

> If you don't need Docker image publishing, remove the `dockers_v2` section from `.goreleaser.yaml` and the Docker steps from `release.yml`. GHCR publishing uses `GITHUB_TOKEN` automatically — no extra secret needed.

### Prerequisites before first release

- Your `<github-owner>/homebrew-tap` repo must exist (can be empty). GoReleaser will fail if it doesn't.
- The `LICENSE` file is included in release archives — update the copyright year/name if needed.

## Web app scaffold

The template includes an opt-in pattern for apps that serve a browser frontend, matching the structure used by [overdrive](https://github.com/bvdwalt/overdrive) and [zwoop](https://github.com/Zwoop-Labs/zwoop):

- `internal/server/` — [chi](https://github.com/go-chi/chi) router with a `/health` endpoint and an SPA static-file handler (with cache headers for hashed assets and index.html fallback for client-side routes).
- `web/` — Svelte + Vite + TypeScript frontend. `web/embed.go` uses `//go:embed all:dist` to compile the built frontend directly into the Go binary — one binary, no separate static-file server needed.
- `internal/config/` — env-var config (`PORT`, `DB_PATH`).
- `internal/db/` — opt-in SQLite data layer: plain `database/sql` + [modernc.org/sqlite](https://gitlab.com/cznic/sqlite) (pure Go, no cgo), with a minimal embedded-migration runner (`internal/db/migrate.go` applies `internal/db/migrations/*.sql` in order, tracked in a `schema_migrations` table). No ORM — write your own queries. Not wired into `main.go` by default; call `db.Connect(cfg.DBPath)` when you need persistence.
- `Dockerfile` — three-stage build (Node builds the frontend → Go compiles the binary with the frontend embedded → Alpine runtime). `Dockerfile.goreleaser` stays as-is; the release workflow builds the frontend before GoReleaser cross-compiles, so `web/dist` is already populated when `go:embed` runs.

Local commands: `just web-dev` (Vite dev server, proxies `/api` and `/health` to `:8080`), `just web-build` (build frontend into `web/dist`), `just build` (builds frontend then the Go binary — no-ops the frontend step if `web/` doesn't exist).

**Building a CLI-only tool instead?** Delete `web/` and `internal/server/`, revert `cmd/<app-name>/main.go` to a plain `func main() {}`, and drop the `Dockerfile` if you don't need a container image. The CI and release workflows skip the frontend build steps automatically when `web/package.json` is absent, so no workflow edits are required.

**Don't need persistence?** Delete `internal/db/`, then remove the `modernc.org/sqlite` require from `go.mod` and run `go mod tidy`.

## Versioning

After CI passes on `main`, the release workflow tags the next version using [svu](https://github.com/caarlos0/svu) based on [conventional commits](https://www.conventionalcommits.org/) and runs GoReleaser in the same job, so no extra token is needed. If a release fails, re-run the **Release** workflow manually (Actions → Release → Run workflow) to publish the latest tag again.

| Prefix | Bump |
|--------|------|
| `fix:` | patch (0.0.x) |
| `feat:` | minor (0.x.0) |
| `feat!:` / `BREAKING CHANGE:` | minor while the major version is 0 (`svu --v0`); tag `v1.0.0` by hand when ready |
| `chore:`, `docs:`, etc. | no bump |

## Local commands

```bash
just build          # Build the binary
just run            # Build and run
just test           # Run tests
just test-coverage  # Run tests with coverage report
just fmt            # Format code
just lint           # Run golangci-lint
just clean          # Remove build artifacts
just version        # Show current and next version
just tag            # Create version tag locally
```

## Prerequisites

- [just](https://github.com/casey/just) — `brew install just`
- [svu](https://github.com/caarlos0/svu) — `go install github.com/caarlos0/svu/v3@v3.4.0` (for `just version/tag`)
- [golangci-lint](https://golangci-lint.run/) — `brew install golangci-lint` (optional, for `just lint`)
- [Node.js](https://nodejs.org/) 20+ — only needed if keeping the `web/` frontend scaffold
