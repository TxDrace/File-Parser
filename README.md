# File Parse
For prerequisites, setup instructions, and the full development workflow, see [CONTRIBUTING.md](CONTRIBUTING.md). Additional documentation is available in [docs/README.md](docs/README.md).

## Project Structure

```
File-Parser/
├── docs/              # Additional documentation
│   ├── README.md
│   ├── bugs/
│   │   ├── README.md
│   │   ├── windows-build-configuration-fix.md
│   │   └── windows-shared-library-fix.md
│   ├── inside/
│   │   ├── README.md
│   │   ├── BUILD.md
│   │   ├── CODE_QUALITY.md
│   │   └── COMPILER_SUPPORT.md
│   └── task-reports/
│       ├── README.md
│       ├── template.md
│       ├── issue-3-unit-testing-framework.md
│       └── issue-6-github-actions-ci.md
├── include/           # Header files
│   ├── compression.h
│   ├── dummy.h
│   └── zip_reader.h
├── src/              # Source files
│   ├── compression.cpp
│   ├── dummy.cpp
│   ├── main.cpp
│   └── zip_reader.cpp
├── tests/            # Test files
│   ├── dummy_test.cpp
│   ├── sample_test.cpp
│   ├── zip_reader_test.cpp
│   └── data/          # Test assets created at runtime
├── build/            # Build artifacts (generated)
├── vcpkg/            # Dependency manager (submodule)
├── CMakeLists.txt    # CMake configuration
├── vcpkg.json        # Dependency specification
└── dev.sh            # Development script with all functionality
```

## Build Options

- **Shared Libraries**: Use `./dev.sh build shared`
- **Debug Build**: Default mode, or use `./dev.sh build debug`
- **Release Build**: Use `./dev.sh build release`

## Compiler Support

This project has been successfully built with:
- **MSVC 19.44.35209** (Visual Studio 2022 Community) on Windows 10
- **Clang 19.1.5** (provided through Visual Studio 2022) on Windows 10
- **GCC 14.2.0** (MSYS2) available on Windows 10

The project uses Visual Studio 2022 generator by default. **To test different compilers**, use VS Code's `CMake: Select a Kit` command to switch between MSVC, clang-cl, and GCC options.

For detailed compiler information and build configurations, see `docs/inside/COMPILER_SUPPORT.md`.

## Troubleshooting

### Common Issues

1. **vcpkg not found**: Make sure you've initialized submodules with `git submodule update --init --recursive` and bootstrapped vcpkg
2. **CMake errors**: Ensure CMake version is 3.10 or higher
3. **Compiler errors**: Verify your compiler supports C++23
4. **Permission errors** (Linux/macOS): Make scripts executable with `chmod +x *.sh`

### Getting Help

- Check the build logs in the `build/` directory
- Run `./dev.sh help` for development script options
- Ensure all prerequisites are installed
- Try a clean build: `./dev.sh build clean && ./dev.sh build debug`

## Running the Application

After successful build:

```bash
./dev.sh run
```

The application demonstrates basic file compression/decompression functionality using zlib.

## Running Tests

Run the unit tests to verify the build:

```bash
./dev.sh test run
```

You can also execute the tests directly with CTest:

```bash
ctest --test-dir build
```
