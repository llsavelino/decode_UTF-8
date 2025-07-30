#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "core/core.h"

// Char. number range  |        UTF-8 octet sequence
//    (hexadecimal)    |              (binary)
// --------------------+---------------------------------------------
// 0000 0000-0000 007F | 0xxxxxxx
// 0000 0080-0000 07FF | 110xxxxx 10xxxxxx
// 0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
// 0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

DecodeResult decodeRune(const unsigned char* b, size_t len) {

    if (b == NULL || len <= 0) 
    { return (DecodeResult){ .r = 0, .s = 0, .err = "null input | empty input"};}
    
    unsigned char b0 = b[0];

    if (b0 < 0x80) { // ASCII
        
        if (len > 1) if ((b[1] & 0xC0) == 0x80) return (DecodeResult)
        { .r = 0, .s = 0, .err = "invalid length"};
        
        return (DecodeResult){ .r = (uint32_t)b0, .s = 1, .err = NULL};
    }
    else if ((b0 & 0xE0) == 0xC0) { // 2 byte character
        
        if (len < 2) return (DecodeResult){ .r = 0, .s = 0, .err = "invalid length"};
        if (len > 2) if ((b[2] & 0xC0) == 0x80) return (DecodeResult)
        { .r = 0, .s = 0, .err = "invalid length"};

        unsigned char b1 = b[1];

        if ((b1 & 0xC0) != 0x80) 
        {    return (DecodeResult){ .r = 0, .s = 0, .err = "invalid continuation byte"};}

        uint32_t r = ((uint32_t)(b0 & 0x1F) << 6) |
                    (uint32_t)(b1 & 0x3F);

        if (r < 0x80) return (DecodeResult){ .r = 0, .s = 0, .err = "overlong"};
        if (r >= 0xD800 && r <= 0xDFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "surrogate halfs"};
        if (r > 0x10FFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "too big"};
        
        return (DecodeResult){ .r = r, .s = 2, .err = NULL};
    }
    else if ((b0 & 0xF0) == 0xE0) { // 3 byte character
        
        if (len < 3) return (DecodeResult){ .r = 0, .s = 0, .err = "invalid length"};
        if (len > 3) if ((b[3] & 0xC0) == 0x80) return (DecodeResult)
        { .r = 0, .s = 0, .err = "invalid length"};
        
        unsigned char b1 = b[1]; unsigned char b2 = b[2];

        if ((b1 & 0xC0) != 0x80 || (b2 & 0xC0) != 0x80) 
        {   return (DecodeResult){ .r = 0, .s = 0, .err = "invalid continuation byte"};}
        
        uint32_t r = ((uint32_t)(b0 & 0x0F) << 12) |
                    ((uint32_t)(b1 & 0x3F) << 6) |
                    (uint32_t)(b2 & 0x3F);

        if (r < 0x800 || (b0 == 0xE0 && b1 < 0xA0)) return (DecodeResult){ .r = 0, .s = 0, .err = "overlong"};
        if (r >= 0xD800 && r <= 0xDFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "surrogate halfs"};
        if (r > 0x10FFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "too big"};
        
        return (DecodeResult){ .r = r, .s = 3, .err = NULL};
    }
    else if ((b0 & 0xF8) == 0xF0) { // 4 byte character
        
        if (len < 4) return (DecodeResult){ .r = 0, .s = 0, .err = "invalid length"};
        if (len > 4) if ((b[4] & 0xC0) == 0x80) return (DecodeResult)
        { .r = 0, .s = 0, .err = "invalid length"};
        
        unsigned char b1 = b[1]; unsigned char b2 = b[2]; unsigned char b3 = b[3];

        if ((b1 & 0xC0) != 0x80 || (b2 & 0xC0) != 0x80 || (b3 & 0xC0) != 0x80) 
        {    return (DecodeResult){ .r = 0, .s = 0, .err = "invalid continuation byte"};}

        uint32_t r = ((uint32_t)(b0 & 0x07) << 18) |
                    ((uint32_t)(b1 & 0x3F) << 12) |
                    ((uint32_t)(b2 & 0x3F) << 6) |
                    (uint32_t)(b3 & 0x3F);

        if (r < 0x10000 || (b0 == 0xF0 && b1 < 0x90)) return (DecodeResult){ .r = 0, .s = 0, .err = "overlong"};
        if (r >= 0xD800 && r <= 0xDFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "surrogate halfs"};
        if (r > 0x10FFFF) return (DecodeResult){ .r = 0, .s = 0, .err = "too big"};
        
        return (DecodeResult){ .r = r, .s = 4, .err = NULL};
    }
    else return (DecodeResult){ .r = 0, .s = 0, .err = "invalid utf8"};
}

// Test function
int main(void) {
    // Test cases
    const char* test1 = "A";  // 1 byte
    const char* test2 = "¢";  // 2 bytes
    const char* test3 = "ह";  // 3 bytes
    const char* test4 = "𐍈";  // 4 bytes
    
    DecodeResult result;
    
    result = decodeRune((const unsigned char*)test1, strlen(test1));
    printf("Test1: r=%d, Rune: U+%04X, s=%d, err=%s\n", result.r, result.r,
        result.s, result.err ? result.err : "NULL");
    result = decodeRune((const unsigned char*)test2, strlen(test2));
    printf("Test2: r=%d, Rune: U+%04X, s=%d, err=%s\n", result.r, result.r,
        result.s, result.err ? result.err : "NULL");
    result = decodeRune((const unsigned char*)test3, strlen(test3));
    printf("Test3: r=%d, Rune: U+%04X, s=%d, err=%s\n", result.r, result.r, 
        result.s, result.err ? result.err : "NULL");   
    result = decodeRune((const unsigned char*)test4, strlen(test4));
    printf("Test4: r=%d, Rune: U+%04X, s=%d, err=%s\n", result.r, result.r, 
        result.s, result.err ? result.err : "NULL");
    
    return 0;
}