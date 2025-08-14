# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

I am on a ARM-based Mac. Give me all commands for MacOS.

## Core Principles

* Each function/method should do EXACTLY one thing and be no more than 10 lines. Try to stick to this principle as much as possible, although this is more a rule of thumb than a requirement.
* Always design code according to the SOLID design principles.
* The best code is no code, the second best is simple code.

## Environment Management with uv

* `uv venv` - Create virtual environment with uv
* `source .venv/bin/activate` - Activate virtual environment
* `deactivate` - Deactivate virtual environment
* `uv sync` - Install all project dependencies
* `uv sync --dev` - Install development dependencies

## Package Management with uv

* `uv add <package>` - Add a package to the project
* `uv add --dev <package>` - Add a development dependency
* `uv remove <package>` - Remove a package
* `uv lock` - Update the lock file
* `uv run <command>` - Run a command in the project environment

## Testing Commands

* `pytest` - Run all tests
* `pytest -v` - Run tests with verbose output
* `pytest --cov` - Run tests with coverage report
* `pytest --cov-report=html` - Generate HTML coverage report
* `pytest -x` - Stop on first failure
* `pytest -k "test_name"` - Run specific test by name
* `python -m unittest` - Run tests with unittest

## Code Quality Commands with ruff

* `ruff format .` - Format code with ruff formatter
* `ruff format --check .` - Check code formatting without changes
* `ruff format --diff .` - Show formatting changes without applying
* `ruff check .` - Run linting with ruff
* `ruff check --fix .` - Auto-fix linting issues
* `ruff check --fix --unsafe-fixes .` - Apply all possible fixes
* `ruff check --select I .` - Check import sorting
* `ruff check --fix --select I .` - Fix import sorting
* `mypy src/` - Run type checking with MyPy

## Development Tools

* `uv python install` - Install Python with uv
* `uv python list` - List available Python versions
* `uv python pin 3.12` - Pin Python version for project
* `python -c "import sys; print(sys.version)"` - Check Python version
* `python -m site` - Show Python site information
* `python -m pdb script.py` - Debug with pdb

## Core Technologies

* **Python** - Primary programming language (3.8+)
* **uv** - Fast Python package and project manager
* **ruff** - Fast Python linter and formatter

## Common Frameworks

* **FastAPI** - Modern API framework with automatic documentation
* **React** - Frontend framework (with TypeScript/JavaScript)
* **SQLAlchemy** - SQL toolkit and ORM
* **Pydantic** - Data validation using Python type hints

## Testing Frameworks

* **pytest** - Testing framework
* **unittest** - Built-in testing framework
* **pytest-cov** - Coverage plugin for pytest
* **factory-boy** - Test fixtures
* **responses** - Mock HTTP requests

## Code Quality Tools

* **ruff** - Ultra-fast Python linter and formatter
* **mypy** - Static type checker
* **pre-commit** - Git hooks framework

## File Organization

```text
src/
├── package_name/
│   ├── __init__.py
│   ├── main.py          # Application entry point
│   ├── models/          # Data models
│   ├── api/             # API endpoints
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   └── config/          # Configuration files
tests/
├── __init__.py
├── conftest.py          # pytest configuration
├── test_models.py
├── test_api.py
└── test_utils.py
pyproject.toml           # Project configuration and dependencies
uv.lock                  # Lock file for dependencies
```

## Naming Conventions

* **Files/Modules**: Use snake_case (`user_profile.py`)
* **Classes**: Use PascalCase (`UserProfile`)
* **Functions/Variables**: Use snake_case (`get_user_data`)
* **Constants**: Use UPPER_SNAKE_CASE (`API_BASE_URL`)
* **Private methods**: Prefix with underscore (`_private_method`)

## Type Hints

* Use type hints for function parameters and return values
* Import types from `typing` module when needed
* Use `| None` for nullable values
* Use pipe operator `|` for multiple possible types (e.g., `str | int`)
* Document complex types with comments

## Code Style

* Follow PEP 8 style guide (enforced by ruff)
* Use meaningful variable and function names
* Keep functions focused and single-purpose
* Use docstrings for modules, classes, and functions
* Limit line length to 88 characters (ruff default)

## Best Practices

* Use list comprehensions for simple transformations
* Prefer `pathlib` over `os.path` for file operations
* Use context managers (`with` statements) for resource management
* Handle exceptions appropriately with try/except blocks
* Use `logging` module instead of print statements
* The logging is setup automatically for the whole project by running `from domain.config import settings`. That’s all you have to do! Then you can just create a logger and use it `logger = logging.getLogger(__name__)`.

## Configuration Files

### ruff Configuration (pyproject.toml)

```toml
[tool.ruff]
# Python version
target-version = "py311"

[tool.ruff.isort]
# Keep all imports on single lines
force-single-line = true
```

## Testing Standards

### Test Structure

* Organize tests to mirror source code structure
* Use descriptive test names that explain the behavior
* Follow AAA pattern (Arrange, Act, Assert)
* Use fixtures for common test data
* Group related tests in classes

### Coverage Goals

* Aim for 90%+ test coverage
* Write unit tests for business logic
* Use integration tests for external dependencies
* Mock external services in tests
* Test error conditions and edge cases

### pytest Configuration

```python
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--cov=src --cov-report=term-missing"
```

## Virtual Environment Setup with uv

### Creation and Activation

```bash
# Create virtual environment with uv
uv venv

# Activate
source .venv/bin/activate

# Install all dependencies
uv sync

# Install including dev dependencies
uv sync --dev
```

### Dependency Management with uv

* Define dependencies in `pyproject.toml`
* Use `uv add <package>` to add new dependencies
* Use `uv add --dev <package>` for development dependencies
* Use `uv remove <package>` to remove dependencies
* `uv lock` updates the lock file
* `uv sync` ensures environment matches lock file

## FastAPI-Specific Guidelines

### Project Structure

```text
src/
├── main.py              # FastAPI application
├── api/
│   ├── __init__.py
│   ├── dependencies.py  # Dependency injection
│   └── v1/
│       ├── __init__.py
│       └── endpoints/
├── core/
│   ├── __init__.py
│   ├── config.py       # Settings
│   └── security.py    # Authentication
├── models/
├── schemas/            # Pydantic models
└── services/
```

## Security Guidelines

### Dependencies

* Regularly check for updates with `uv lock --upgrade`
* Use `safety` package to check for known vulnerabilities
* Pin dependency versions in `pyproject.toml`
* Use virtual environments to isolate dependencies

### Code Security

* Validate input data with Pydantic or similar
* Use environment variables for sensitive configuration
* Implement proper authentication and authorization
* Sanitize data before database operations
* Use HTTPS for production deployments
