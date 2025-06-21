# Code Quality Tools

This project uses clang-format and clang-tidy to maintain consistent code style and catch potential issues.

## Setup

### Prerequisites

Make sure you have the following tools installed:

- **clang-format**: For code formatting
- **clang-tidy**: For static analysis and linting

On Windows with LLVM installed:
```bash
# Check if tools are available
clang-format --version
clang-tidy --version
```

### Configuration Files

- **`.clang-format`**: Defines the coding style (based on LLVM style with custom modifications)
- **`.clang-tidy`**: Configures static analysis checks and naming conventions

## Usage

### Quick Start with Helper Scripts (Recommended)

This project includes convenient wrapper scripts that automatically handle the build configuration and tool execution:

#### Linux/macOS/Git Bash Users
```bash
# Format all source files
./dev-quality.sh format

# Check formatting without modifying files
./dev-quality.sh check

# Run clang-tidy static analysis
./dev-quality.sh tidy

# Run all code quality checks (format check + clang-tidy)
./dev-quality.sh all

# Show help and available commands
./dev-quality.sh help
```

#### Windows Users (Command Prompt)
```cmd
REM Format all source files
dev-quality.bat format

REM Check formatting without modifying files
dev-quality.bat check

REM Run clang-tidy static analysis
dev-quality.bat tidy

REM Run all code quality checks (format check + clang-tidy)
dev-quality.bat all

REM Show help and available commands
dev-quality.bat help
```

#### Windows Users (Git Bash/MSYS2)
```bash
# Alternative: Run Windows batch file from bash
cmd //c "dev-quality.bat format"
cmd //c "dev-quality.bat check"
cmd //c "dev-quality.bat tidy"
cmd //c "dev-quality.bat all"

# Or use the bash script directly
./dev-quality.sh format
./dev-quality.sh check
./dev-quality.sh tidy
./dev-quality.sh all
```

**Note**: The helper scripts automatically:
- Check if required tools are installed
- Configure the build directory with proper flags if needed (`-DENABLE_CLANG_FORMAT=ON -DENABLE_CLANG_TIDY=ON`)
- Handle cross-platform differences
- Provide colored output and clear error messages
- **No manual CMake configuration required** - just run the scripts!

### During Development

#### Enable clang-tidy during build (recommended for development)
```bash
# Configure with clang-tidy enabled
cmake -B build -DENABLE_CLANG_TIDY=ON -DENABLE_CLANG_FORMAT=ON

# Build (clang-tidy will run automatically on each source file)
cmake --build build
```

#### Manual CMake targets (if you prefer direct CMake usage)
```bash
# Format all source files
cmake --build build --target format

# Check formatting without modifying files
cmake --build build --target format-check

# Run clang-tidy manually
cmake --build build --target tidy

# Run all code quality checks
cmake --build build --target code-quality
```

### CI/CD Integration

For continuous integration, you can use:

```bash
# Configure without clang-tidy during build (faster)
cmake -B build -DENABLE_CLANG_FORMAT=ON

# Build
cmake --build build

# Run code quality checks
cmake --build build --target code-quality
```

### Individual Tool Usage

#### clang-format
```bash
# Format a single file
clang-format -i src/main.cpp

# Check formatting of a file
clang-format --dry-run --Werror src/main.cpp

# Format all source files
find src include tests -name "*.cpp" -o -name "*.h" | xargs clang-format -i
```

#### clang-tidy
```bash
# Check a single file
clang-tidy src/main.cpp -- -Iinclude

# Check all source files
clang-tidy src/*.cpp tests/*.cpp -- -Iinclude
```

## Configuration Details

### .clang-format Settings

- **Style**: Based on LLVM with 4-space indentation
- **Column limit**: 100 characters
- **C++ standard**: C++11
- **Pointer alignment**: Left (`int* ptr`)
- **Brace style**: Attach (K&R style)

### .clang-tidy Checks

Enabled check categories:
- **bugprone-***: Bug-prone code patterns
- **cert-***: CERT secure coding guidelines
- **clang-analyzer-***: Static analysis checks
- **cppcoreguidelines-***: C++ Core Guidelines
- **google-***: Google style guide
- **llvm-***: LLVM coding standards
- **misc-***: Miscellaneous checks
- **modernize-***: C++11/14/17 modernization
- **performance-***: Performance-related issues
- **portability-***: Portability issues
- **readability-***: Code readability improvements

### Naming Conventions

- **Classes/Structs**: `CamelCase`
- **Functions**: `camelBack`
- **Variables/Parameters**: `camelBack`
- **Constants**: `UPPER_CASE`
- **Enums**: `CamelCase`
- **Enum constants**: `UPPER_CASE`
- **Namespaces**: `lower_case`

## Integration with IDEs

### Visual Studio Code

Install the following extensions:
- **C/C++**: Microsoft's C++ extension
- **clangd**: Alternative language server with built-in clang-tidy support

### Visual Studio

Configure clang-format in Tools > Options > Text Editor > C/C++ > Formatting.

### CLion

CLion has built-in support for both clang-format and clang-tidy.

## Troubleshooting

### Common Issues

1. **Tools not found**: Make sure clang-format and clang-tidy are in your PATH
2. **Build errors with clang-tidy**: Some checks might be too strict; adjust `.clang-tidy` as needed
3. **Formatting conflicts**: Ensure your editor respects the `.clang-format` file

### Customization

You can modify the configuration files to match your team's preferences:
- Edit `.clang-format` for style preferences
- Edit `.clang-tidy` to enable/disable specific checks
- Use `# NOLINT` comments to suppress specific warnings in code

## Best Practices

1. **Run formatting before commits**: `cmake --build build --target format`
2. **Enable clang-tidy during development**: Catch issues early
3. **Use format-check in CI**: Enforce consistent formatting
4. **Regularly update configurations**: Keep up with new checks and improvements
5. **Document exceptions**: Use comments to explain NOLINT suppressions

## Common Usage Scenarios

### Before Committing Changes
```bash
# Format your code and check for issues
./dev-quality.sh all
```
This ensures your code follows the project's style guidelines and catches potential issues before they reach the repository.

### During Development
```bash
# Quick format while coding
./dev-quality.sh format

# Check if your changes introduced any new issues
./dev-quality.sh tidy
```

### Setting Up Pre-commit Hooks
You can integrate these scripts into your Git workflow:

```bash
# Create a pre-commit hook (Linux/macOS/Git Bash)
echo '#!/bin/bash' > .git/hooks/pre-commit
echo './dev-quality.sh check' >> .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### CI/CD Pipeline Integration
For automated builds, use the `check` command to ensure code quality:

```bash
# In your CI script
./dev-quality.sh check  # Fails if formatting is incorrect
./dev-quality.sh tidy   # Fails if code quality issues are found
```

### Fixing Common Issues

When `dev-quality.sh tidy` reports warnings:
- **Naming issues**: Follow the project's naming conventions (see Configuration Details section)
- **Performance warnings**: Consider the suggested optimizations
- **Modernization suggestions**: Update code to use modern C++ features when appropriate
- **Include issues**: Add missing headers or remove unused includes

Use `# NOLINT` comments sparingly to suppress false positives:
```cpp
int legacyFunction() { // NOLINT(readability-identifier-naming)
    // Explanation of why this naming is acceptable
}
```
