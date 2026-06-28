#!/usr/bin/env bash

# is_older - Check if a version string is strictly older than another.
#
# Usage:
#   is_older <version1> <version2>
#
# Arguments:
#   version1  The version to test (e.g. "1.2.3")
#   version2  The version to compare against (e.g. "2.0.0")
#
# Returns:
#   0  if version1 is strictly older than version2
#   1  otherwise (version1 is equal to or newer than version2)
#
# Examples:
#   is_older "1.2.3" "2.0.0"  # returns 0 (older)
#   is_older "1.10" "1.9"     # returns 1 (newer)
#   is_older "1.5" "1.5"      # returns 1 (equal)
is_older() {
    printf '%s\n' "$1" "$2" | sort -C -V && [ "$1" != "$2" ]
}

# get_latest_release - Fetch the latest release tag from a GitHub repository.
#
# Usage:
#   get_latest_release <owner/repo>
#
# Arguments:
#   owner/repo  The GitHub repository slug (e.g. "creativeprojects/resticprofile")
#
# Returns:
#   Prints the latest release tag (e.g. "v0.34.0") to stdout
get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

# --- Config ---
REPO="creativeprojects/resticprofile"
BINARY="/usr/bin/resticprofile"
DOWNLOAD_DIR="/home/$USER/Downloads"

# --- Get local version ---
echo "=> Checking local version..."
local_version=$(
    strings "$BINARY" \
        | grep -P '^mod\s+github.com/creativeprojects/resticprofile\s+v\d+\.\d+\.\d+' \
        | grep -oP 'v\d+\.\d+\.\d+' \
        | head -n1
)

if [ -z "$local_version" ]; then
    echo "error: could not determine local version from $BINARY" >&2
    exit 2
fi

echo "   local version:  $local_version"

# --- Get latest remote version ---
echo "=> Fetching latest version from GitHub..."
latest_version=$(get_latest_release "$REPO")

if [ -z "$latest_version" ]; then
    echo "error: could not fetch latest version from GitHub" >&2
    exit 2
fi

echo "   latest version: $latest_version"

# --- Compare and report ---
if ! is_older "$local_version" "$latest_version"; then
    echo "=> You are up to date ($local_version)"
    exit 1
fi

echo ""
echo "=> New version detected: $latest_version (you have $local_version)"
echo "   Release page: https://github.com/$REPO/releases/tag/$latest_version"
echo ""

# --- Ask user ---
read -r -p "Do you want to update? [y/N] " answer
answer="${answer:-N}"

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "=> Skipping update."
    exit 0
fi

# --- Build download URL ---
# Strip leading 'v' from version for the filename (e.g. v0.34.0 -> 0.34.0)
version_num="${latest_version#v}"
tarball="resticprofile_${version_num}_linux_amd64.tar.gz"
download_url="https://github.com/$REPO/releases/download/$latest_version/$tarball"
tarball_path="$DOWNLOAD_DIR/$tarball"
extract_dir="$DOWNLOAD_DIR/resticprofile_${version_num}"

# --- Download ---
echo ""
echo "=> Downloading $tarball..."
curl --progress-bar -L "$download_url" -o "$tarball_path"
if [ $? -ne 0 ]; then
    echo "error: download failed" >&2
    exit 2
fi
echo "   Saved to $tarball_path"

# --- Extract ---
echo "=> Extracting tarball..."
mkdir -p "$extract_dir"
tar -xzf "$tarball_path" -C "$extract_dir"
if [ $? -ne 0 ]; then
    echo "error: extraction failed" >&2
    exit 2
fi
echo "   Extracted to $extract_dir"

# --- Backup old binary ---
echo "=> Backing up current binary to ${BINARY}~..."
sudo cp "$BINARY" "${BINARY}~"
if [ $? -ne 0 ]; then
    echo "error: backup failed" >&2
    exit 2
fi
echo "   Backup done."

# --- Install new binary ---
echo "=> Installing new binary to $BINARY..."
sudo cp "$extract_dir/resticprofile" "$BINARY"
if [ $? -ne 0 ]; then
    echo "error: install failed" >&2
    exit 2
fi

echo ""
echo "=> Done! resticprofile updated to $latest_version"
exit 0
