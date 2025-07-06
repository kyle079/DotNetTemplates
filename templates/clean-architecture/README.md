# Clean Architecture Solution Template

[![Build](https://github.com/jasontaylordev/CleanArchitecture/actions/workflows/build.yml/badge.svg)](https://github.com/jasontaylordev/CleanArchitecture/actions/workflows/build.yml)
[![CodeQL](https://github.com/jasontaylordev/CleanArchitecture/actions/workflows/codeql.yml/badge.svg)](https://github.com/jasontaylordev/CleanArchitecture/actions/workflows/codeql.yml)
[![Nuget](https://img.shields.io/nuget/v/Clean.Architecture.Solution.Template?label=NuGet)](https://www.nuget.org/packages/Clean.Architecture.Solution.Template)
[![Nuget](https://img.shields.io/nuget/dt/Clean.Architecture.Solution.Template?label=Downloads)](https://www.nuget.org/packages/Clean.Architecture.Solution.Template)

The goal of this template is to provide a straightforward and efficient approach to enterprise application development, leveraging the power of Clean Architecture and ASP.NET Core. Using this template, you can effortlessly create a Single Page App (SPA) with ASP.NET Core and Angular or React, while adhering to the principles of Clean Architecture.

Based on [Jason Taylor's Clean Architecture Template](https://github.com/jasontaylordev/CleanArchitecture).

## Features

- ASP.NET Core 9.0
- Entity Framework Core 9.0
- Angular 18 or React 18
- .NET Aspire support (optional)
- Support for SQL Server, SQLite, and PostgreSQL
- Docker support
- CI/CD via GitHub Actions or Azure Pipelines

## Getting Started

### Prerequisites

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [Node.js](https://nodejs.org/) (latest LTS)

### Installation

Install the template locally:

```bash
dotnet new install ./templates/clean-architecture
```

### Creating a New Solution

Create a Single-Page Application (SPA) with Angular:
```bash
dotnet new ca-sln --client-framework Angular --output YourProjectName
```

Create a SPA with React:
```bash
dotnet new ca-sln -cf React -o YourProjectName
```

Create a Web API-only solution:
```bash
dotnet new ca-sln -cf None -o YourProjectName
```

### Template Options

| Option | Short | Values | Default | Description |
|--------|-------|---------|---------|-------------|
| --client-framework | -cf | Angular, React, None | Angular | The type of client framework |
| --database | -d | sqlserver, postgresql, sqlite | sqlserver | The database provider |
| --pipeline-provider | -p | github, azdo | github | CI/CD pipeline provider |
| --use-aspire | | true, false | false | Include .NET Aspire |

### Running the Application

```bash
cd YourProjectName/src/Web
dotnet run
```

Navigate to https://localhost:5001. The app will automatically reload if you change any of the source files.

## Database Configuration

The template supports multiple database providers. The database will be automatically created and migrations applied on startup.

### Database Migrations

Add a new migration:
```bash
dotnet ef migrations add "SampleMigration" --project src/Infrastructure --startup-project src/Web --output-dir Data/Migrations
```

Update the database:
```bash
dotnet ef database update --project src/Infrastructure --startup-project src/Web
```

## Creating Use Cases

You can quickly scaffold new use cases (commands or queries) using the included item template.

Navigate to the Application project:
```bash
cd src/Application
```

Create a new command:
```bash
dotnet new ca-usecase --name CreateTodoList --feature-name TodoLists --usecase-type command --return-type int
```

Create a new query:
```bash
dotnet new ca-usecase -n GetTodos -fn TodoLists -ut query -rt TodosVm
```

## Architecture

The solution template uses Clean Architecture with the following projects:

- **Domain** - Enterprise logic and entities
- **Application** - Business logic and use cases
- **Infrastructure** - Data access and external services
- **Web** - Presentation layer (API and SPA)

## Testing

The solution includes various test projects:

- **Domain.UnitTests** - Domain logic tests
- **Application.UnitTests** - Business logic tests
- **Application.FunctionalTests** - Integration tests
- **Web.AcceptanceTests** - End-to-end tests

Run all tests:
```bash
dotnet test
```

## Deployment

### Azure Deployment

The template is configured for Azure Developer CLI (azd):

```bash
# Log in to Azure
azd auth login

# Provision and deploy
azd up
```

### Docker Support

Build and run with Docker:
```bash
docker-compose up
```

## Technologies

- [ASP.NET Core 9](https://docs.microsoft.com/en-us/aspnet/core/)
- [Entity Framework Core 9](https://docs.microsoft.com/en-us/ef/core/)
- [Angular 18](https://angular.dev/) or [React 18](https://react.dev/)
- [MediatR](https://github.com/jbogard/MediatR)
- [AutoMapper](https://automapper.org/)
- [FluentValidation](https://fluentvalidation.net/)
- [NUnit](https://nunit.org/), [FluentAssertions](https://fluentassertions.com/), [Moq](https://github.com/moq/moq4)

## License

This project is licensed with the [MIT license](LICENSE).