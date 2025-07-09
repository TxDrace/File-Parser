#include "compression.h"
#include <zlib.h>

std::string getZlibVersion() { return std::string(zlibVersion()); }
