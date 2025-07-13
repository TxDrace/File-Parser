#include "zip_archive.h"

ZipArchive::ZipArchive(const std::string& _path) : reader_(_path) {}

ZipArchive::ZipArchive(const std::uint8_t* _data, std::size_t _size)
    : reader_(_data, _size) {}

bool ZipArchive::load() {
    if (!reader_.isOpen()) {
        return false;
    }

    std::size_t count = reader_.entryCount();
    entries_.clear();
    for (std::size_t i = 0; i < count; ++i) {
        ZipEntry entry;
        if (!reader_.readEntry(i, entry)) {
            return false;
        }
        entries_.push_back(entry);
    }
    return true;
}

const std::vector<ZipEntry>& ZipArchive::entries() const { return entries_; }
