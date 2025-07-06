# Getting Started with .NET Templates

This guide will help you get started with using the .NET templates in this repository.

## Prerequisites

Before using these templates, ensure you have:

- **.NET 9.0 SDK** or later - [Download](https://dotnet.microsoft.com/download/dotnet/9.0)
- **Node.js** (latest LTS) - Required for Angular/React templates - [Download](https://nodejs.org/)
- **PowerShell** - For running the management scripts
- **Git** - For cloning this repository

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/DotNetTemplates.git
cd DotNetTemplates
```

### 2. Install Templates

You have two options for installing templates:

#### Option A: Install All Templates

```powershell
./scripts/install-all.ps1
```

#### Option B: Install Specific Template

```bash
dotnet new install ./templates/clean-architecture
```

### 3. Verify Installation

List all installed templates:

```bash
dotnet new list
```

You should see your templates listed with their short names.

## Using Templates

### Clean Architecture Template

The Clean Architecture template (`ca-sln`) is a full-featured solution template.

#### Basic Usage

```bash
# Create with default options (Angular + SQL Server)
dotnet new ca-sln -n MyProject

# Create with React and PostgreSQL
dotnet new ca-sln -n MyProject -cf React -d postgresql

# Create API-only with SQLite
dotnet new ca-sln -n MyProject -cf None -d sqlite
```

#### Available Options

| Option | Short | Values | Default | Description |
|--------|-------|---------|---------|-------------|
| `--client-framework` | `-cf` | Angular, React, None | Angular | Frontend framework |
| `--database` | `-d` | sqlserver, postgresql, sqlite | sqlserver | Database provider |
| `--pipeline-provider` | `-p` | github, azdo | github | CI/CD provider |
| `--use-aspire` | | true, false | false | Include .NET Aspire |

#### Running the Application

After creating a project:

```bash
cd MyProject/src/Web
dotnet run
```

Navigate to https://localhost:5001

## Template Development

### Modifying Templates

1. Edit template files in `templates/[template-name]/`
2. Update `.template.config/template.json` if needed
3. Reinstall the template:
   ```powershell
   ./scripts/uninstall-all.ps1
   ./scripts/install-all.ps1
   ```

### Testing Templates

Test all template variations:

```powershell
./scripts/test-templates.ps1
```

Test and keep output for inspection:

```powershell
./scripts/test-templates.ps1 -KeepOutput
```

## Troubleshooting

### Template Not Found

If `dotnet new` doesn't show your template:

1. Check installation:
   ```bash
   dotnet new list
   ```

2. Reinstall:
   ```powershell
   ./scripts/uninstall-all.ps1
   ./scripts/install-all.ps1
   ```

### Build Errors

If a created project doesn't build:

1. Ensure all prerequisites are installed
2. Check .NET SDK version: `dotnet --version`
3. For Angular/React: Check Node.js version: `node --version`
4. Review error messages for missing dependencies

### Script Execution Policy (Windows)

If PowerShell scripts won't run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Next Steps

- Read the [Clean Architecture Template Documentation](../templates/clean-architecture/README.md)
- Explore template customization options
- Check [Contributing Guide](contributing.md) to help improve templates

## Getting Help

- Check existing [Issues](https://github.com/yourusername/DotNetTemplates/issues)
- Review template-specific README files
- Create a new issue for bugs or feature requests