# General:
- Suggest code (and comment if neccessary) in English, regardless language of the prompt.
- After every change, update the project structure section so that it correctly reflects the project.

# Project Structure:
- docs/
    - README.md
    - bugs/
        - README.md
        - windows-build-configuration-fix.md
        - windows-shared-library-fix.md
    - inside/
        - README.md
        - BUILD.md
        - CODE_QUALITY.md
        - COMPILER_SUPPORT.md
    - task-reports/
        - README.md
        - template.md
        - issue-3-unit-testing-framework.md
        - issue-6-github-actions-ci.md
- AGENTS.md
- CONTRIBUTING.md
- README.md
- CMakeLists.txt
- dev.sh
- vcpkg.json
- .github/
    - workflows/
        - ci.yml
 - include/
    - zip_archive.h
    - zip_entry.h
    - zip_reader.h
 - src/
    - zip_archive.cpp
    - zip_reader.cpp
    - main.cpp
 - tests/
    - zip_reader_test.cpp
 - vcpkg/

# Naming Convention:
- For variable: use snake_case
- For function parameters: use _snake_case_with_underscore_before
- For function name: use camelCase()

# How to write task report (in docs\\task-reports):
- This is place for report per issue
- The report is .md file,
- The structure of the report must follow the structure of the template docs\\task-reports\\template.md
- Only make a new report file when I told you

# Developement
- How to build ? -> Follow the instructions in docs\inside\BUILD.md
- How to test quality ? -> Follow the instructions in docs\inside\CODE_QUALITY.md
