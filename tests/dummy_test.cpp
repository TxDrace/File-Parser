#include "dummy.h"
#include "compression.h"
#include <cassert>
#include <iostream>

int main() {
    assert(addNumbers(2, 3) == 5);
    std::string version = getZlibVersion();
    assert(!version.empty());
    std::cout << "zlib version: " << version << std::endl;
    return 0;
}
