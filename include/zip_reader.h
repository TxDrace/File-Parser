#ifndef ZIP_READER_H
#define ZIP_READER_H

#include <cstdint>
#include <fstream>
#include <memory>
#include <string>
#include <vector>

/** Represents a file entry within a ZIP archive. */
struct ZipFileEntry {
    std::string name;                     ///< File name
    std::uint32_t compressed_size{};      ///< Compressed size in bytes
    std::uint32_t uncompressed_size{};    ///< Uncompressed size in bytes
    std::uint32_t local_header_offset{};  ///< Offset of the local header
};

/** Abstract interface that provides random access to ZIP data. */
class ZipSource {
  public:
    virtual ~ZipSource() = default;
    /** Read a block of bytes from the source. */
    virtual bool read(std::uint64_t _offset, void* _buffer, std::size_t _size) = 0;
    /** Total size of the data in bytes. */
    virtual std::size_t size() const = 0;
};

/** Data source that reads from a file on disk using RAII. */
class FileZipSource : public ZipSource {
  public:
    explicit FileZipSource(const std::string& _path);
    bool read(std::uint64_t _offset, void* _buffer, std::size_t _size) override;
    std::size_t size() const override;

  private:
    std::ifstream file_;
    std::size_t file_size_{};
};

/** Data source that reads from an in-memory buffer. */
class MemoryZipSource : public ZipSource {
  public:
    MemoryZipSource(const std::uint8_t* _data, std::size_t _size);
    bool read(std::uint64_t _offset, void* _buffer, std::size_t _size) override;
    std::size_t size() const override;

  private:
    const std::uint8_t* data_;
    std::size_t size_;
};

/** Parser for ZIP archives. */
class ZipReader {
  public:
    explicit ZipReader(std::unique_ptr<ZipSource> _source);
    bool parse();
    const std::vector<ZipFileEntry>& files() const;

  private:
    std::unique_ptr<ZipSource> source_;
    std::vector<ZipFileEntry> files_;
};

#endif  // ZIP_READER_H
