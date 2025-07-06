# Contributing to .NET Templates Collection

Thank you for your interest in contributing to this .NET Templates Collection! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Issues
- Use the GitHub issue tracker to report bugs or suggest features
- Before creating a new issue, please check if it already exists
- Provide as much detail as possible, including:
  - Template name and version
  - Steps to reproduce the issue
  - Expected vs actual behavior
  - Your environment details (.NET version, OS, etc.)

### Submitting Pull Requests
1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes following our coding standards
4. Add or update tests as necessary
5. Update documentation if needed
6. Submit a pull request with a clear description of your changes

### Coding Standards
- Follow the existing code style in the project
- Use meaningful variable and method names
- Add XML documentation comments for public APIs
- Keep commits small and focused on a single change
- Write clear commit messages

### Template Development Guidelines
- Ensure templates follow .NET template best practices
- Test templates thoroughly on different platforms
- Include comprehensive README files for each template
- Use conditional compilation appropriately
- Avoid hardcoding values that should be parameterized

### Testing
- Test your changes locally before submitting
- Ensure all existing tests pass
- Add new tests for new functionality
- Test templates on both Windows and Unix-based systems

## Development Setup

1. Clone the repository
2. Install .NET SDK 8.0 or later
3. Install Docker Desktop for testing Docker features
4. Run `./scripts/install-all.ps1` to install templates locally

## Questions?

If you have questions about contributing, please open an issue for discussion.