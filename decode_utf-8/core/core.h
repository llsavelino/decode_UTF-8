#pragma once
#ifndef DECODE_RESULT_H
#define DECODE_RESULT_H

#include <stdint.h>
#define uc8 unsigned char

#ifdef __cplusplus
extern "C" {
#endif

typedef struct { uint32_t r; unsigned int s; const char* err; } DecodeResult;

uint32_t Bytes2_utf8(uc8* x, uc8* y);
uint32_t Bytes3_utf8(uc8* x, uc8* y, uc8* z);
uint32_t Bytes4_utf8(uc8* x, uc8* y, uc8* z, uc8* w);

#ifdef __cplusplus
}
#endif
#endif // DECODE_RESULT_H
