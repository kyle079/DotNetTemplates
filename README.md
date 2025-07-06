# .NET Solution Templates Collection

A curated collection of .NET solution templates following best practices and modern architectural patterns. These templates are designed for local use and provide a solid foundation for various types of .NET applications.

## 📦 Available Templates

### 1. Clean Architecture Solution Template
**Short Name:** `ca-sln`  
**Description:** A comprehensive Clean Architecture solution template featuring:
- ASP.NET Core 9.0
- Angular, React, or API-only options
- Entity Framework Core with SQL Server, PostgreSQL, or SQLite
- Docker support
- CI/CD pipelines (GitHub Actions or Azure DevOps)
- Full test suite (Unit, Integration, Functional, and Acceptance tests)

[📖 View Documentation](templates/clean-architecture/README.md)

```bash
# Install template from local source
dotnet new install ./templates/clean-architecture

# Create a new solution
dotnet new ca-sln -n MyProject -cf React
```

### 2. Minimal API Template (Coming Soon)
**Short Name:** `min-api`  
**Description:** Lightweight API template with minimal dependencies and fast startup

### 3. Blazor Clean Architecture (Coming Soon)
**Short Name:** `blazor-ca`  
**Description:** Clean Architecture with Blazor WebAssembly/Server options

### 4. Microservices Template (Coming Soon)
**Short Name:** `micro-sln`  
**Description:** Distributed microservices solution with service discovery and messaging

## 🚀 Quick Start

### Prerequisites
- .NET 9.0 SDK or later
- Node.js (for Angular/React templates)
- Docker Desktop (optional, for containerization)

### Installation

Since these templates are for local use, clone this repository and install templates directly:

```bash
# Clone the repository
git clone https://github.com/yourusername/DotNetTemplates.git
cd DotNetTemplates

# Install all templates
./scripts/install-all.ps1

# Or install a specific template
dotnet new install ./templates/clean-architecture
```

### Usage

After installation, create a new project using any template:

```bash
# List available templates
dotnet new list

# Create a new Clean Architecture solution
dotnet new ca-sln -n MyApp -cf Angular -d postgresql

# Create with all available options
dotnet new ca-sln -n MyApp \
  -cf React \              # Client Framework: Angular|React|None
  -d postgresql \          # Database: sqlserver|postgresql|sqlite
  -p github \              # Pipeline: github|azdo
  --use-aspire false       # .NET Aspire support
```

## 📁 Repository Structure

```
DotNetTemplates/
├── templates/                 # All template sources
│   ├── clean-architecture/    # Clean Architecture template
│   ├── minimal-api/          # Minimal API template
│   └── ...                   # Other templates
├── scripts/                  # Management scripts
│   ├── install-all.ps1       # Install all templates
│   ├── uninstall-all.ps1     # Uninstall all templates
│   └── test-templates.ps1    # Test template creation
├── docs/                     # Documentation
│   ├── getting-started.md    # Getting started guide
│   ├── contributing.md       # Contribution guidelines
│   └── architecture/         # Architecture documentation
└── .gitignore               # Git ignore patterns
```

## 🛠️ Template Management

### Installing Templates

```powershell
# Install all templates
./scripts/install-all.ps1

# Install specific template
dotnet new install ./templates/clean-architecture
```

### Updating Templates

```powershell
# Uninstall and reinstall to update
./scripts/uninstall-all.ps1
./scripts/install-all.ps1
```

### Testing Templates

```powershell
# Test all template variations
./scripts/test-templates.ps1
```

## 📝 Template Development

To modify or create new templates:

1. **Modify existing template**: Edit files in `templates/[template-name]/`
2. **Update template config**: Edit `.template.config/template.json`
3. **Test changes**: Run `./scripts/test-templates.ps1`
4. **Reinstall**: Run `./scripts/install-all.ps1`

See [Contributing Guide](docs/contributing.md) for detailed instructions.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](docs/contributing.md) for details on:
- Code of conduct
- Development process
- Submitting pull requests
- Creating new templates

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Jason Taylor](https://github.com/jasontaylordev) for the original Clean Architecture template
- The .NET community for continuous feedback and contributions

## 📞 Support

- Create an [Issue](https://github.com/yourusername/DotNetTemplates/issues) for bugs or feature requests
- Check [Documentation](docs/) for guides and examples
- Review documentation for customization guidelines
