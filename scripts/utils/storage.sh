#!/bin/bash
# Revenue OS - Storage Utilities
# Helper functions for reading/writing Revenue OS data

DATA_DIR="${HOME}/.claude/revenue-os"

# Ensure data directories exist
ensure_data_dirs() {
  mkdir -p "$DATA_DIR"
  mkdir -p "$DATA_DIR/outreach"
  mkdir -p "$DATA_DIR/exports"
}

# Product functions
read_product() {
  cat "$DATA_DIR/product.json" 2>/dev/null || echo '{"name": null}'
}

write_product() {
  local data="$1"
  ensure_data_dirs
  echo "$data" | jq '.' > "$DATA_DIR/product.json"
}

get_product_name() {
  read_product | jq -r '.name // "Not Analyzed"'
}

# ICP functions
read_icp() {
  cat "$DATA_DIR/icp.json" 2>/dev/null || echo '{"primary": null}'
}

write_icp() {
  local data="$1"
  ensure_data_dirs
  echo "$data" | jq '.' > "$DATA_DIR/icp.json"
}

get_primary_icp() {
  read_icp | jq -r '.primary.name // "Not Defined"'
}

# Value Prop functions
read_value_prop() {
  cat "$DATA_DIR/value-prop.json" 2>/dev/null || echo '{"headline": null}'
}

write_value_prop() {
  local data="$1"
  ensure_data_dirs
  echo "$data" | jq '.' > "$DATA_DIR/value-prop.json"
}

# Pricing functions
read_pricing() {
  cat "$DATA_DIR/pricing.json" 2>/dev/null || echo '{"tiers": []}'
}

write_pricing() {
  local data="$1"
  ensure_data_dirs
  echo "$data" | jq '.' > "$DATA_DIR/pricing.json"
}

# Outreach functions
list_outreach() {
  ls -1 "$DATA_DIR/outreach/" 2>/dev/null || echo ""
}

count_outreach() {
  ls -1 "$DATA_DIR/outreach/" 2>/dev/null | wc -l | tr -d ' '
}

save_outreach() {
  local name="$1"
  local content="$2"
  ensure_data_dirs
  echo "$content" > "$DATA_DIR/outreach/${name}.md"
}

# Score calculation
calculate_score() {
  local score=0

  # Product (15 points)
  local product_name=$(get_product_name)
  if [[ "$product_name" != "Not Analyzed" && "$product_name" != "null" ]]; then
    score=$((score + 15))
  fi

  # ICP (25 points)
  local icp_name=$(get_primary_icp)
  if [[ "$icp_name" != "Not Defined" && "$icp_name" != "null" ]]; then
    score=$((score + 25))
  fi

  # Value Prop (25 points)
  local headline=$(read_value_prop | jq -r '.headline // "null"')
  if [[ "$headline" != "null" ]]; then
    score=$((score + 25))
  fi

  # Pricing (15 points)
  local tiers=$(read_pricing | jq '.tiers | length')
  if [[ "$tiers" -gt 0 ]]; then
    score=$((score + 15))
  fi

  # Outreach (10 points)
  local outreach_count=$(count_outreach)
  if [[ "$outreach_count" -gt 0 ]]; then
    score=$((score + 10))
  fi

  # Distribution (10 points) - placeholder
  # score=$((score + 10))

  echo "$score"
}

# Export data
export_all() {
  local export_dir="$DATA_DIR/exports"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local export_file="$export_dir/revenue-os-export-$timestamp.json"

  ensure_data_dirs

  jq -n \
    --slurpfile product "$DATA_DIR/product.json" \
    --slurpfile icp "$DATA_DIR/icp.json" \
    --slurpfile value_prop "$DATA_DIR/value-prop.json" \
    --slurpfile pricing "$DATA_DIR/pricing.json" \
    '{
      exported_at: now | strftime("%Y-%m-%dT%H:%M:%SZ"),
      product: $product[0],
      icp: $icp[0],
      value_prop: $value_prop[0],
      pricing: $pricing[0]
    }' > "$export_file"

  echo "$export_file"
}

# Reset all data
reset_all() {
  rm -f "$DATA_DIR/product.json"
  rm -f "$DATA_DIR/icp.json"
  rm -f "$DATA_DIR/value-prop.json"
  rm -f "$DATA_DIR/pricing.json"
  rm -rf "$DATA_DIR/outreach/"*

  # Re-initialize
  source "${BASH_SOURCE%/*}/../core/init-session.sh"
}

# Main - if script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Revenue OS Storage Utilities"
  echo ""
  echo "Available functions:"
  echo "  read_product, write_product, get_product_name"
  echo "  read_icp, write_icp, get_primary_icp"
  echo "  read_value_prop, write_value_prop"
  echo "  read_pricing, write_pricing"
  echo "  list_outreach, count_outreach, save_outreach"
  echo "  calculate_score"
  echo "  export_all"
  echo "  reset_all"
  echo ""
  echo "Source this file to use: source storage.sh"
fi
