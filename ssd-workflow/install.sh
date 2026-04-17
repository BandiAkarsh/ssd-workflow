#!/bin/bash
#
# SSD Workflow Installation Script
# Installs the Self-Determining System Development workflow
#
# Usage: ./install.sh [developer|team|global]

set -e  # Exit on error

INSTALL_TYPE="${1:-developer}"
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
cp -r . "$INSTALL_DIR/"

# Set up symlinks
echo "🔗 Setting up symlinks..."
ln -sf "$INSTALL_DIR/ssd-workflow/bin/ssd" /usr/local/bin/ssd 2>/dev/null || \
  echo "⚠️  Could not create /usr/local/bin/ssd (run with sudo if needed)"

# Install dependencies if package.json exists
if [ -f "$INSTALL_DIR/ssd-workflow/package.json" ]; then
  echo "📦 Installing dependencies..."
  cd "$INSTALL_DIR/ssd-workflow"
  
  if command -v bun &> /dev/null; then
    bun install
  elif command -v npm &> /dev/null; then
    npm install
  else
    echo "⚠️  No package manager found (bun/npm). Skipping dependencies."
  fi
fi

# Run post-install
if [ -f "$INSTALL_DIR/ssd-workflow/install-post.sh" ]; then
  echo "⚙️  Running post-install..."
  bash "$INSTALL_DIR/ssd-workflow/install-post.sh"
fi

# Create initial config
echo "⚙️  Setting up configuration..."
mkdir -p "$HOME/.config/ssd-workflow"
if [ ! -f "$HOME/.config/ssd-workflow/config.yaml" ]; then
  cp "$INSTALL_DIR/ssd-workflow/config.example.yaml" \
    "$HOME/.config/ssd-workflow/config.yaml"
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
echo "  $INSTALL_DIR/ssd-workflow/README.md"
echo "  $INSTALL_DIR/ssd-workflow/docs/architecture.md"
echo ""
echo "🔧 Configuration:"
echo "  $HOME/.config/ssd-workflow/config.yaml"
echo ""
echo "Happy autonomous coding! 🤖"
