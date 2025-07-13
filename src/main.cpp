#include "zip_archive.h"
#include "file_parser_error.h"
#include <iostream>

namespace {

void showUsage(const std::string& _program_name) {
    std::cout << "Usage: " << _program_name << " <command> [options]\n";
    std::cout << "Commands:\n";
    std::cout << "  zip <file_or_url>    Parse zip file and print details\n";
}

void printZipInfo(const std::string& _path) {
    ZipArchive archive(_path);
    archive.load();

    std::cout << "Archive contains " << archive.entries().size() << " entr";
    std::cout << (archive.entries().size() == 1 ? "y" : "ies") << "\n";
    for (const auto& entry : archive.entries()) {
        std::cout << "- " << entry.name << " (" << entry.compressed_size << " bytes compressed, "
                  << entry.uncompressed_size << " bytes uncompressed)\n";
    }
}

}  // namespace

int main(int argc, char* argv[]) {
    try {
        if (argc < 2) {
            showUsage(argv[0]);
            return 0;
        }

        std::string command = argv[1];
        if (command == "zip") {
            if (argc < 3) {
                throw MissingArgumentError("zip file path or URL");
            }
            printZipInfo(argv[2]);
            return 0;
        }

        throw UnknownCommandError(command);
    } catch (const FileParserError& _e) {
        std::cerr << _e.what() << '\n';
        return 1;
    } catch (const std::exception& _e) {
        std::cerr << "Unexpected error: " << _e.what() << '\n';
        return 1;
    }
}
