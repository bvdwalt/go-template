# go-template

A GitHub template repository for Go projects, pre-configured with:

- **GoReleaser** — cross-platform builds (macOS, Linux, Windows) and GitHub releases
- **Homebrew tap** — automatic formula updates on release
- **Auto-tagging** — conventional commits drive version bumps via `svu`
- **justfile** — common development commands

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

Two PATs are required. Create them at **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**.

### `GH_PAT`

This allows the auto-tag workflow to push tags in a way that triggers the release workflow. GitHub's default `GITHUB_TOKEN` intentionally cannot trigger other workflows, so a real PAT is needed.

- **Resource owner:** your GitHub account
- **Repository access:** only the new repo (e.g. `mynewapp`)
- **Permissions:** Contents → Read and write

Add it to the repo at **Settings → Secrets and variables → Actions → New repository secret**, named `GH_PAT`.

> This secret must be added per repo each time you use this template.

### `HOMEBREW_TAP_GITHUB_TOKEN`

This allows GoReleaser to push the updated Homebrew cask to your tap repo after a release.

- **Resource owner:** your GitHub account
- **Repository access:** only `homebrew-tap`
- **Permissions:** Contents → Read and write

Add it to the repo at **Settings → Secrets and variables → Actions → New repository secret**, named `HOMEBREW_TAP_GITHUB_TOKEN`.

> If you already have this secret from another project, you still need to add it here — secrets are per repo.

### Prerequisites before first release

- Your `<github-owner>/homebrew-tap` repo must exist (can be empty). GoReleaser will fail if it doesn't.
- The `LICENSE` file is included in release archives — update the copyright year/name if needed.

## Versioning

Commits to `main` are automatically tagged using [svu](https://github.com/caarlos0/svu) based on [conventional commits](https://www.conventionalcommits.org/):

| Prefix | Bump |
|--------|------|
| `fix:` | patch (0.0.x) |
| `feat:` | minor (0.x.0) |
| `feat!:` / `BREAKING CHANGE:` | major (x.0.0) |
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
just release        # Tag and push to trigger a release
```

## Prerequisites

- [just](https://github.com/casey/just) — `brew install just`
- [svu](https://github.com/caarlos0/svu) — `go install github.com/caarlos0/svu/v3@latest` (for `just version/tag/release`)
- [golangci-lint](https://golangci-lint.run/) — `brew install golangci-lint` (optional, for `just lint`)
