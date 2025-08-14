"""Comprehensive tests to ensure .gitignore files are ALWAYS respected."""

import shutil
import tempfile
from pathlib import Path
from unittest.mock import MagicMock

import git
import pytest

from csync.config import Config
from csync.sync import Syncer


class TestGitignoreCompliance:
    """Test suite to ensure .gitignore rules are always respected."""

    @pytest.fixture
    def temp_repo(self):
        """Create a temporary git repository for testing."""
        temp_dir = tempfile.mkdtemp()
        repo = git.Repo.init(temp_dir)

        # Create a comprehensive .gitignore file
        gitignore_content = """
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
*.egg-info/
.venv/
venv/
ENV/

# Git internals - NEVER commit these
.git/
.git/*
.git/**/*

# Local/private files
*.local
*.local.*
.local/
settings.local.json
.env
.envrc

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Claude
.claude/
*.claude.md
"""
        gitignore_path = Path(temp_dir) / ".gitignore"
        gitignore_path.write_text(gitignore_content)

        # Initial commit with gitignore
        repo.index.add([".gitignore"])
        repo.index.commit("Initial commit with .gitignore")

        yield temp_dir, repo

        # Cleanup
        shutil.rmtree(temp_dir, ignore_errors=True)

    def test_pycache_never_added(self, temp_repo):
        """Test that __pycache__ directories are NEVER added to git."""
        temp_dir, repo = temp_repo

        # Create __pycache__ directories with files
        pycache_dir = Path(temp_dir) / "src" / "__pycache__"
        pycache_dir.mkdir(parents=True)
        (pycache_dir / "test.cpython-311.pyc").write_text("bytecode")
        (pycache_dir / "another.cpython-311.pyc").write_text("bytecode")

        # Create a valid Python file that should be added
        src_dir = Path(temp_dir) / "src"
        (src_dir / "valid_file.py").write_text("print('hello')")

        # Use git add with --all flag (same as our fix)
        repo.git.add("--all", ".")

        # Get staged files
        staged_files = [item.a_path for item in repo.index.diff("HEAD")]

        # Assert __pycache__ is NOT in staged files
        assert not any("__pycache__" in path for path in staged_files), (
            f"__pycache__ was added to git! Staged files: {staged_files}"
        )

        # Assert valid file IS staged
        assert any("valid_file.py" in path for path in staged_files), (
            "Valid Python file was not staged"
        )

    def test_git_directory_never_added(self, temp_repo):
        """Test that .git directory contents are NEVER added."""
        temp_dir, repo = temp_repo

        # Try to add files that look like .git internals
        git_test_dir = Path(temp_dir) / ".git"
        test_file = git_test_dir / "test_file"
        test_file.write_text("should not be added")

        # Create a normal file that should be added
        normal_file = Path(temp_dir) / "normal.txt"
        normal_file.write_text("this should be added")

        # Use git add with --all flag
        repo.git.add("--all", ".")

        # Get staged files
        staged_files = [item.a_path for item in repo.index.diff("HEAD")]

        # Assert .git files are NOT staged
        assert not any(".git/" in path for path in staged_files), (
            f".git files were added! Staged files: {staged_files}"
        )

        # Assert normal file IS staged
        assert any("normal.txt" in path for path in staged_files), (
            "Normal file was not staged"
        )

    def test_local_files_never_added(self, temp_repo):
        """Test that .local files and settings.local.json are NEVER added."""
        temp_dir, repo = temp_repo

        # Create various .local files
        Path(temp_dir, "config.local").write_text("local config")
        Path(temp_dir, "settings.local.json").write_text('{"key": "value"}')
        Path(temp_dir, ".local").mkdir()
        Path(temp_dir, ".local", "data.txt").write_text("local data")

        # Create normal files
        Path(temp_dir, "config.json").write_text('{"key": "value"}')

        # Use git add with --all flag
        repo.git.add("--all", ".")

        # Get staged files
        staged_files = [item.a_path for item in repo.index.diff("HEAD")]

        # Assert .local files are NOT staged
        assert not any(".local" in path for path in staged_files), (
            f".local files were added! Staged files: {staged_files}"
        )
        assert not any("settings.local.json" in path for path in staged_files), (
            f"settings.local.json was added! Staged files: {staged_files}"
        )

        # Assert normal config IS staged
        assert any("config.json" in path for path in staged_files), (
            "Normal config file was not staged"
        )

    def test_syncer_respects_gitignore(self, temp_repo):
        """Test that Syncer class respects .gitignore when committing."""
        temp_dir, repo = temp_repo

        # Create test files
        Path(temp_dir, "__pycache__").mkdir()
        Path(temp_dir, "__pycache__", "test.pyc").write_text("bytecode")
        Path(temp_dir, "settings.local.json").write_text('{"local": true}')
        Path(temp_dir, "valid_file.txt").write_text("should be committed")

        # Create a mock config
        mock_config = MagicMock(spec=Config)
        mock_config.configs_dir = Path(temp_dir)
        mock_config.branch = "main"
        mock_config.get_machine_id.return_value = "test-machine"

        # Create syncer instance
        syncer = Syncer(mock_config)

        # Simulate the sync commit process (using our fixed code)
        syncer.repo.git.add("--all", ".")

        # Get what would be committed
        staged_files = [item.a_path for item in syncer.repo.index.diff("HEAD")]

        # Verify gitignore is respected
        assert not any("__pycache__" in path for path in staged_files), (
            "Syncer would commit __pycache__ files!"
        )
        assert not any(".local" in path for path in staged_files), (
            "Syncer would commit .local files!"
        )
        assert any("valid_file.txt" in path for path in staged_files), (
            "Syncer did not stage valid files"
        )

    def test_already_tracked_ignored_files_are_removed(self, temp_repo):
        """Test that previously tracked files that should be ignored are untracked."""
        temp_dir, repo = temp_repo

        # First, force add a __pycache__ file (simulating the bug)
        pycache_dir = Path(temp_dir) / "__pycache__"
        pycache_dir.mkdir()
        pycache_file = pycache_dir / "bad.pyc"
        pycache_file.write_text("should not be tracked")

        # Force add it (simulating the old bug)
        repo.index.add([str(pycache_file)])
        repo.index.commit("Accidentally committed __pycache__")

        # Verify it's tracked
        assert str(pycache_file.relative_to(temp_dir)) in [
            item.path for item in repo.tree().traverse()
        ]

        # Now remove it from tracking (our fix)
        repo.index.remove([str(pycache_file)], cached=True)
        repo.index.commit("Remove __pycache__ from tracking")

        # Verify it's no longer tracked
        assert str(pycache_file.relative_to(temp_dir)) not in [
            item.path for item in repo.tree().traverse()
        ]

        # Verify file still exists on disk
        assert pycache_file.exists()

        # Try to add all files again
        repo.git.add("--all", ".")

        # Verify __pycache__ is not staged
        staged_files = [item.a_path for item in repo.index.diff("HEAD")]
        assert not any("__pycache__" in path for path in staged_files), (
            "Previously untracked __pycache__ was added again!"
        )

    def test_comprehensive_ignore_patterns(self, temp_repo):
        """Test various gitignore patterns comprehensively."""
        temp_dir, repo = temp_repo

        # Create a comprehensive set of files that should be ignored
        ignored_files = [
            "__pycache__/test.pyc",
            "src/__pycache__/module.pyc",
            "deep/nested/__pycache__/file.pyc",
            "config.local",
            "settings.local.json",
            ".local/data.txt",
            ".env",
            ".envrc",
            ".venv/lib/python3.11/test.py",
            "venv/bin/python",
            ".DS_Store",
            ".vscode/settings.json",
            ".idea/workspace.xml",
            "file.swp",
            "backup~",
            ".claude/settings.json",
            "README.claude.md",
        ]

        # Create all ignored files
        for file_path in ignored_files:
            full_path = Path(temp_dir) / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(f"Content of {file_path}")

        # Create files that should be added
        valid_files = [
            "src/main.py",
            "tests/test_main.py",
            "README.md",
            "pyproject.toml",
            "docs/guide.md",
        ]

        for file_path in valid_files:
            full_path = Path(temp_dir) / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(f"Valid content of {file_path}")

        # Add all files
        repo.git.add("--all", ".")

        # Get staged files
        staged_files = [item.a_path for item in repo.index.diff("HEAD")]

        # Assert NO ignored files are staged
        for ignored in ignored_files:
            assert not any(ignored in staged for staged in staged_files), (
                f"Ignored file '{ignored}' was staged! Staged: {staged_files}"
            )

        # Assert ALL valid files are staged
        for valid in valid_files:
            assert any(valid in staged for staged in staged_files), (
                f"Valid file '{valid}' was not staged! Staged: {staged_files}"
            )

    def test_git_check_ignore_validation(self, temp_repo):
        """Use git check-ignore to validate our assumptions."""
        temp_dir, repo = temp_repo

        # Files that should be ignored
        test_cases = [
            ("__pycache__/test.pyc", True),
            ("src/__pycache__/test.pyc", True),
            ("config.local", True),
            ("settings.local.json", True),
            (".local/file.txt", True),
            (".env", True),
            (".DS_Store", True),
            ("src/main.py", False),
            ("README.md", False),
            ("tests/test.py", False),
        ]

        for file_path, should_be_ignored in test_cases:
            full_path = Path(temp_dir) / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(f"Content of {file_path}")

            # Check if git ignores this file
            try:
                repo.git.check_ignore(str(full_path))
                is_ignored = True
            except git.GitCommandError:
                is_ignored = False

            assert is_ignored == should_be_ignored, (
                f"File '{file_path}' ignore status is {is_ignored}, expected {should_be_ignored}"
            )


class TestSyncerSafeguards:
    """Test additional safeguards in Syncer to prevent committing ignored files."""

    @pytest.fixture
    def mock_config(self):
        """Create a mock config for testing."""
        config = MagicMock(spec=Config)
        config.configs_dir = Path("/tmp/test_configs")
        config.branch = "main"
        config.get_machine_id.return_value = "test-machine"
        return config

    def test_syncer_uses_correct_add_command(self, mock_config):
        """Ensure Syncer uses 'git add --all .' instead of repo.index.add('.')."""
        with tempfile.TemporaryDirectory() as temp_dir:
            mock_config.configs_dir = Path(temp_dir)

            # Initialize a real repo for testing
            repo = git.Repo.init(temp_dir)

            # Create .gitignore
            gitignore = Path(temp_dir) / ".gitignore"
            gitignore.write_text("__pycache__/\n*.pyc\n.git/\n*.local")
            repo.index.add([".gitignore"])
            repo.index.commit("Add .gitignore")

            # Create test files
            Path(temp_dir, "valid.txt").write_text("valid")
            Path(temp_dir, "__pycache__").mkdir()
            Path(temp_dir, "__pycache__", "bad.pyc").write_text("bad")

            # Create syncer
            syncer = Syncer(mock_config)

            # Simulate the sync process
            syncer.repo.git.add("--all", ".")

            # Check what was staged
            staged = [item.a_path for item in syncer.repo.index.diff("HEAD")]

            # Verify
            assert any("valid.txt" in s for s in staged)
            assert not any("__pycache__" in s for s in staged)
            assert not any(".pyc" in s for s in staged)


class TestRegressionPrevention:
    """Tests to prevent regression of the gitignore bug."""

    def test_sync_py_line_190_uses_correct_command(self):
        """Verify sync.py line ~190 uses correct git add command."""
        sync_file = Path(__file__).parent.parent / "src" / "csync" / "sync.py"
        content = sync_file.read_text()

        # Check that we're NOT using the bad pattern (excluding comments)
        # Remove comments for checking
        code_lines = []
        for line in content.split("\n"):
            # Remove comments but keep the line structure
            if "#" in line:
                code_part = line.split("#")[0]
            else:
                code_part = line
            code_lines.append(code_part)
        code_without_comments = "\n".join(code_lines)

        assert 'repo.index.add(".")' not in code_without_comments, (
            "CRITICAL: sync.py contains the buggy 'repo.index.add(\".\")' pattern in actual code!"
        )

        # Check that we ARE using the correct pattern
        assert 'repo.git.add("--all", ".")' in content, (
            'sync.py should use \'repo.git.add("--all", ".")\' to respect .gitignore'
        )

    def test_no_force_add_patterns(self):
        """Ensure no code uses force add that could bypass .gitignore."""
        src_dir = Path(__file__).parent.parent / "src" / "csync"

        # Only check for actual dangerous git add patterns
        dangerous_patterns = [
            'repo.index.add("*")',
            'repo.index.add(".")',
            'repo.index.add(["."])',
            'repo.index.add(["*"])',
            'git.add("-f"',  # force flag with git add
            'git.add("--force"',  # force flag with git add
        ]

        for py_file in src_dir.glob("*.py"):
            content = py_file.read_text()
            # Remove comments for checking
            code_lines = []
            for line in content.split("\n"):
                if "#" in line:
                    code_part = line.split("#")[0]
                else:
                    code_part = line
                code_lines.append(code_part)
            code_without_comments = "\n".join(code_lines)

            for pattern in dangerous_patterns:
                assert pattern not in code_without_comments, (
                    f"File {py_file.name} contains dangerous pattern '{pattern}' that might bypass .gitignore"
                )


def test_cli_integration():
    """Integration test for the full CLI flow."""
    with tempfile.TemporaryDirectory() as temp_dir:
        # Setup test environment
        configs_dir = Path(temp_dir) / "configs"
        configs_dir.mkdir()

        # Initialize git repo
        repo = git.Repo.init(configs_dir)

        # Create comprehensive .gitignore
        gitignore = configs_dir / ".gitignore"
        gitignore.write_text("""
__pycache__/
*.pyc
.git/
*.local
*.local.*
settings.local.json
.env
.DS_Store
""")
        repo.index.add([".gitignore"])
        repo.index.commit("Initial commit")

        # Create various files
        (configs_dir / "config.json").write_text('{"valid": true}')
        (configs_dir / "__pycache__").mkdir()
        (configs_dir / "__pycache__" / "bad.pyc").write_text("bytecode")
        (configs_dir / "settings.local.json").write_text('{"local": true}')

        # Simulate sync (using the correct add command)
        repo.git.add("--all", ".")

        # Verify only valid files are staged
        staged = [item.a_path for item in repo.index.diff("HEAD")]

        assert len(staged) == 1
        assert "config.json" in staged[0]
        assert "__pycache__" not in str(staged)
        assert ".local" not in str(staged)


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v", "--tb=short"])
