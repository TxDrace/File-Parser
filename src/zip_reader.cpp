#include "zip_reader.h"
#include "file_parser_error.h"

#include <curl/curl.h>
#include <string>
#include <vector>
#include <zip.h>

namespace {

bool isUrl(const std::string& _path) {
    return _path.rfind("http://", 0) == 0 || _path.rfind("https://", 0) == 0;
}

size_t writeToBuffer(void* _ptr, size_t _size, size_t _nmemb, void* _userdata) {
    auto* buffer = static_cast<std::vector<std::uint8_t>*>(_userdata);
    size_t total = _size * _nmemb;
    std::uint8_t* bytes = static_cast<std::uint8_t*>(_ptr);
    buffer->insert(buffer->end(), bytes, bytes + total);
    return total;
}

bool downloadUrl(const std::string& _url, std::vector<std::uint8_t>& _out) {
    CURL* curl = curl_easy_init();
    if (!curl) {
        return false;
    }
    curl_easy_setopt(curl, CURLOPT_URL, _url.c_str());
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeToBuffer);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &_out);
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);
    return res == CURLE_OK;
}

}  // namespace

ZipReader::ZipReader(const std::string& _path_or_url) {
    if (isUrl(_path_or_url)) {
        if (!downloadUrl(_path_or_url, buffer_)) {
            throw UrlDownloadError(_path_or_url);
        }

        zip_error_t error;
        zip_error_init(&error);
        zip_source_t* src =
            zip_source_buffer_create(buffer_.data(), buffer_.size(), 0, &error);
        if (!src) {
            std::string detail = zip_error_strerror(&error);
            zip_error_fini(&error);
            throw InvalidZipError(detail);
        }
        archive_ = zip_open_from_source(src, ZIP_RDONLY, &error);
        if (!archive_) {
            std::string detail = zip_error_strerror(&error);
            zip_source_free(src);
            zip_error_fini(&error);
            throw InvalidZipError(detail);
        }
        zip_error_fini(&error);
        return;
    }

    int error = 0;
    archive_ = zip_open(_path_or_url.c_str(), ZIP_RDONLY, &error);
    if (!archive_) {
        if (error == ZIP_ER_OPEN || error == ZIP_ER_NOENT) {
            throw FileNotFoundError(_path_or_url);
        }
        throw FileReadError(_path_or_url);
    }
}

ZipReader::ZipReader(const std::uint8_t* _data, std::size_t _size) {
    zip_error_t error;
    zip_error_init(&error);
    zip_source_t* src = zip_source_buffer_create(_data, _size, 0, &error);
    if (!src) {
        std::string detail = zip_error_strerror(&error);
        zip_error_fini(&error);
        throw InvalidZipError(detail);
    }
    archive_ = zip_open_from_source(src, ZIP_RDONLY, &error);
    if (!archive_) {
        std::string detail = zip_error_strerror(&error);
        zip_source_free(src);
        zip_error_fini(&error);
        throw InvalidZipError(detail);
    }
    zip_error_fini(&error);
}

ZipReader::~ZipReader() {
    if (archive_) {
        zip_close(archive_);
    }
}

bool ZipReader::isOpen() const { return archive_ != nullptr; }

std::size_t ZipReader::entryCount() const {
    if (!archive_) {
        throw ArchiveError("Archive not open");
    }
    zip_int64_t count = zip_get_num_entries(archive_, 0);
    if (count < 0) {
        throw InvalidZipError(zip_strerror(archive_));
    }
    return static_cast<std::size_t>(count);
}

void ZipReader::readEntry(std::size_t _index, ZipEntry& _entry) const {
    if (!archive_) {
        throw ArchiveError("Archive not open");
    }
    zip_stat_t sb;
    if (zip_stat_index(archive_, static_cast<zip_uint64_t>(_index), 0, &sb) != 0) {
        throw EntryReadError(std::to_string(_index));
    }
    _entry.name = sb.name ? sb.name : "";
    _entry.compressed_size = sb.comp_size;
    _entry.uncompressed_size = sb.size;
}
