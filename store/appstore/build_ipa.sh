#!/usr/bin/env bash
# Build a release IPA and (optionally) upload to App Store Connect.
set -euo pipefail
cd "$(dirname "$0")/../.."

if [[ ! -f assets/env/env.json ]]; then
  echo "Missing assets/env/env.json (API key). Add it before a store build." >&2
  exit 1
fi

flutter build ipa --release \
  --export-options-plist=store/appstore/exportOptions.plist

echo
echo "IPA: build/ios/ipa/"
ls -la build/ios/ipa/ 2>/dev/null || true
echo
echo "Next: App Store Connect → TestFlight (wait for processing), then submit for review."
echo "Listing text: store/appstore/listing.md"
