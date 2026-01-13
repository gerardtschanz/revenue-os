#!/bin/bash
set -euo pipefail

# Revenue OS - Session Initialization Script
# This script runs at the start of each Claude Code session

DATA_DIR="${HOME}/.claude/revenue-os"

# Ensure data directories exist
mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/outreach"
mkdir -p "$DATA_DIR/exports"

# Initialize product.json if it doesn't exist
if [[ ! -f "$DATA_DIR/product.json" ]]; then
  cat > "$DATA_DIR/product.json" << 'EOF'
{
  "name": null,
  "description": null,
  "analyzed_at": null,
  "codebase_path": null,
  "features": [],
  "tech_stack": [],
  "category": null,
  "competitors": []
}
EOF
fi

# Initialize icp.json if it doesn't exist
if [[ ! -f "$DATA_DIR/icp.json" ]]; then
  cat > "$DATA_DIR/icp.json" << 'EOF'
{
  "primary": null,
  "secondary": null,
  "created_at": null,
  "updated_at": null
}
EOF
fi

# Initialize value-prop.json if it doesn't exist
if [[ ! -f "$DATA_DIR/value-prop.json" ]]; then
  cat > "$DATA_DIR/value-prop.json" << 'EOF'
{
  "headline": null,
  "subheadline": null,
  "one_liner": null,
  "benefits": [],
  "angles": {},
  "elevator_pitch": null,
  "created_at": null
}
EOF
fi

# Initialize pricing.json if it doesn't exist
if [[ ! -f "$DATA_DIR/pricing.json" ]]; then
  cat > "$DATA_DIR/pricing.json" << 'EOF'
{
  "tiers": [],
  "psychology_applied": [],
  "competitor_pricing": [],
  "created_at": null
}
EOF
fi

# Output empty JSON to indicate success (silent - no message to user)
echo '{}'
