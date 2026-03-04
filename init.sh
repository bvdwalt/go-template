#!/usr/bin/env bash
# Usage: ./init.sh <app-name> <github-owner> <module-path> <description>
# Example: ./init.sh mytool bvdwalt github.com/bvdwalt/mytool "A tool that does things"
set -euo pipefail

APP_NAME="${1:?Usage: ./init.sh <app-name> <github-owner> <module-path> <description>}"
GITHUB_OWNER="${2:?Missing github-owner}"
MODULE_PATH="${3:?Missing module-path}"
APP_DESCRIPTION="${4:?Missing description}"
YEAR=$(date +%Y)

echo "Initializing project: $APP_NAME"

# Replace placeholders in files
find . -not -path './.git/*' -type f \( \
    -name "*.yaml" -o -name "*.yml" -o \
    -name "go.mod" -o -name "justfile" -o \
    -name "*.go" -o -name "*.md" -o \
    -name ".gitignore" \
\) | while read -r file; do
    sed -i '' \
        -e "s|APP_NAME|$APP_NAME|g" \
        -e "s|GITHUB_OWNER|$GITHUB_OWNER|g" \
        -e "s|MODULE_PATH|$MODULE_PATH|g" \
        -e "s|APP_DESCRIPTION|$APP_DESCRIPTION|g" \
        -e "s|YEAR|$YEAR|g" \
        "$file"
done

# Rename cmd/APP_NAME to cmd/<app-name>
if [ -d "cmd/APP_NAME" ]; then
    mv "cmd/APP_NAME" "cmd/$APP_NAME"
fi

# Remove this script
rm -- "$0"

echo "Done. Next steps:"
echo "  1. Add secrets to the repo: GH_PAT, HOMEBREW_TAP_GITHUB_TOKEN"
echo "  2. Start coding in cmd/$APP_NAME/main.go"
echo "  3. Commit with conventional commits (feat:, fix:) to trigger auto-versioning"
