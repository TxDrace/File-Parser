# Build Scripts

This project includes several automated build scripts to make development easier.

## Quick Start

### Windows (Command Prompt)
```cmd
build.bat
```

### Linux/macOS/Windows (Bash)
```bash
./build.sh
```

## Available Scripts

### 1. `build.bat` (Windows)
Simple Windows batch script that:
- Sets up vcpkg toolchain
- Cleans previous build
- Configures with CMake
- Builds the project
- Runs tests

### 2. `build.sh` (Cross-platform)
Cross-platform bash script that:
- Auto-detects operating system
- Sets up vcpkg toolchain
- Builds and tests the project

### 3. `dev.sh` (Advanced Development)
Feature-rich development script with multiple options:

```bash
# Basic build
./dev.sh

# Clean and build
./dev.sh clean build

# Release build
./dev.sh release

# Build with shared libraries
./dev.sh shared

# Run tests only
./dev.sh test

# Run the executable
./dev.sh run

# Show help
./dev.sh help
```

## How It Works

1. **vcpkg Integration**: Scripts automatically set the `CMAKE_TOOLCHAIN_FILE` environment variable
2. **Manifest Mode**: Dependencies are read from `vcpkg.json` and installed automatically
3. **Cross-platform**: Scripts work on Windows, Linux, and macOS
4. **Error Handling**: Scripts exit on errors and provide clear feedback

## Dependencies

The scripts will automatically install dependencies listed in `vcpkg.json`:
- zlib (compression library)

## Output

Built executables are located in:
- **Windows**: `build\Debug\`
- **Linux/macOS**: `build/`

Files:
- `file_parser.exe` / `file_parser` - Main executable
- `dummy_test.exe` / `dummy_test` - Test executable

## Troubleshooting

If you encounter issues:

1. **vcpkg not found**: Make sure the `vcpkg/` directory exists
2. **CMake not found**: Install CMake and ensure it's in your PATH
3. **Visual Studio (Windows)**: Install Visual Studio with C++ development tools

## Example Workflows

### Basic Development
```bash
# First time setup
./build.sh

# After making changes
./dev.sh

# Run tests
./dev.sh test

# Run the program
./dev.sh run
```

### Release Build
```bash
./dev.sh clean release build test
```

This will clean, configure for release, build, and test in one command.
