#include "zip_archive.h"

ZipArchive::ZipArchive(const std::string& _path) : reader_(_path) {}

ZipArchive::ZipArchive(const std::uint8_t* _data, std::size_t _size)
    : reader_(_data, _size) {}

void ZipArchive::load() {
    std::size_t count = reader_.entryCount();
    entries_.clear();
    for (std::size_t i = 0; i < count; ++i) {
        ZipEntry entry;
        reader_.readEntry(i, entry);
        entries_.push_back(entry);
    }
}

const std::vector<ZipEntry>& ZipArchive::entries() const { return entries_; }
