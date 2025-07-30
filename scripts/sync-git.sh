#!/bin/bash

set -e

BARE_REPO_DIR="/tmp/argocd-demo.git"

echo "🔄 Syncing changes to Git repository..."

# Check if we have changes to commit
if git diff --quiet && git diff --cached --quiet; then
    echo "ℹ️  No changes to sync"
    exit 0
fi

# Stage all changes if not already staged
if ! git diff --cached --quiet; then
    echo "📝 Changes already staged"
else
    echo "📝 Staging all changes..."
    git add .
fi

# Commit changes if not already committed
if git diff --cached --quiet; then
    echo "✅ Changes already committed"
else
    echo "💾 Committing changes..."
    git commit -m "Update applications - $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Push to bare repository
if [ -d "$BARE_REPO_DIR" ]; then
    echo "🚀 Pushing to bare repository..."
    git push "$BARE_REPO_DIR" HEAD:main --force
    echo "✅ Changes synced successfully!"
    echo ""
    echo "🔍 ArgoCD should detect changes within ~3 minutes"
    echo "🌐 Check ArgoCD UI: https://localhost:30443"
else
    echo "❌ Bare repository not found at $BARE_REPO_DIR"
    echo "   Run ./scripts/init-git.sh first"
    exit 1
fi