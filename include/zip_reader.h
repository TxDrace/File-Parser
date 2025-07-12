#ifndef ZIP_READER_H
#define ZIP_READER_H

#include <cstdint>
#include <string>

#include <zip.h>

/** Low level reader that opens a zip archive from file or memory. */
class ZipReader {
  public:
    explicit ZipReader(const std::string& _path);
    ZipReader(const std::uint8_t* _data, std::size_t _size);
    ~ZipReader();

    [[nodiscard]] zip_t* handle() const;

  private:
    zip_t* archive_{};
};

#endif  // ZIP_READER_H
