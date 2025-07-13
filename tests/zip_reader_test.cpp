#include "zip_archive.h"
#include "zip_reader.h"

#include <chrono>
#include <filesystem>
#include <fstream>
#include <gtest/gtest.h>

namespace {
const std::uint8_t sample_zip[] = {
    80,  75,  3,   4,   20, 0, 0, 0,  0, 0,   208, 82,  234, 90,  134, 166, 16,  54,  5,   0,
    0,   0,   5,   0,   0,  0, 8, 0,  0, 0,   116, 101, 115, 116, 46,  116, 120, 116, 104, 101,
    108, 108, 111, 80,  75, 1, 2, 20, 3, 20,  0,   0,   0,   0,   0,   208, 82,  234, 90,  134,
    166, 16,  54,  5,   0,  0, 0, 5,  0, 0,   0,   8,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   128, 1,  0, 0, 0,  0, 116, 101, 115, 116, 46,  116, 120, 116, 80,  75,  5,
    6,   0,   0,   0,   0,  1, 0, 1,  0, 54,  0,   0,   0,   43,  0,   0,   0,   0,   0};
}

TEST(ZipArchive, LoadFromFile) {
    // build a unique temp path
    std::filesystem::path file_path =
        std::filesystem::temp_directory_path() /
        ("zip_reader_test_" +
         std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()));

    // write out the sample zip
    {
        std::ofstream file(file_path, std::ios::binary);
        file.write(reinterpret_cast<const char*>(sample_zip), sizeof(sample_zip));
    }

    // inner scope: reader is created, used, then destroyed
    {
        ZipArchive archive(file_path.string());
        ASSERT_TRUE(archive.load());
        ASSERT_EQ(archive.entries().size(), 1u);
        EXPECT_EQ(archive.entries()[0].name, "test.txt");
        EXPECT_EQ(archive.entries()[0].uncompressed_size, 5u);
    }

    // now it's safe to delete the file
    std::filesystem::remove(file_path);
}

TEST(ZipArchive, LoadFromMemory) {
    ZipArchive archive(sample_zip, sizeof(sample_zip));
    ASSERT_TRUE(archive.load());
    ASSERT_EQ(archive.entries().size(), 1u);
    EXPECT_EQ(archive.entries()[0].name, "test.txt");
    EXPECT_EQ(archive.entries()[0].uncompressed_size, 5u);
}

TEST(ZipReader, OpenFromMemoryValid) {
    ZipReader reader(sample_zip, sizeof(sample_zip));
    ASSERT_TRUE(reader.isOpen());
    EXPECT_EQ(reader.entryCount(), 1u);
    ZipEntry entry;
    ASSERT_TRUE(reader.readEntry(0, entry));
    EXPECT_EQ(entry.name, "test.txt");
    EXPECT_EQ(entry.uncompressed_size, 5u);
}

TEST(ZipReader, OpenFromFileValid) {
    std::filesystem::path file_path =
        std::filesystem::temp_directory_path() /
        ("zip_reader_file_" +
         std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()));

    {
        std::ofstream file(file_path, std::ios::binary);
        file.write(reinterpret_cast<const char*>(sample_zip), sizeof(sample_zip));
    }

    {
        ZipReader reader(file_path.string());
        ASSERT_TRUE(reader.isOpen());
        EXPECT_EQ(reader.entryCount(), 1u);
        ZipEntry entry;
        ASSERT_TRUE(reader.readEntry(0, entry));
        EXPECT_EQ(entry.name, "test.txt");
        EXPECT_EQ(entry.uncompressed_size, 5u);
    }

    std::filesystem::remove(file_path);
}

TEST(ZipReader, InvalidFilePath) {
    ZipReader reader("non_existent_file.zip");
    EXPECT_FALSE(reader.isOpen());
    EXPECT_EQ(reader.entryCount(), 0u);
    ZipEntry entry;
    EXPECT_FALSE(reader.readEntry(0, entry));
}

TEST(ZipReader, InvalidMemory) {
    const std::uint8_t invalid_zip[] = {1, 2, 3, 4};
    ZipReader reader(invalid_zip, sizeof(invalid_zip));
    EXPECT_FALSE(reader.isOpen());
    EXPECT_EQ(reader.entryCount(), 0u);
    ZipEntry entry;
    EXPECT_FALSE(reader.readEntry(0, entry));
}

TEST(ZipReader, InvalidIndex) {
    ZipReader reader(sample_zip, sizeof(sample_zip));
    ASSERT_TRUE(reader.isOpen());
    ZipEntry entry;
    EXPECT_FALSE(reader.readEntry(5, entry));
}
