#!/usr/bin/env bash
set -euo pipefail
if [ ! -f server.js ]; then
  echo "server.js not found in current directory."
  exit 1
fi

# RPC to env-based
perl -0777 -pe "s|new Connection\(['\"]https?://[^'\"]+['\"],\s*'confirmed'\)|new Connection(process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com', 'confirmed')|g" -i server.js

# Branding swaps
sed -i '' -e "s/JUNKNET server running/ZCOIN Launchpad server running/g" server.js 2>/dev/null || sed -i -e "s/JUNKNET server running/ZCOIN Launchpad server running/g" server.js
sed -i '' -e "s/JUNKNET/ZCOIN Launchpad/g" server.js 2>/dev/null || sed -i -e "s/JUNKNET/ZCOIN Launchpad/g" server.js
sed -i '' -e "s/\\bJUNK\\b/ZCOIN/g" server.js 2>/dev/null || sed -i -e "s/\\bJUNK\\b/ZCOIN/g" server.js

# createdOn URL swap to brand
sed -i '' -e "s|https://junknet\\.dev/|https://0xzerebro.io/|g" server.js 2>/dev/null || sed -i -e "s|https://junknet\\.dev/|https://0xzerebro.io/|g" server.js

# fallback image name normalization
sed -i '' -e "s|public/[A-Za-z0-9_-]*\\.png|public/zcoin.png|g" server.js 2>/dev/null || true

echo "Patched server.js for ZCOIN Launchpad with https://0xzerebro.io branding."
