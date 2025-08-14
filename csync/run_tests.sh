#!/bin/bash
# Script to run csync tests with proper validation

set -e  # Exit on error

echo "🧪 Running csync gitignore compliance tests..."
echo "================================================"

# Ensure we're in the csync directory
cd "$(dirname "$0")"

# Install dependencies if needed
echo "📦 Installing dependencies..."
uv sync --dev

# Run the tests
echo ""
echo "🔍 Running tests..."
uv run pytest tests/test_gitignore_compliance.py -v --tb=short

# Check the exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed! The .gitignore compliance is verified."
    echo ""
    echo "Summary:"
    echo "- ✓ __pycache__ directories are never committed"
    echo "- ✓ .git directory contents are never committed"
    echo "- ✓ .local files are never committed"
    echo "- ✓ Syncer respects .gitignore when committing"
    echo "- ✓ Previously tracked ignored files can be untracked"
    echo "- ✓ Comprehensive gitignore patterns work correctly"
    echo "- ✓ No dangerous git add patterns in code"
    echo ""
    echo "🛡️  Your csync is protected against committing ignored files!"
else
    echo ""
    echo "❌ Some tests failed. Please review the output above."
    exit 1
fi