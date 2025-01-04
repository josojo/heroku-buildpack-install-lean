   #!/bin/bash
   set -e

   echo "Starting REPL setup..."

   # Check if git is installed
	if ! command -v git &> /dev/null
	then
	    echo "Git could not be found. Please ensure Git is installed."
	    exit 1
	fi


   PWD=$(pwd)
   WORK_DIR="$PWD/repl"
   mkdir -p "$WORK_DIR"
   cd "$WORK_DIR"

   echo "Current PATH: $PATH"
   echo "Current directory: $(pwd)"
   echo "Listing available commands:"
   which git || echo "git not found"

   # Install Elan
   curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y

   # Add Elan to PATH
   export PATH="$HOME/.elan/bin:$PATH"

   # Clone REPL repository
   echo "Cloning REPL repository..."
   git clone https://github.com/leanprover-community/repl.git
   cd repl

   # Install Lean version as specified in lean-toolchain
   LEAN_VERSION=$(cat lean-toolchain)
   elan default $LEAN_VERSION

   # Build REPL
   lake update
   lake build
   cd test/Mathlib
   echo "Downloading Mathlib..."
   lake exe cache get > /dev/null


   # Add a marker file to indicate successful installation
   touch "$WORK_DIR/.keep"
   echo "Listing all files in REPL directory $WORK_DIR:"
   ls -al "$WORK_DIR"

   # copy all files into a new non temp directory
   mkdir -p /usr/test/repl
   cp -r $WORK_DIR/* /usr/test/repl
   

   echo "REPL setup completed successfully"
