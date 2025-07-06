# CleanArchitecture

The project was generated using the [Clean.Architecture.Solution.Template](caRepositoryUrl) version caPackageVersion.

## Build

Run `dotnet build -tl` to build the solution.

## Run

<!--#if (!UseSqlite) -->
### Start Development Database

The solution includes Docker support for local development databases.

```bash
# Windows PowerShell
.\scripts\start-database.ps1

# Linux/Mac
./scripts/start-database.sh
```

This will start a Docker container with your chosen database. Database credentials are automatically generated and stored in .NET User Secrets when you first build the Web project.

### Database Management Scripts

#### Windows (PowerShell)
- **Start Database**: `.\scripts\start-database.ps1` - Starts the database container
- **Stop Database**: `.\scripts\stop-database.ps1` - Stops the database (data is preserved)
- **Reset Database**: `.\scripts\reset-database.ps1` - Removes all data and starts fresh
- **Show Credentials**: `.\scripts\show-credentials.ps1` - Display Docker service credentials

#### Linux/Mac (Shell)
- **Start Database**: `./scripts/start-database.sh` - Starts the database container
- **Stop Database**: `./scripts/stop-database.sh` - Stops the database (data is preserved)
- **Reset Database**: `./scripts/reset-database.sh` - Removes all data and starts fresh
- **Show Credentials**: `./scripts/show-credentials.sh` - Display Docker service credentials

**Note**: Database credentials are automatically generated and stored securely in .NET User Secrets when you first build the Web project.

### Run Migrations

After starting the database, apply Entity Framework migrations:

```bash
cd .\src\Web\
dotnet ef database update
```
<!--#endif -->

### Run the Application

```bash
cd .\src\Web\
dotnet watch run
```

Navigate to https://localhost:5001. The application will automatically reload if you change any of the source files.

## Code Styles & Formatting

The template includes [EditorConfig](https://editorconfig.org/) support to help maintain consistent coding styles for multiple developers working on the same project across various editors and IDEs. The **.editorconfig** file defines the coding styles applicable to this solution.

## Code Scaffolding

The template includes support to scaffold new commands and queries.

Start in the `.\src\Application\` folder.

Create a new command:

```
dotnet new ca-usecase --name CreateTodoList --feature-name TodoLists --usecase-type command --return-type int
```

Create a new query:

```
dotnet new ca-usecase -n GetTodos -fn TodoLists -ut query -rt TodosVm
```

If you encounter the error *"No templates or subcommands found matching: 'ca-usecase'."*, install the template and try again:

```bash
dotnet new install Clean.Architecture.Solution.Template::caPackageVersion
```

## Test

<!--#if (UseApiOnly) -->
The solution contains unit, integration, and functional tests.

To run the tests:
```bash
dotnet test
```
<!--#else -->
The solution contains unit, integration, functional, and acceptance tests.

To run the unit, integration, and functional tests (excluding acceptance tests):
```bash
dotnet test --filter "FullyQualifiedName!~AcceptanceTests"
```

To run the acceptance tests, first start the application:

```bash
cd .\src\Web\
dotnet run
```

Then, in a new console, run the tests:
```bash
cd .\src\Web\
dotnet test
```
<!--#endif -->

## Help
To learn more about the template go to the [project website](caRepositoryUrl). Here you can find additional guidance, request new features, report a bug, and discuss the template with other users.