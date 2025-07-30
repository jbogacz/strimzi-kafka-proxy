#!/bin/bash

set -e

GIT_SERVER_PORT=${GIT_SERVER_PORT:-9418}
GIT_HTTP_PORT=${GIT_HTTP_PORT:-8090}

echo "🔧 Initializing Git repository and server..."

# Initialize git repo if not already initialized
if [ ! -d ".git" ]; then
    echo "📝 Initializing Git repository..."
    git init
    git config user.name "ArgoCD Demo"
    git config user.email "demo@argocd.local"
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
.DS_Store
*.log
.env
EOF
    
    # Initial commit
    git add .
    git commit -m "Initial commit: ArgoCD app-of-apps setup"
else
    echo "✅ Git repository already initialized"
fi

# Stop existing git daemon if running
if pgrep -f "git daemon" > /dev/null; then
    echo "🛑 Stopping existing git daemon..."
    pkill -f "git daemon" || true
    sleep 2
fi

# Stop existing git http server if running
if pgrep -f "git http-backend" > /dev/null; then
    echo "🛑 Stopping existing git http server..."
    pkill -f "git http-backend" || true
    sleep 2
fi

# Create bare repository for serving
BARE_REPO_DIR="/tmp/argocd-demo.git"
if [ -d "$BARE_REPO_DIR" ]; then
    rm -rf "$BARE_REPO_DIR"
fi

echo "📁 Creating bare repository at $BARE_REPO_DIR..."
git clone --bare . "$BARE_REPO_DIR"
cd "$BARE_REPO_DIR"
git config daemon.receivepack true
git config http.receivepack true
cd - > /dev/null

# Start git daemon in background
echo "🚀 Starting Git daemon on port $GIT_SERVER_PORT..."
git daemon --reuseaddr --base-path=/tmp --export-all --verbose --enable=receive-pack --port=$GIT_SERVER_PORT &
GIT_DAEMON_PID=$!
echo $GIT_DAEMON_PID > /tmp/git-daemon.pid

# Start simple HTTP server for Git over HTTP
echo "🌐 Starting Git HTTP server on port $GIT_HTTP_PORT..."
cd /tmp
python3 -m http.server $GIT_HTTP_PORT &
HTTP_SERVER_PID=$!
echo $HTTP_SERVER_PID > /tmp/git-http-server.pid
cd - > /dev/null

# Wait a moment for servers to start
sleep 2

# Test git daemon
echo "🧪 Testing Git daemon..."
if git ls-remote git://localhost:$GIT_SERVER_PORT/argocd-demo.git > /dev/null 2>&1; then
    echo "✅ Git daemon is working"
else
    echo "❌ Git daemon test failed"
fi

# Add remote for pushing changes
git remote remove origin 2>/dev/null || true
git remote add origin git://localhost:$GIT_SERVER_PORT/argocd-demo.git

echo "✅ Git setup complete!"
echo ""
echo "📝 Git Repository Information:"
echo "  📍 Local repo: $(pwd)"
echo "  📍 Bare repo: $BARE_REPO_DIR"
echo "  🌐 Git daemon: git://localhost:$GIT_SERVER_PORT/argocd-demo.git"
echo "  🌐 HTTP server: http://localhost:$GIT_HTTP_PORT/argocd-demo.git"
echo ""
echo "🔧 To push changes:"
echo "  git add ."
echo "  git commit -m 'Your changes'"
echo "  ./scripts/sync-git.sh"