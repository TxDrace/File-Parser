# Contributing


## Prerequisites

Before contributing to this project, ensure you have the following installed:

### Required Tools
- **Git** - For version control
- **CMake** (version 3.10 or higher) - For build configuration
  - *Current environment: CMake 4.0.3*
- **C++ Compiler** with C++23 support:
  - **Windows**: Visual Studio 2017+ (currently using VS 2022 Community)
    - Includes MSVC compiler and Clang-cl (Clang 19.1.5)
  - **Alternative**: MinGW-w64/MSYS2 GCC (currently GCC 14.2.0 available)
  - **Linux**: GCC 7+ or Clang 5+ (for cross-platform development)
  - **macOS**: Xcode 9+ or Clang 5+ (for cross-platform development)

### Optional but Recommended
- **Visual Studio Code** with CMake extension - For easy compiler switching
- **Git Bash** (Windows users) for better cross-platform script compatibility
- **MSYS2** (current environment) for Unix-like tools on Windows

### Code Quality Tools (Optional)
For maintaining consistent code style and catching potential issues:
- **clang-format** - For automatic code formatting
- **clang-tidy** - For static analysis and linting

Install via LLVM package or standalone tools. See [CODE_QUALITY.md](CODE_QUALITY.md) for detailed setup instructions.

## Getting Started for New Contributors

### 1. Clone the Repository

```bash
git clone <repository-url>
cd File-Parser
```

### 2. Initialize vcpkg (Dependency Manager)

This project uses vcpkg for dependency management. vcpkg is included as a submodule:

```bash
# Initialize and update git submodules
git submodule update --init --recursive

# Bootstrap vcpkg (compile vcpkg from source)
cd vcpkg
```

**On Windows:**
```batch
.\bootstrap-vcpkg.bat
```

**On Linux/macOS/Git Bash:**
```bash
./bootstrap-vcpkg.sh
```

### 3. Build the Project

You have several options to build the project:

#### Option A: Using Development Script (Recommended)

```bash
# Build in debug mode (default)
./dev.sh build debug

# Build in release mode
./dev.sh build release

# Build with shared libraries
./dev.sh build shared

# Clean and rebuild
./dev.sh build clean
./dev.sh build debug

# See all available options
./dev.sh help
./dev.sh build help
```

#### Option B: Manual CMake Build

```bash
# Configure the project
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake

# Build the project
cmake --build build

# Run tests (uses Google Test)
ctest --test-dir build
```

### 4. Verify Installation

After building, test that everything works:

```bash
# Run tests (Google Test)
./dev.sh test run

# Or manually:
cd build
ctest  # runs Google Test suite

# Run the main executable
./dev.sh run

# Or manually:
cd build
./file_parser  # Linux/macOS
# or
.\Debug\file_parser.exe  # Windows
```

### Testing Different Compilers

To verify the project works with different compilers (VS Code method):

1. **Open Command Palette**: `Ctrl+Shift+P`
2. **Select Kit**: Run `CMake: Select a Kit`
3. **Choose Compiler**:
   - Visual Studio Community 2022 (MSVC)
   - Clang for MSVC (Clang-cl)
   - GCC (if available)
4. **Configure**: Run `CMake: Configure`
5. **Build**: Run `CMake: Build`
6. **Test**: Run `CMake: Run Tests`

## Development Workflow

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** to the source code

3. **Build and test:**
   ```bash
   ./dev.sh build debug
   ./dev.sh test run
   ```

4. **Run the application to verify:**
   ```bash
   ./dev.sh run
   ```

### Code Quality

This project includes code quality tools to maintain consistent style and catch potential issues. All code quality functionality is integrated into the main development script.

#### Using the Development Script (Recommended)

```bash
# Format all source files
./dev.sh quality format

# Check formatting without modifying files
./dev.sh quality check

# Run clang-tidy static analysis
./dev.sh quality lint

# Run all code quality checks (format check + clang-tidy)
./dev.sh quality all

# Show help for quality commands
./dev.sh quality help
```

#### Understanding the Commands

- **`format`**: Automatically formats all source files according to the project's style guide
- **`check`**: Verifies formatting without making changes (useful for CI/CD)
- **`lint`**: Runs static analysis to catch potential bugs and code quality issues
- **`all`**: Runs both format checking and static analysis

**Important**: The development script automatically handles all configuration for you:
- ✅ Check if clang-format and clang-tidy are installed
- ✅ Configure the build directory with the required flags (`-DENABLE_CLANG_FORMAT=ON -DENABLE_CLANG_TIDY=ON`)
- ✅ Handle cross-platform differences
- ✅ **No manual setup required** - just run the commands!

#### Quick Start with Code Quality

```bash
# Format all source files
./dev.sh quality format

# Check code quality (formatting + static analysis)
./dev.sh quality all
```

#### CMake Integration (Advanced/Optional)

If you prefer to use CMake directly instead of the helper scripts, you can manually enable code quality tools:

```bash
# Configure with code quality tools (only needed if not using helper scripts)
cmake -B build -DENABLE_CLANG_TIDY=ON -DENABLE_CLANG_FORMAT=ON

# Build with automatic clang-tidy checks
cmake --build build

# Run specific code quality targets
cmake --build build --target format        # Format code
cmake --build build --target format-check  # Check formatting
cmake --build build --target tidy          # Run clang-tidy
```

**Note**: The development script (`./dev.sh quality`) is recommended as it handles the configuration automatically.

See [CODE_QUALITY.md](CODE_QUALITY.md) for detailed configuration and usage instructions.

### Adding Dependencies

To add new C++ dependencies:

1. **Edit `vcpkg.json`** to add the dependency:
   ```json
   {
     "dependencies": [
       {
         "name": "zlib",
         "version>=": "1.3.1"
       },
       {
         "name": "new-dependency-name"
       }
     ]
   }
   ```

2. **Update `CMakeLists.txt`** to find and link the package:
   ```cmake
   find_package(NewPackage REQUIRED)
   target_link_libraries(your_target PRIVATE NewPackage::NewPackage)
   ```

3. **Rebuild the project:**
   ```bash
   ./dev.sh build clean
   ./dev.sh build debug
   ```
