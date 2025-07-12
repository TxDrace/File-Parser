#include "zip_archive.h"

#include <zip.h>

ZipArchive::ZipArchive(const std::string& _path) : reader_(_path) {}

ZipArchive::ZipArchive(const std::uint8_t* _data, std::size_t _size)
    : reader_(_data, _size) {}

bool ZipArchive::load() {
    zip_t* zip_handle = reader_.handle();
    if (!zip_handle) {
        return false;
    }

    zip_int64_t count = zip_get_num_entries(zip_handle, 0);
    if (count < 0) {
        return false;
    }

    entries_.clear();
    for (zip_uint64_t i = 0; i < static_cast<zip_uint64_t>(count); ++i) {
        zip_stat_t sb;
        if (zip_stat_index(zip_handle, i, 0, &sb) != 0) {
            return false;
        }
        ZipEntry entry;
        entry.name = sb.name ? sb.name : "";
        entry.compressed_size = sb.comp_size;
        entry.uncompressed_size = sb.size;
        entries_.push_back(entry);
    }
    return true;
}

const std::vector<ZipEntry>& ZipArchive::entries() const { return entries_; }
