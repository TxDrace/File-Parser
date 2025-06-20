# Compiler Support

The project has been built and tested using the following compilers:

- **MSVC 19.44.35209** (Visual Studio 2022 Community) on Windows 10
- **Clang 19.1.5** (provided through Visual Studio 2022) on Windows 10
- **GCC 14.2.0** (MSYS2 project) available on Windows 10
- **CMake 4.0.3** for build configuration

**Note**: This project is currently configured and tested primarily on Windows using Visual Studio 2022 with multiple compiler options.

The provided CMake build scripts work with these compilers. The project is currently configured to use Visual Studio 2022 generator.

**Current Build Configuration:**
```cmd
# Default configuration (uses Visual Studio 2022)
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake

# Build the project
cmake --build build --config Release
```

**Switching Between Compilers:**

The easiest way to switch between different compilers is using VS Code's CMake extension:

1. **Using CMake: Select a Kit command in VS Code:**
   - Open Command Palette (`Ctrl+Shift+P`)
   - Run `CMake: Select a Kit`
   - Choose from available options:
     - Visual Studio Community 2022 Release - amd64 (MSVC)
     - Visual Studio Community 2022 Release - amd64_x86 (MSVC)
     - Clang for MSVC with Visual Studio Community 2022 (Clang-cl)
     - GCC (if MSYS2/MinGW is in PATH)

2. **Manual compiler selection:**

2. **Manual compiler selection:**

For Visual Studio Clang:
```cmd
# Using Clang with Visual Studio generator
cmake -B build -S . -G "Visual Studio 17 2022" -T ClangCL -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake
```

For MSYS2/MinGW-w64 GCC:
```bash
# GCC with MinGW Makefiles generator
cmake -B build -S . -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_CXX_COMPILER=g++
```

For other Visual Studio versions:
```cmd
# Visual Studio 2019
cmake -B build -S . -G "Visual Studio 16 2019" -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake
```

Running tests after build ensures the compilers are working correctly:

```bash
ctest --test-dir build
```

## Verifying Compiler Compatibility

To confirm the project works with different compilers:

1. **In VS Code (Recommended):**
   - Use `Ctrl+Shift+P` → `CMake: Select a Kit`
   - Choose a different compiler kit
   - Use `Ctrl+Shift+P` → `CMake: Configure` to reconfigure
   - Use `Ctrl+Shift+P` → `CMake: Build` to build
   - Use `Ctrl+Shift+P` → `CMake: Run Tests` to verify

2. **From Command Line:**
   ```bash
   # Clean previous build
   rm -rf build
   
   # Configure with specific compiler (example: Clang)
   cmake -B build -S . -G "Visual Studio 17 2022" -T ClangCL -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake
   
   # Build and test
   cmake --build build --config Release
   ctest --test-dir build -C Release
   ```

**Tested Compiler Combinations:**
- ✅ MSVC 19.44 (Visual Studio 2022) - Default
- ✅ Clang 19.1.5 (Visual Studio Clang-cl) - Tested via CMake kit selection
- ✅ GCC 14.2.0 (MSYS2) - Available for MinGW builds
