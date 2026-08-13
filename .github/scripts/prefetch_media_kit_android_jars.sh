#!/usr/bin/env bash
# Prefetch media_kit Android libmpv jars with retries so Gradle config-time
# URL.openStream() (no retries) does not fail on flaky GitHub CDN responses.
set -euo pipefail

DEST_DIR="${1:-build/media_kit_libs_android_video/v1.1.5}"
BASE_URL="https://github.com/Schnitzel5/libmpv-android-video-build/releases/download/0.39.0"
MAX_ATTEMPTS=5

# name|md5 — must match media_kit_libs_android_video android/build.gradle
JARS=(
  "default-arm64-v8a.jar|fa551194ff736b0a583e47cbfd852b95"
  "default-armeabi-v7a.jar|12fa59f5f8f402f8f9589f9b5d5499af"
  "default-x86_64.jar|23509af7af1b6a827dcb6aaf200a1622"
  "default-x86.jar|663308fd48a2d3da61b1802985db390f"
)

mkdir -p "$DEST_DIR"

download_one() {
  local name="$1"
  local expected_md5="$2"
  local out="${DEST_DIR}/${name}"
  local url="${BASE_URL}/${name}"
  local attempt

  if [[ -f "$out" ]]; then
    local existing
    existing="$(md5sum "$out" | awk '{print $1}')"
    if [[ "$existing" == "$expected_md5" ]]; then
      echo "Already present and verified: $out"
      return 0
    fi
    echo "MD5 mismatch for existing $out (got $existing); re-downloading"
    rm -f "$out"
  fi

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    echo "Downloading $name (attempt ${attempt}/${MAX_ATTEMPTS})..."
    rm -f "$out"
    if curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 \
      --connect-timeout 30 --max-time 300 \
      -o "$out" "$url"; then
      local got
      got="$(md5sum "$out" | awk '{print $1}')"
      if [[ "$got" == "$expected_md5" ]]; then
        echo "Verified $name ($got)"
        return 0
      fi
      echo "MD5 mismatch for $name (got $got, expected $expected_md5)"
    else
      echo "curl failed for $name on attempt ${attempt}"
    fi
    rm -f "$out"
    sleep $((attempt * 2))
  done

  echo "Failed to download and verify $name after ${MAX_ATTEMPTS} attempts" >&2
  return 1
}

for entry in "${JARS[@]}"; do
  IFS='|' read -r name md5 <<<"$entry"
  download_one "$name" "$md5"
done

echo "All media_kit Android jars prefetched into $DEST_DIR"
