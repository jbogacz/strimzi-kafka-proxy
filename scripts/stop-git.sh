#!/bin/bash

echo "🛑 Stopping Git servers..."

# Stop git daemon
if [ -f /tmp/git-daemon.pid ]; then
    PID=$(cat /tmp/git-daemon.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "🛑 Stopping Git daemon (PID: $PID)..."
        kill $PID
        rm -f /tmp/git-daemon.pid
    else
        echo "ℹ️  Git daemon not running"
        rm -f /tmp/git-daemon.pid
    fi
else
    # Fallback: kill by process name
    if pgrep -f "git daemon" > /dev/null; then
        echo "🛑 Stopping Git daemon..."
        pkill -f "git daemon"
    else
        echo "ℹ️  Git daemon not running"
    fi
fi

# Stop HTTP server
if [ -f /tmp/git-http-server.pid ]; then
    PID=$(cat /tmp/git-http-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "🛑 Stopping Git HTTP server (PID: $PID)..."
        kill $PID
        rm -f /tmp/git-http-server.pid
    else
        echo "ℹ️  Git HTTP server not running"
        rm -f /tmp/git-http-server.pid
    fi
else
    # Fallback: kill by process name
    if pgrep -f "python3 -m http.server" > /dev/null; then
        echo "🛑 Stopping Git HTTP server..."
        pkill -f "python3 -m http.server"
    else
        echo "ℹ️  Git HTTP server not running"
    fi
fi

# Clean up bare repository
BARE_REPO_DIR="/tmp/argocd-demo.git"
if [ -d "$BARE_REPO_DIR" ]; then
    echo "🗑️  Removing bare repository..."
    rm -rf "$BARE_REPO_DIR"
fi

echo "✅ Git servers stopped and cleaned up"