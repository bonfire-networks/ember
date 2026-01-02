#!/usr/bin/env bash

# Exit on any error
set -e

# Get the script's directory
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source the functions file
source "$(dirname "$0")/functions.sh"

# Parse command line arguments
AUTO_YES=${AUTO_YES:-false}
for arg in "$@"; do
    case $arg in
        -y|--yes)
            echo "Existing files will be overridden without prompting"
            export AUTO_YES=true
            shift
            ;;
    esac
done

# Create necessary directories
create_dirs "lib/" "config/" "priv/extras/"

# Show mode
if [ "$AUTO_YES" = true ]; then
    echo "Running in automatic override mode (-y flag detected)"
fi

# Perform the copies with prompts
echo "Processing templates for lib/"
copy_dir_with_prompt "$SOURCE_DIR/priv/templates/lib/" "lib/"

echo -e "\nCopying deps.* files"
copy_glob_with_prompt "$SOURCE_DIR" "deps.*" "config"

echo -e "\nCopying config/"
copy_dir_with_prompt "$SOURCE_DIR/config/" "config/"

echo -e "\nCopying DB migrations"
copy_dir_with_prompt "$SOURCE_DIR/priv/repo/" "priv/repo/"

echo -e "\nCopying priv/extras/"
copy_dir_with_prompt "$SOURCE_DIR/priv/extras/" "priv/extras/"

echo -e "\nEmber installation complete"

