# Issue Report: [7] - Implement File I/O Layer and Application Layer for ZIP File Parsing

## 1. Summary

Implemented a full ZIP parsing stack using libzip and libcurl, including a CLI application that can load archives from disk or HTTP URLs.

## 2. Background

* **Context:** Needed a practical demonstration of file parsing with real file I/O and network support.
* **Related Tickets/Discussions:** Issue #7.

## 3. Objectives

* **Goal 1:** Provide C++ classes capable of reading ZIP archives from files or memory.
* **Goal 2:** Expose a command line tool to inspect archive contents.

## 4. Acceptance Criteria

* [x] Criterion 1: Zip files can be loaded from disk or memory.
* [x] Criterion 2: The CLI lists entries from local paths and HTTP/HTTPS URLs.

## 5. Implementation Details

1. **Approach:** Added RAII-based `ZipReader` and `ZipArchive` classes that wrap libzip handles. Network downloads are performed with libcurl when a URL is provided.
2. **Files Changed:**
   * `include/zip_reader.h`, `src/zip_reader.cpp`: Low-level loader supporting files, memory buffers and HTTP URLs.
   * `include/zip_archive.h`, `src/zip_archive.cpp`: High-level wrapper returning `ZipEntry` information.
   * `src/main.cpp`: New CLI command `zip` prints archive details.
   * `tests/zip_reader_test.cpp`: Extended to cover new functionality.
   * `CMakeLists.txt`, `vcpkg.json`: Link against libzip and libcurl.
3. **Key Code Snippets:**

```cpp
bool downloadUrl(const std::string& url, std::vector<std::uint8_t>& out) {
    CURL* curl = curl_easy_init();
    if (!curl) {
        return false;
    }
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeToBuffer);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &out);
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);
    return res == CURLE_OK;
}
```

4. **Libraries/Tools Used:**
   * libzip
   * libcurl
   * Google Test

## 6. Testing

* **Unit Tests:** `tests/zip_reader_test.cpp` verifies loading archives from files and memory and checks error handling.
* **Integration Tests:** CLI tested manually for local files and public HTTP URLs.
* **Manual Verification Steps:**
  1. Build with `./dev.sh build`.
  2. Run `./dev.sh run zip <path_or_url_to_zip>`.

## 7. Screenshots / Diagrams

N/A

## 8. Impact Assessment

* **Affected Components:** Library code, CLI application, build configuration.
* **Performance Impact:** Minor overhead when downloading via HTTP.
* **Security Considerations:** Network input is validated by libcurl; no file writing occurs.

## 9. Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| Invalid URLs or corrupted archives | Added checks for `isOpen()` and return codes |
| Network availability issues | Falls back to local file handling if download fails |

