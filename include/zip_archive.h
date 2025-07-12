#ifndef ZIP_ARCHIVE_H
#define ZIP_ARCHIVE_H

#include "zip_reader.h"

#include <string>
#include <vector>
#include <cstdint>

/** Represents a single file entry inside a zip archive. */
struct ZipEntry {
    std::string name;                 ///< File name
    std::uint64_t compressed_size{};  ///< Compressed size in bytes
    std::uint64_t uncompressed_size{};///< Uncompressed size in bytes
};

/** High level interface for inspecting a zip archive. */
class ZipArchive {
  public:
    explicit ZipArchive(const std::string& _path);
    ZipArchive(const std::uint8_t* _data, std::size_t _size);

    bool load();
    const std::vector<ZipEntry>& entries() const;

  private:
    ZipReader reader_;
    std::vector<ZipEntry> entries_;
};

#endif  // ZIP_ARCHIVE_H
