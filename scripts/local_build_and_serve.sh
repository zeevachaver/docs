#!/bin/bash
set -euo pipefail

# Resolve absolute path of this script
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Root of the docs repo
DOCS_REPO_ROOT="$(realpath "$SCRIPT_DIR/..")"
EXTERNAL_DIR="$DOCS_REPO_ROOT/docs"

# Read repo names from file
REPO_NAMES=($(<"$DOCS_REPO_ROOT/repos.txt"))

# Check for .github* repo
GH_REPO=$(find "$DOCS_REPO_ROOT/../.github"* -maxdepth 0 -type d 2>/dev/null)
if [[ -d "$GH_REPO" ]]; then
  REPO_NAMES+=("$(basename "$GH_REPO")")
fi

# --- CLEANUP FUNCTION ---
cleanup() {
  echo "Cleaning up generated links and files..."

  # delete the hard-linked repo directories
  # only delete directories that match names in our REPO_NAMES list
  for NAME in "${REPO_NAMES[@]}"; do
    # skip .github just in case someone mistakingly adds it to repos.txt
    if [[ "$NAME" == .github* ]]; then continue; fi

    TARGET="$EXTERNAL_DIR/$(basename "$NAME")"
    if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
       rm -rf "$TARGET"
    fi
  done

  # Clean up specific files linked from .github repo into root docs
  if [[ -n "${GH_REPO:-}" ]]; then
     find "$EXTERNAL_DIR" -maxdepth 1 -type f -links +1 -delete
     # Clean up assets specifically from .github
     find "$EXTERNAL_DIR/assets" -type f -links +1 -delete 2>/dev/null || true
  fi

  # remove generated site/ dir
  if [ -d site ]; then
    rm -rf site
  fi
}

# Initial clean
cleanup

# Build full paths
REPOS=()
for NAME in "${REPO_NAMES[@]}"; do
  REPO_PATH="$(realpath "$DOCS_REPO_ROOT/../$NAME" 2>/dev/null || true)"
  if [ -z "$REPO_PATH" ] || [ ! -d "$REPO_PATH" ]; then
    echo "⚠️ Skipping $NAME: local repo not found"
    continue
  fi
  REPOS+=("$REPO_PATH")
done

# --- LINKING ---
for REPO_PATH in "${REPOS[@]}"; do
  REPO_NAME="$(basename "$REPO_PATH")"
  DOCS_SRC="$REPO_PATH/docs"

  if [ -d "$DOCS_SRC" ] && [[ "$REPO_NAME" != .github* ]]; then
    DEST_DIR="$EXTERNAL_DIR/$REPO_NAME"
    echo "🔗 Hard-linking $REPO_NAME docs..."
    mkdir -p "$DEST_DIR"
    cp -al "$DOCS_SRC/." "$DEST_DIR/"
    echo "✅ Created hard-link tree → $DEST_DIR"

  elif [[ "$REPO_NAME" == .github* ]]; then
    echo "🔗 Hard-linking .github files to root docs..."
    for SRC_FILE in "$REPO_PATH"/*.md; do
        [ -e "$SRC_FILE" ] || continue
        FILENAME=$(basename "$SRC_FILE")
        DEST_FILE="$EXTERNAL_DIR/$FILENAME"
        ln "$SRC_FILE" "$DEST_FILE" # Hard link
        echo "✅ Linked $FILENAME"
    done

    # Assets linking
    ASSETS_SRC="$REPO_PATH/assets"
    ASSETS_DEST="$EXTERNAL_DIR/assets"
    if [ -d "$ASSETS_SRC" ]; then
        mkdir -p "$ASSETS_DEST"
        cp -al "$ASSETS_SRC/." "$ASSETS_DEST/"
        echo "✅ Hard-linked assets"
    fi
  else
    echo "⚠️ Skipping $REPO_NAME: no docs directory found"
  fi
done

echo "Generating zensical.generated.toml ..."
python "$DOCS_REPO_ROOT/scripts/generate_zensical.py"

echo "Starting local Zensical server..."
# ensure cleanup happens even if user hits Ctrl+C
trap cleanup EXIT

zensical serve -f "$DOCS_REPO_ROOT/zensical.generated.toml"

echo "✅ Done."