#ifndef CONSTS_HPP
#define CONSTS_HPP


#include <string>

using namespace std;


#define  ASSEMBLE   1  // 00000001
#define  COMPILE    2  // 00000010
#define  EXECUTE    4  // 00000100
#define  FORCE      8  // 00001000
#define  LANG      16  // 00010000
#define  OUTFILE   32  // 00100000
#define  REMOVE    64  // 01000000

#define  HAS_ASSEMBLE(x)  (x & ASSEMBLE)
#define  HAS_COMPILE(x)   (x & COMPILE)
#define  HAS_EXECUTE(x)   (x & EXECUTE)
#define  HAS_FORCE(x)     (x & FORCE)
#define  HAS_LANG(x)      (x & LANG)
#define  HAS_OUTFILE(x)   (x & OUTFILE)
#define  HAS_REMOVE(x)    (x & REMOVE)

#define  NASM       "/usr/bin/nasm"
#define  LD         "/usr/bin/ld"
#define  GCC        "/usr/bin/gcc"
#define  PKGCONFIG  "/usr/bin/pkg-config"
#define  GPP        "/usr/bin/g++"


extern string USAGE;


#endif
