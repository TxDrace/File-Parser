General:
- Suggest code (and comment if neccessary) in English, regardless language of the prompt.
- After every change, update the project structure section so that it correctly reflects the project.

Project Structure:
- COMPILER_SUPPORT.md
- CODE_QUALITY.md
- BUILD.md
- AGENTS.md
- CONTRIBUTING.md
- README.md
- CMakeLists.txt
- dev.sh
- vcpkg.json
- doc/
    - windows-build-configuration-fix.md
    - windows-shared-library-fix.md
- include/
    - compression.h
    - dummy.h
- src/
    - compression.cpp
    - dummy.cpp
    - main.cpp
- tests/
    - dummy_test.cpp
- vcpkg/

Naming Convention:
- For variable: use snake_case
- For function parameters: use _snake_case_with_hyperscore_before
- For function name: user camelCase()
