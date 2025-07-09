# Build Scripts

This project uses a unified development script to handle all build operations.

## Quick Start

### Cross-platform (Recommended)
```bash
./dev.sh build debug
```

## Available Script

### `dev.sh` (Unified Development Script)
Feature-rich development script with multiple options:

```bash
# Basic build
./dev.sh build debug

# Clean and build
./dev.sh build clean
./dev.sh build debug

# Release build
./dev.sh build release

# Build with shared libraries
./dev.sh build shared

# Run tests
./dev.sh test run

# Run the executable
./dev.sh run

# Show help
./dev.sh help

# Show build options
./dev.sh build help

# Quality checks
./dev.sh quality all
```

## How It Works

1. **vcpkg Integration**: The script automatically sets the `CMAKE_TOOLCHAIN_FILE` environment variable
2. **Manifest Mode**: Dependencies are read from `vcpkg.json` and installed automatically
3. **Cross-platform**: Script works on Windows, Linux, and macOS
4. **Error Handling**: Script exits on errors and provides clear feedback

## Dependencies

The script will automatically install dependencies listed in `vcpkg.json`:
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
./dev.sh build debug

# After making changes
./dev.sh build debug

# Run tests
./dev.sh test run

# Run the program
./dev.sh run
```

### Release Build
```bash
./dev.sh build clean
./dev.sh build release
./dev.sh test run
```

This will clean, configure for release, build, and test.
