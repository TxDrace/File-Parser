#ifndef ZIP_ENTRY_H
#define ZIP_ENTRY_H

#include <cstdint>
#include <string>

/** Represents a single file entry inside a zip archive. */
struct ZipEntry {
    std::string name;                 ///< File name
    std::uint64_t compressed_size{};  ///< Compressed size in bytes
    std::uint64_t uncompressed_size{};///< Uncompressed size in bytes
};

#endif  // ZIP_ENTRY_H
