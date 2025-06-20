# File Parser

This project provides a simple C++ skeleton built with CMake. A small dummy library is included to verify the toolchain. zlib is used as a third-party dependency.

## Prerequisites

Before contributing to this project, ensure you have the following installed:

### Required Tools
- **Git** - For version control
- **CMake** (version 3.10 or higher) - For build configuration
  - *Current environment: CMake 4.0.3*
- **C++ Compiler** with C++11 support:
  - **Windows**: Visual Studio 2017+ (currently using VS 2022 Community)
    - Includes MSVC compiler and Clang-cl (Clang 19.1.5)
  - **Alternative**: MinGW-w64/MSYS2 GCC (currently GCC 14.2.0 available)
  - **Linux**: GCC 7+ or Clang 5+ (for cross-platform development)
  - **macOS**: Xcode 9+ or Clang 5+ (for cross-platform development)

### Optional but Recommended
- **Visual Studio Code** with CMake extension - For easy compiler switching
- **Git Bash** (Windows users) for better cross-platform script compatibility
- **MSYS2** (current environment) for Unix-like tools on Windows

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

#### Option A: Using Build Scripts (Recommended for beginners)

**On Windows:**
```batch
.\build.bat
```

**On Linux/macOS/Git Bash:**
```bash
./build.sh
```

#### Option B: Using Development Script (Advanced users)

```bash
# Build in debug mode (default)
./dev.sh build

# Build in release mode
./dev.sh release

# Build with shared libraries
./dev.sh shared

# Clean and rebuild
./dev.sh clean
./dev.sh build

# See all available options
./dev.sh help
```

#### Option C: Manual CMake Build

```bash
# Configure the project
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake

# Build the project
cmake --build build

# Run tests
ctest --test-dir build
```

### 4. Verify Installation

After building, test that everything works:

```bash
# Run tests
./dev.sh test

# Or manually:
cd build
ctest

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

## Project Structure

```
File-Parser/
├── include/           # Header files
│   ├── compression.h
│   └── dummy.h
├── src/              # Source files
│   ├── compression.cpp
│   ├── dummy.cpp
│   └── main.cpp
├── tests/            # Test files
│   └── dummy_test.cpp
├── build/            # Build artifacts (generated)
├── vcpkg/            # Dependency manager (submodule)
├── CMakeLists.txt    # CMake configuration
├── vcpkg.json        # Dependency specification
├── build.bat         # Windows build script
├── build.sh          # Cross-platform build script
├── COMPILER_SUPPORT.md    # Compiler verification info
└── dev.sh            # Development script with options
```

## Development Workflow

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** to the source code

3. **Build and test:**
   ```bash
   ./dev.sh build
   ./dev.sh test
   ```

4. **Run the application to verify:**
   ```bash
   ./dev.sh run
   ```

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
   ./dev.sh clean
   ./dev.sh build
   ```

## Build Options

- **Shared Libraries**: Use `-DBUILD_SHARED=ON` or `./dev.sh shared`
- **Debug Build**: Default mode, or use `./dev.sh debug`
- **Release Build**: Use `./dev.sh release`

## Compiler Support

This project has been successfully built with:
- **MSVC 19.44.35209** (Visual Studio 2022 Community) on Windows 10
- **Clang 19.1.5** (provided through Visual Studio 2022) on Windows 10
- **GCC 14.2.0** (MSYS2) available on Windows 10

The project uses Visual Studio 2022 generator by default. **To test different compilers**, use VS Code's `CMake: Select a Kit` command to switch between MSVC, Clang-cl, and GCC options.

For detailed compiler information and build configurations, see `COMPILER_SUPPORT.md`.

## Troubleshooting

### Common Issues

1. **vcpkg not found**: Make sure you've initialized submodules with `git submodule update --init --recursive` and bootstrapped vcpkg
2. **CMake errors**: Ensure CMake version is 3.10 or higher
3. **Compiler errors**: Verify your compiler supports C++11
4. **Permission errors** (Linux/macOS): Make scripts executable with `chmod +x *.sh`

### Getting Help

- Check the build logs in the `build/` directory
- Run `./dev.sh help` for development script options
- Ensure all prerequisites are installed
- Try a clean build: `./dev.sh clean && ./dev.sh build`

## Running the Application

After successful build:

```bash
./dev.sh run
```

The application demonstrates basic file compression/decompression functionality using zlib.
