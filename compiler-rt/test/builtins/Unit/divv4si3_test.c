// RUN: %clang_builtins %s %librt -o %t && %run %t
// REQUIRES: librt_has_divv4si3

#include <stdio.h>

// Returns: a % b

typedef int v4si __attribute__((__vector_size__(16)));
v4si __divv4si3(v4si a, v4si b);



int test__divv4si3(v4si a, v4si b, v4si expected_r)
{
    v4si r = __divv4si3(a, b);
    int res = 0;
    for (int lane = 0; lane < 4; ++lane)
      if (r[lane] != expected_r[lane]) {
        printf("error in __divv4si3 (lane %d): %X / %X = %X, expected %X\n",
               lane, a[lane], b[lane], r[lane], expected_r[lane]);
               res = 1;
      }
    return res;
}

v4si tests[][3] =
{
{{1, -1, 12, -101},        {10, 11, -11, -100},     {0, 0, -1, 1}},
{{1010, -9500, 0, -90}, {101, 95, 1, -91}, {10, -100, 0, 0}},
{{733700828, -1074162816, 413913109, -556347615}, {-1815467615, -919985178, -1322016045, 1583839069}, {0, 1, 0, 0}},
{{-541577867, -1094808216, 1915752591, 1519251063}, {1330680247, 197659806, 371462822, 625159208}, {0, -5, 5, 2}},
{{-665569017, -1821975812, -1221752427, 356500524}, {-1006533030, 669877777, -1581767944, -1991822045}, {0, -2, 0, 0}},
{{-1852911499, -175808264, -568142156, 700893609}, {176768800, 1788120164, -1907778547, -119548576}, {-10, 0, 0, -5}},
{{-904258708, 548110913, 353070733, -254940605}, {286612271, -1844516226, -266317530, 545040488}, {-3, 0, -1, 0}},
{{-2021497581, -528931705, 1849462043, 1133468611}, {1633490388, 1463002378, 194922800, -438325539}, {-1, 0, 9, -2}},
{{-1266175435, 939050183, -1023087003, 1768294063}, {125213076, 1162166782, -1942173189, -1780757600}, {-10, 0, 0, 0}},
{{1872996349, -1682334791, -1818666821, -1577877739}, {2115611076, -417334116, -1348200977, -1949286028}, {0, 4, 1, 0}},
{{620085907, 1918489185, 1394079640, -203649838}, {-640968039, 1292957176, -913200066, -2142191326}, {0, 1, -1, 0}},
{{-66069708, -1821194633, -575896124, 643712051}, {-1031163971, -204901895, -638919784, 1959499806}, {0, 8, 0, 0}},
{{-144900326, -921084140, -836810737, -1841451425}, {182532454, -365743904, 1849915232, -459173975}, {0, 2, 0, 4}},
};

int main()
{
    const unsigned N = sizeof(tests) / sizeof(tests[0]);
    unsigned i;
    for (i = 0; i < N; ++i)
        if (test__divv4si3(tests[i][0], tests[i][1], tests[i][2]))
            return 1;

    return 0;
}
