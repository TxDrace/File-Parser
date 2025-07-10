#include "zip_reader.h"

#include <cstring>

namespace {
std::uint16_t readLe16(const std::uint8_t* _data) {
    return static_cast<std::uint16_t>(_data[0] | (_data[1] << 8));
}

std::uint32_t readLe32(const std::uint8_t* _data) {
    return static_cast<std::uint32_t>(_data[0] | (_data[1] << 8) | (_data[2] << 16) |
                                      (_data[3] << 24));
}
}  // namespace

FileZipSource::FileZipSource(const std::string& _path) {
    file_.open(_path, std::ios::binary);
    if (file_) {
        file_.seekg(0, std::ios::end);
        file_size_ = static_cast<std::size_t>(file_.tellg());
        file_.seekg(0, std::ios::beg);
    }
}

bool FileZipSource::read(std::uint64_t _offset, void* _buffer, std::size_t _size) {
    if (!file_) {
        return false;
    }
    file_.seekg(static_cast<std::streamoff>(_offset), std::ios::beg);
    file_.read(static_cast<char*>(_buffer), static_cast<std::streamsize>(_size));
    return static_cast<std::size_t>(file_.gcount()) == _size;
}

std::size_t FileZipSource::size() const { return file_size_; }

MemoryZipSource::MemoryZipSource(const std::uint8_t* _data, std::size_t _size)
    : data_(_data), size_(_size) {}

bool MemoryZipSource::read(std::uint64_t _offset, void* _buffer, std::size_t _size) {
    if (_offset + _size > size_) {
        return false;
    }
    std::memcpy(_buffer, data_ + _offset, _size);
    return true;
}

std::size_t MemoryZipSource::size() const { return size_; }

ZipReader::ZipReader(std::unique_ptr<ZipSource> _source) : source_(std::move(_source)) {}

const std::vector<ZipFileEntry>& ZipReader::files() const { return files_; }

bool ZipReader::parse() {
    if (!source_ || source_->size() < 22) {
        return false;
    }

    const std::uint32_t eocd_signature = 0x06054b50;
    const std::size_t max_comment = 0xFFFF;
    std::size_t search_start =
        source_->size() > (max_comment + 22) ? source_->size() - (max_comment + 22) : 0;
    std::vector<std::uint8_t> buffer(source_->size() - search_start);
    if (!source_->read(search_start, buffer.data(), buffer.size())) {
        return false;
    }

    std::size_t eocd_pos = std::string::npos;
    for (std::size_t i = buffer.size() - 22; i != static_cast<std::size_t>(-1); --i) {
        if (readLe32(buffer.data() + i) == eocd_signature) {
            eocd_pos = i;
            break;
        }
    }
    if (eocd_pos == std::string::npos) {
        return false;
    }

    const std::uint8_t* eocd = buffer.data() + eocd_pos;
    std::uint16_t entry_count = readLe16(eocd + 10);
    std::uint32_t cd_size = readLe32(eocd + 12);
    std::uint32_t cd_offset = readLe32(eocd + 16);

    std::vector<std::uint8_t> cd_data(cd_size);
    if (!source_->read(cd_offset, cd_data.data(), cd_size)) {
        return false;
    }

    std::size_t offset = 0;
    files_.clear();
    for (std::uint16_t i = 0; i < entry_count; ++i) {
        if (offset + 46 > cd_data.size()) {
            return false;
        }
        const std::uint8_t* header = cd_data.data() + offset;
        if (readLe32(header) != 0x02014b50) {
            return false;
        }
        std::uint16_t name_len = readLe16(header + 28);
        std::uint16_t extra_len = readLe16(header + 30);
        std::uint16_t comment_len = readLe16(header + 32);
        ZipFileEntry entry;
        entry.compressed_size = readLe32(header + 20);
        entry.uncompressed_size = readLe32(header + 24);
        entry.local_header_offset = readLe32(header + 42);
        if (offset + 46 + name_len > cd_data.size()) {
            return false;
        }
        entry.name.assign(reinterpret_cast<const char*>(header + 46), name_len);
        files_.push_back(entry);
        offset += 46 + name_len + extra_len + comment_len;
    }

    // Validate local file headers
    std::vector<std::uint8_t> lfh(30);
    for (auto& entry : files_) {
        if (!source_->read(entry.local_header_offset, lfh.data(), lfh.size())) {
            return false;
        }
        if (readLe32(lfh.data()) != 0x04034b50) {
            return false;
        }
        std::uint16_t name_len = readLe16(lfh.data() + 26);
        std::uint16_t extra_len = readLe16(lfh.data() + 28);
        std::vector<std::uint8_t> name_buf(name_len);
        if (!source_->read(entry.local_header_offset + 30, name_buf.data(), name_len)) {
            return false;
        }
        std::string local_name(reinterpret_cast<const char*>(name_buf.data()), name_len);
        if (local_name != entry.name) {
            return false;
        }
        entry.local_header_offset += 30 + name_len + extra_len;
    }

    return true;
}
