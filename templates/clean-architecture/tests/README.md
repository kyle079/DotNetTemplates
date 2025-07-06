# Test Projects

This directory contains various test projects for the Clean Architecture solution.

## Test Credentials

The test projects contain hardcoded credentials that are **for testing purposes only**:

- PostgreSQL test password: `password` (in appsettings.PostgreSQL.json)
- Test user password: `Administrator1!` (in acceptance tests)

These credentials are intentionally simple and should **never** be used in production environments.

## Test Projects

### Application.FunctionalTests
Integration tests that test the application with a real database.

### Application.UnitTests
Unit tests for application logic.

### Domain.UnitTests
Unit tests for domain entities and value objects.

### Web.AcceptanceTests
UI acceptance tests using Selenium WebDriver.

## Running Tests

```bash
# Run all tests except acceptance tests
dotnet test --filter "FullyQualifiedName!~AcceptanceTests"

# Run only unit tests
dotnet test --filter "FullyQualifiedName~UnitTests"

# Run functional tests
dotnet test --filter "FullyQualifiedName~FunctionalTests"
```

For acceptance tests, first start the application, then run:
```bash
cd tests/Web.AcceptanceTests
dotnet test
```