#!/bin/bash
# Wrapper script to run sticker-importer from project root
# Usage: ./import-stickers.sh /path/to/stickers --ai-label

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/tools/sticker_importer" && uv run python main.py "$@"
