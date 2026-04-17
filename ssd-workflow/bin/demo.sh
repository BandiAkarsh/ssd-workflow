#!/bin/bash
#
# SSD Workflow Demo Script
# Demonstrates the SSD workflow capabilities

set -e

echo "🤖 SSD Workflow Demo"
echo "===================="
echo ""

# Check if installed
if ! command -v ssd &> /dev/null; then
  echo "❌ SSD CLI not found. Please run install.sh first."
  exit 1
fi

# Check config
if [ ! -f "$HOME/.config/ssd-workflow/config.yaml" ]; then
  echo "⚠️  Config not found. Copying example..."
  mkdir -p "$HOME/.config/ssd-workflow"
  cp "$(dirname "$0")/config.example.yaml" \
    "$HOME/.config/ssd-workflow/config.yaml"
  echo "✓ Config created. Edit $HOME/.config/ssd-workflow/config.yaml to customize."
  echo ""
fi

# Demo scenarios
echo "📋 Available Demo Scenarios:"
echo ""
echo "1. Simple Task (Auto-approve)"
echo "   Description: Add validation to existing API"
echo "   Expected: Auto-execute, no human intervention"
echo ""
echo "2. Medium Task (Execute with flag)"
echo "   Description: Create new API endpoint with tests"
echo "   Expected: Execute autonomously, flag for post-review"
echo ""
echo "3. Complex Task (Require approval)"
echo "   Description: Build authentication system"
echo "   Expected: Propose plan, wait for approval, then execute"
echo ""
echo "4. Parallel Demo"
echo "   Description: Build user dashboard (API + DB + UI)"
echo "   Expected: Decompose into parallel tasks, execute simultaneously"
echo ""

read -p "Select scenario (1-4): " scenario

case $scenario in
  1)
    TASK="Add zod validation to the existing user API endpoint in src/app/api/users/route.ts"
    ;;
  2)
    TASK="Create a new API endpoint POST /api/products with full CRUD operations and tests"
    ;;
  3)
    TASK="Build a complete authentication system with JWT, refresh tokens, and protected routes"
    ;;
  4)
    TASK="Create a user dashboard with profile management, settings, and real-time updates"
    ;;
  *)
    echo "Invalid selection"
    exit 1
    ;;
esac

echo ""
echo "🎯 Running Scenario $scenario:"
echo "   Task: $TASK"
echo ""
echo "Starting SSD orchestrator..."
echo "Press Ctrl+C to stop at any time."
echo ""
echo "--- Output ---"
echo ""

# Run the task
ssd --agent SSDOra "$TASK"

echo ""
echo "--- End Output ---"
echo ""
echo "✅ Demo complete!"
echo ""
echo "📊 Check metrics:"
echo "   cat ~/.config/ssd-workflow/logs/ssd.log"
echo ""
echo "📈 View learning database:"
echo "   ls ~/.config/ssd-workflow/context/learning/"
echo ""
echo "🔧 Configure:"
echo "   nano ~/.config/ssd-workflow/config.yaml"
echo ""
