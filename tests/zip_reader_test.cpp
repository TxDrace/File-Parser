#include "zip_reader.h"

#include <filesystem>
#include <fstream>
#include <chrono>
#include <gtest/gtest.h>

namespace {
const std::uint8_t sample_zip[] = {
    80,  75,  3,  4,  20, 0,   0, 0, 0, 0, 208, 82, 234, 90,  134, 166, 16,
    54,  5,   0,  0,  0,  5,   0, 0, 0, 8,  0,   0,  0,  116, 101, 115, 116,
    46,  116, 120, 116, 104, 101, 108, 108, 111, 80, 75, 1,  2,  20, 3,  20,
    0,   0,   0,  0,  0,  208, 82, 234, 90, 134, 166, 16, 54, 5,  0,  0, 0,
    5,   0,   0,  0,  8,  0,   0, 0, 0,  0,   0,  0,  0,  0,   0,  0,  128, 1,
    0,   0,   0,  0,  116, 101, 115, 116, 46, 116, 120, 116, 80, 75, 5, 6,
    0,   0,   0,  0,  1,  0,   1, 0, 54, 0,  0, 0, 43, 0, 0, 0, 0, 0};
}

TEST(ZipReader, ParseFromFile) {
    // build a unique temp path
    std::filesystem::path file_path =
        std::filesystem::temp_directory_path() /
        ("zip_reader_test_" +
         std::to_string(
             std::chrono::steady_clock::now().time_since_epoch().count()));

    // write out the sample zip
    {
        std::ofstream file(file_path, std::ios::binary);
        file.write(reinterpret_cast<const char*>(sample_zip), sizeof(sample_zip));
    }

    // inner scope: reader is created, used, then destroyed
    {
        ZipReader reader(std::make_unique<FileZipSource>(file_path.string()));
        ASSERT_TRUE(reader.parse());
        ASSERT_EQ(reader.files().size(), 1u);
        EXPECT_EQ(reader.files()[0].name, "test.txt");
        EXPECT_EQ(reader.files()[0].uncompressed_size, 5u);
        // reader (and its FileZipSource) goes out-of-scope & closes here
    }

    // now it's safe to delete the file
    std::filesystem::remove(file_path);
}


TEST(ZipReader, ParseFromMemory) {
    auto reader =
        ZipReader(std::make_unique<MemoryZipSource>(sample_zip, sizeof(sample_zip)));
    ASSERT_TRUE(reader.parse());
    ASSERT_EQ(reader.files().size(), 1u);
    EXPECT_EQ(reader.files()[0].name, "test.txt");
    EXPECT_EQ(reader.files()[0].uncompressed_size, 5u);
}


