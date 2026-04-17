#!/bin/bash
#
# SSD Workflow Installation Script
# Installs the Self-Determining System Development workflow
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/BandiAkarsh/ssd-workflow/main/install.sh | bash
#   ./install.sh [developer|team|global]
#

set -e  # Exit on error

# Detect if running from pipe (remote) or local
if [ -t 0 ]; then
    # Running locally
    INSTALL_TYPE="${1:-developer}"
    SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    # Running from curl pipe - clone repo first
    echo "📥 Downloading SSD Workflow from GitHub..."
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Clone or download
    if command -v git &> /dev/null; then
        git clone --depth 1 https://github.com/BandiAkarsh/ssd-workflow "$TEMP_DIR/ssd-workflow"
    else
        curl -fsSL https://github.com/BandiAkarsh/ssd-workflow/archive/refs/heads/main.tar.gz -o "$TEMP_DIR/ssd.tar.gz"
        tar -xzf "$TEMP_DIR/ssd.tar.gz" -C "$TEMP_DIR"
        mv "$TEMP_DIR/ssd-workflow-main" "$TEMP_DIR/ssd-workflow"
    fi
    
    SOURCE_DIR="$TEMP_DIR/ssd-workflow"
    INSTALL_TYPE="${1:-developer}"
fi

INSTALL_DIR="${INSTALL_DIR:-$HOME/.config/ssd-workflow}"

echo "🚀 Installing SSD Workflow..."
echo "📦 Type: $INSTALL_TYPE"
echo "📁 Install dir: $INSTALL_DIR"
echo ""

# Check prerequisites
echo "✓ Checking prerequisites..."

if ! command -v git &> /dev/null; then
    echo "❌ Git is required. Install git first."
    exit 1
fi

if ! command -v node &> /dev/null && ! command -v bun &> /dev/null; then
    echo "⚠️  Node.js or Bun recommended but not required"
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Copy files
echo "📋 Copying files..."
cp -rf "$SOURCE_DIR/"* "$INSTALL_DIR/"

# Set up symlinks
echo "🔗 Setting up symlinks..."
if [ -w "/usr/local/bin" ]; then
    ln -sf "$INSTALL_DIR/bin/ssd" /usr/local/bin/ssd
else
    # Fallback to user's PATH
    mkdir -p "$HOME/.local/bin"
    ln -sf "$INSTALL_DIR/bin/ssd" "$HOME/.local/bin/ssd"
    echo "⚠️  Added to ~/.local/bin - add to your PATH if needed"
fi

# Install dependencies if package.json exists
if [ -f "$INSTALL_DIR/package.json" ]; then
    echo "📦 Installing dependencies..."
    cd "$INSTALL_DIR"
    
    if command -v bun &> /dev/null; then
        bun install
    elif command -v npm &> /dev/null; then
        npm install
    else
        echo "⚠️  No package manager found (bun/npm). Skipping dependencies."
    fi
fi

# Run post-install
if [ -f "$INSTALL_DIR/install-post.sh" ]; then
    echo "⚙️  Running post-install..."
    bash "$INSTALL_DIR/install-post.sh"
fi

# Create initial config
echo "⚙️  Setting up configuration..."
mkdir -p "$HOME/.config/ssd-workflow"
if [ ! -f "$HOME/.config/ssd-workflow/config.yaml" ]; then
    cp "$INSTALL_DIR/config.example.yaml" "$HOME/.config/ssd-workflow/config.yaml"
fi

# Create context directory with default context files
echo "📚 Setting up context files..."
mkdir -p "$HOME/.config/ssd-workflow/context"

# Copy context files from installation
if [ -d "$INSTALL_DIR/context" ]; then
    cp -rf "$INSTALL_DIR/context/"* "$HOME/.config/ssd-workflow/context/"
fi

# If no context files exist, create basic ones
if [ ! -f "$HOME/.config/ssd-workflow/context/core.md" ]; then
    cat > "$HOME/.config/ssd-workflow/context/core.md" << 'CTXEOF'
# Core Development Context

This is the core context file for SSD workflow. It defines the fundamental
development patterns and practices that all agents should follow.

## Core Principles

1. **Self-Determining**: Agents should be autonomous and self-directed
2. **Continuous Learning**: Always improve from feedback and outcomes
3. **Dynamic Context**: Load context dynamically based on task requirements
4. **Parallel Execution**: Execute independent tasks concurrently
5. **Self-Healing**: Automatically detect and fix issues when possible

## Code Quality Standards

- Write modular, functional code
- Add meaningful comments that explain "why" not "what"
- Follow language-specific conventions
- Use proper type systems
- Prefer declarative over imperative patterns

## Self-Updating

This context file can self-update. When patterns or best practices change,
the system should update this file automatically.
CTXEOF
fi

# Success
echo ""
echo "✅ SSD Workflow installed successfully!"
echo ""
echo "📖 Quick start:"
echo "  ssd --agent SSDOra"
echo "  > \"Build a user authentication system\""
echo ""
echo "📚 Documentation:"
echo "  $INSTALL_DIR/README.md"
echo "  $INSTALL_DIR/docs/architecture.md"
echo ""
echo "🔧 Configuration:"
echo "  $HOME/.config/ssd-workflow/config.yaml"
echo ""
echo "📁 Context Files:"
echo "  $HOME/.config/ssd-workflow/context/"
echo ""
echo "Happy autonomous coding! 🤖"