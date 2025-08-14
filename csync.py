#!/usr/bin/env python3
"""Wrapper script to run csync from the configs directory."""

import sys
from pathlib import Path

# Add csync to path
sys.path.insert(0, str(Path(__file__).parent / "csync" / "src"))

from csync.cli import main

if __name__ == "__main__":
    main()