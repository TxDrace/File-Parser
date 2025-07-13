#ifndef ZIP_ARCHIVE_H
#define ZIP_ARCHIVE_H

#include "zip_entry.h"
#include "zip_reader.h"

#include <cstdint>
#include <string>
#include <vector>

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
