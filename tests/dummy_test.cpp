#include "compression.h"
#include "dummy.h"
#include <gtest/gtest.h>

TEST(DummyLibrary, AddNumbers) { EXPECT_EQ(addNumbers(2, 3), 5); }

TEST(DummyLibrary, ZlibVersionNotEmpty) { EXPECT_FALSE(getZlibVersion().empty()); }
