#!/bin/bash
# Rebuild the site and push it live to GitHub Pages.
# Run this after recompiling any deck.  Usage:  ./publish.sh
set -euo pipefail
cd "$(dirname "$0")"

./build.sh

if ! git remote get-url origin >/dev/null 2>&1; then
  echo
  echo "No GitHub remote set yet. Run this once:"
  echo "  git remote add origin https://github.com/USERNAME/eh2.git"
  exit 1
fi

git add -A
if git diff --cached --quiet; then
  echo "Nothing changed."
  exit 0
fi
git commit -m "Update slides $(date '+%Y-%m-%d %H:%M')"
git push origin main
echo
echo "Live in ~1 minute at: https://$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+)(\.git)?#\1.github.io/\2#')/"
