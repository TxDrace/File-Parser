#ifndef FILE_PARSER_ERROR_H
#define FILE_PARSER_ERROR_H

#include <stdexcept>
#include <string>

class FileParserError : public std::runtime_error {
  public:
    explicit FileParserError(const std::string& _msg);
    virtual ~FileParserError() = default;
};

class IoError : public FileParserError {
  public:
    explicit IoError(const std::string& _msg);
};

class ParseError : public FileParserError {
  public:
    explicit ParseError(const std::string& _msg);
};

class ArchiveError : public FileParserError {
  public:
    explicit ArchiveError(const std::string& _msg);
};

class CliError : public FileParserError {
  public:
    explicit CliError(const std::string& _msg);
};

class FileNotFoundError : public IoError {
  public:
    explicit FileNotFoundError(const std::string& _path);
};

class UrlDownloadError : public IoError {
  public:
    explicit UrlDownloadError(const std::string& _url);
};

class AccessDeniedError : public IoError {
  public:
    explicit AccessDeniedError(const std::string& _url);
};

class FileReadError : public IoError {
  public:
    explicit FileReadError(const std::string& _path);
};

class InvalidZipError : public ParseError {
  public:
    explicit InvalidZipError(const std::string& _detail);
};

class EntryReadError : public ParseError {
  public:
    explicit EntryReadError(const std::string& _entry_name);
};

class UnsupportedCompressionError : public ParseError {
  public:
    explicit UnsupportedCompressionError(const std::string& _detail);
};

class EntryNotFoundError : public ArchiveError {
  public:
    explicit EntryNotFoundError(const std::string& _entry_name);
};

class MissingArgumentError : public CliError {
  public:
    explicit MissingArgumentError(const std::string& _arg);
};

class UnknownCommandError : public CliError {
  public:
    explicit UnknownCommandError(const std::string& _cmd);
};

#endif  // FILE_PARSER_ERROR_H
