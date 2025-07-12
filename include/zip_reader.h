#ifndef ZIP_READER_H
#define ZIP_READER_H

#include <cstdint>
#include <string>
#include <vector>

#include "zip_entry.h"

struct zip;

/** Low level reader that opens a zip archive from file or memory. */
class ZipReader {
  public:
    explicit ZipReader(const std::string& _path);
    ZipReader(const std::uint8_t* _data, std::size_t _size);
    ~ZipReader();

    [[nodiscard]] bool isOpen() const;
    std::size_t entryCount() const;
    bool readEntry(std::size_t _index, ZipEntry& _entry) const;

  private:
    zip* archive_{};
};

#endif  // ZIP_READER_H
