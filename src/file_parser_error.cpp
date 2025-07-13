#include "file_parser_error.h"

FileParserError::FileParserError(const std::string& _msg) : std::runtime_error(_msg) {}
IoError::IoError(const std::string& _msg) : FileParserError(_msg) {}
ParseError::ParseError(const std::string& _msg) : FileParserError(_msg) {}
ArchiveError::ArchiveError(const std::string& _msg) : FileParserError(_msg) {}
CliError::CliError(const std::string& _msg) : FileParserError(_msg) {}
FileNotFoundError::FileNotFoundError(const std::string& _path)
    : IoError("File not found: " + _path) {}
UrlDownloadError::UrlDownloadError(const std::string& _url)
    : IoError("Failed to download: " + _url) {}
AccessDeniedError::AccessDeniedError(const std::string& _url)
    : IoError("Access denied: " + _url) {}
FileReadError::FileReadError(const std::string& _path) : IoError("Failed to read: " + _path) {}
InvalidZipError::InvalidZipError(const std::string& _detail)
    : ParseError("Invalid zip archive: " + _detail) {}
EntryReadError::EntryReadError(const std::string& _entry_name)
    : ParseError("Failed to read entry: " + _entry_name) {}
UnsupportedCompressionError::UnsupportedCompressionError(const std::string& _detail)
    : ParseError("Unsupported compression method: " + _detail) {}
EntryNotFoundError::EntryNotFoundError(const std::string& _entry_name)
    : ArchiveError("Entry not found: " + _entry_name) {}
MissingArgumentError::MissingArgumentError(const std::string& _arg)
    : CliError("Missing argument: " + _arg) {}
UnknownCommandError::UnknownCommandError(const std::string& _cmd)
    : CliError("Unknown command: " + _cmd) {}
