#include "zip_reader.h"

#include <zip.h>

ZipReader::ZipReader(const std::string& _path) {
    int error = 0;
    archive_ = zip_open(_path.c_str(), ZIP_RDONLY, &error);
}

ZipReader::ZipReader(const std::uint8_t* _data, std::size_t _size) {
    zip_error_t error;
    zip_error_init(&error);
    zip_source_t* src = zip_source_buffer_create(_data, _size, 0, &error);
    if (!src) {
        zip_error_fini(&error);
        archive_ = nullptr;
        return;
    }
    archive_ = zip_open_from_source(src, ZIP_RDONLY, &error);
    if (!archive_) {
        zip_source_free(src);
    }
    zip_error_fini(&error);
}

ZipReader::~ZipReader() {
    if (archive_) {
        zip_close(archive_);
    }
}

zip_t* ZipReader::handle() const { return archive_; }
