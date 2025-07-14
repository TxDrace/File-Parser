# Issue Report: [10] - Handle Errors

## 1. Summary

Introduced structured error handling across the file parser using custom exception classes.

## 2. Background

* **Context:** The parser previously returned boolean error codes. This issue standardized failure reporting via exceptions.
* **Related Tickets/Discussions:** Issue #10.

## 3. Objectives

* **Goal 1:** Provide a hierarchy of exceptions for IO, parsing and CLI errors.
* **Goal 2:** Refactor archive classes and CLI to throw these errors.

## 4. Acceptance Criteria

* [x] Criterion 1: New `FileParserError` classes cover common failure cases.
* [x] Criterion 2: `ZipArchive` and `ZipReader` throw exceptions instead of returning `bool`.

## 5. Implementation Details

1. **Approach:** Added exception classes and converted all load and read functions to throw on error. The CLI now catches `FileParserError` types and prints messages.
2. **Files Changed:**
   * `include/file_parser_error.h`: Defined error hierarchy including `IoError`, `ParseError`, `ArchiveError` and CLI-related errors.
   * `src/file_parser_error.cpp`: Implemented constructors generating descriptive messages.
   * `include/zip_archive.h`: `load()` now returns `void` and no longer signals failure via return value.
   * `include/zip_reader.h`: `readEntry()` returns `void`; `entryCount()` throws when the archive is not open.
   * `src/zip_reader.cpp`: Reworked URL download, archive opening and entry reading logic to throw specific exceptions such as `FileNotFoundError` and `InvalidZipError`.
   * `src/zip_archive.cpp`: Updated to use the new `ZipReader` behavior.
   * `src/main.cpp`: Wrapped CLI operations in try/catch blocks and used `MissingArgumentError` and `UnknownCommandError` when needed.
   * `tests/zip_reader_test.cpp`: Updated and expanded tests for invalid paths, corrupt data, invalid entry indices and HTTP 401 responses.
3. **Key Code Snippets:**
```cpp
try {
    ZipArchive archive(path);
    archive.load();
} catch (const FileParserError& e) {
    std::cerr << e.what() << '\n';
}
```
4. **Libraries/Tools Used:**
   * libzip (via vcpkg)
   * Google Test

## 6. Testing

* **Unit Tests:** Extended `zip_reader_test.cpp` with failure cases using `EXPECT_THROW` macros.
* **Integration Tests:** `dev.sh test run` builds and executes tests on supported platforms.
* **Manual Verification Steps:**
  1. Build with `./dev.sh build debug`.
  2. Run `./dev.sh test run` to ensure all tests pass.

## 7. Screenshots / Diagrams

N/A

## 8. Impact Assessment

* **Affected Components:** Zip parser classes, CLI interface and tests.
* **Performance Impact:** Negligible; exceptions only arise on failure.
* **Security Considerations:** More robust error reporting helps diagnose malformed or malicious archives.

## 9. Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| Exception not caught in future code | Documented error hierarchy and provided unit tests |
| Network errors during URL download | Added `UrlDownloadError` and `AccessDeniedError` to surface HTTP failures |
