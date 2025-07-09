General:
- Suggest code (and comment if neccessary) in English, regardless language of the prompt.
- After every change, update the project structure section so that it correctly reflects the project.

Project Structure:
- docs/
    - README.md
    - bugs/
        - README.md
        - windows-build-configuration-fix.md
        - windows-shared-library-fix.md
    - inside/
        - BUILD.md
        - CODE_QUALITY.md
        - COMPILER_SUPPORT.md
    - task-reports/
        - template.md
        - issue-3-unit-testing-framework.md
- AGENTS.md
- CONTRIBUTING.md
- README.md
- CMakeLists.txt
- dev.sh
- vcpkg.json
- include/
    - compression.h
    - dummy.h
- src/
    - compression.cpp
    - dummy.cpp
    - main.cpp
- tests/
    - dummy_test.cpp
    - sample_test.cpp
- vcpkg/

Naming Convention:
- For variable: use snake_case
- For function parameters: use _snake_case_with_hyperscore_before
- For function name: user camelCase()

How to write task report (in docs\task-reports): 
- This is place for report per issue
- The report is .md file, 
- The structure of the report must follow the structure of the template docs\task-reports\template.md
