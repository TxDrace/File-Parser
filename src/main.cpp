#include "compression.h"
#include "dummy.h"
#include <iostream>

int main() {
    int sum = addNumbers(2, 3);
    std::cout << "Result: " << sum << std::endl;
    std::cout << "Using zlib version: " << getZlibVersion() << std::endl;
    return 0;
}
