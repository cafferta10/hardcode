#include "pwpdemo.h"

/*
char texture1[32*32]={
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x99,0x89,0x89,0x89,0x89,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x99,0x99,0x89,0x89,0x89,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x89,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x89,0x89,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x10,0x10,0x10,0x89,0x99,0x10,0x10,0x89,0x99,0x99,0x89,0x99,0x99,0x89,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,
0x01,0x10,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x99,0x99,0x99,0x89,0x89,0x89,0x89,0x99,0x99,0x99,0x99,0x89,0x10,0x89,0x99,0x10,0x01,0x01,
0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x10,0x10,0x10,0x89,0x89,0x99,0x99,0x89,0x89,0x89,0x89,0x89,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x89,0x99,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x89,0x89,0x99,0x99,0x89,0x89,0x89,0x89,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,
0x10,0x01,0x01,0x01,0x10,0x10,0x99,0x99,0x89,0x99,0x99,0x99,0x89,0x10,0x10,0x10,0x99,0x99,0x99,0x89,0x89,0x99,0x99,0x99,0x10,0x99,0x10,0x10,0x10,0x10,0x10,0x10,
0x10,0x01,0x01,0x10,0x10,0x89,0x99,0x99,0x89,0x89,0x99,0x99,0x99,0x10,0x01,0x10,0x10,0x99,0x89,0x89,0x89,0x89,0x99,0x99,0x99,0x99,0x10,0x10,0x89,0x99,0x99,0x10,
0x10,0x01,0x01,0x10,0x99,0x99,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x01,0x01,0x10,0x10,0x10,0x99,0x99,0x89,0x89,0x89,0x89,0x89,0x89,0x10,0x10,0x10,0x89,0x89,
0x10,0x01,0x01,0x10,0x99,0x99,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x99,0x99,0x99,0x89,0x89,0x99,0x10,0x10,0x10,0x01,0x10,0x10,0x10,
0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x89,0x89,0x99,0x99,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x99,0x99,0x99,0x99,0x89,0x89,0x99,0x99,0x99,0x99,0x89,0x99,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x10,0x10,0x10,0x10,0x89,0x89,0x10,0x10,0x10,0x10,0x10,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x99,0x89,0x99,0x99,0x89,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,
0x10,0x10,0x10,0x99,0x99,0x89,0x89,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x89,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x99,0x99,0x89,0x89,0x10,0x10,0x10,0x01,0x01,0x01,
0x10,0x89,0x89,0x99,0x99,0x89,0x89,0x99,0x99,0x89,0x89,0x89,0x89,0x89,0x99,0x99,0x99,0x89,0x99,0x10,0x89,0x89,0x89,0x89,0x99,0x99,0x99,0x89,0x10,0x10,0x01,0x01,
0x10,0x89,0x89,0x89,0x89,0x99,0x99,0x89,0x89,0x99,0x99,0x89,0x89,0x99,0x99,0x89,0x99,0x99,0x99,0x10,0x10,0x89,0x89,0x99,0x99,0x99,0x99,0x89,0x99,0x10,0x01,0x01,
0x10,0x10,0x10,0x10,0x89,0x99,0x99,0x89,0x99,0x99,0x99,0x99,0x99,0x89,0x89,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,
0x89,0x89,0x89,0x89,0x89,0x89,0x89,0x89,0x99,0x99,0x99,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x89,0x89,0x99,0x99,0x99,0x10,
0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,
0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x10,0x89,0x99,0x99,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x10,0x89,0x10,0x10,0x89,0x89,0x89,0x89,0x89,0x10,0x10,0x10,0x10,0x10,0x01,0x01,
0x01,0x01,0x01,0x10,0x99,0x99,0x10,0x10,0x10,0x89,0x89,0x99,0x10,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x89,0x89,0x89,0x99,0x99,0x99,0x10,0x01,0x01,
0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x01,0x10,0x10,0x89,0x99,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x89,0x99,0x10,0x99,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x89,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01
};
*/

unsigned char texture1[32*32]={
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0xaa,0x8a,0x8a,0x8a,0x8a,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0xaa,0xaa,0x8a,0x8a,0x8a,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x8a,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x02,0x02,0x02,0x8a,0xaa,0x02,0x02,0x8a,0xaa,0xaa,0x8a,0xaa,0xaa,0x8a,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,
0x00,0x02,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0xaa,0xaa,0xaa,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0x8a,0x02,0x8a,0xaa,0x02,0x00,0x00,
0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x02,0x02,0x02,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0x8a,0x8a,0x8a,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x8a,0xaa,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0x8a,0x8a,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,
0x02,0x00,0x00,0x00,0x02,0x02,0xaa,0xaa,0x8a,0xaa,0xaa,0xaa,0x8a,0x02,0x02,0x02,0xaa,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0xaa,0x02,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,
0x02,0x00,0x00,0x02,0x02,0x8a,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0xaa,0x02,0x00,0x02,0x02,0xaa,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0x02,0x02,0x8a,0xaa,0xaa,0x02,
0x02,0x00,0x00,0x02,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x00,0x00,0x02,0x02,0x02,0xaa,0xaa,0x8a,0x8a,0x8a,0x8a,0x8a,0x8a,0x02,0x02,0x02,0x8a,0x8a,
0x02,0x00,0x00,0x02,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0xaa,0xaa,0xaa,0x8a,0x8a,0xaa,0x02,0x02,0x02,0x00,0x02,0x02,0x02,
0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0xaa,0xaa,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0x8a,0xaa,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x02,0x02,0x02,0x02,0x8a,0x8a,0x02,0x02,0x02,0x02,0x02,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0x8a,0xaa,0xaa,0x8a,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,
0x02,0x02,0x02,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0x8a,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0x8a,0x8a,0x02,0x02,0x02,0x00,0x00,0x00,
0x02,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0x8a,0xaa,0x02,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0x8a,0x02,0x02,0x00,0x00,
0x02,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x8a,0x8a,0xaa,0xaa,0x8a,0xaa,0xaa,0xaa,0x02,0x02,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0x8a,0xaa,0x02,0x00,0x00,
0x02,0x02,0x02,0x02,0x8a,0xaa,0xaa,0x8a,0xaa,0xaa,0xaa,0xaa,0xaa,0x8a,0x8a,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
0x8a,0x8a,0x8a,0x8a,0x8a,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x8a,0x8a,0xaa,0xaa,0xaa,0x02,
0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x02,0x8a,0xaa,0xaa,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x02,0x8a,0x02,0x02,0x8a,0x8a,0x8a,0x8a,0x8a,0x02,0x02,0x02,0x02,0x02,0x00,0x00,
0x00,0x00,0x00,0x02,0xaa,0xaa,0x02,0x02,0x02,0x8a,0x8a,0xaa,0x02,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x8a,0x8a,0x8a,0xaa,0xaa,0xaa,0x02,0x00,0x00,
0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x00,0x02,0x02,0x8a,0xaa,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x8a,0xaa,0x02,0xaa,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x02,0x02,0x02,0x8a,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};

void scroller_do(int t,int hg)
{
        u8*d=pwplib_buf;

	static int lastt=0;
	int y,offy,k=120;

        if(hg<0)hg=0;else if(hg>pwplib_bufh-1)
          hg=pwplib_bufh-1;

        memset(d,0x11,pwplib_bufw*(pwplib_bufh-hg));
        d+=pwplib_bufw*(pwplib_bufh-hg);

        for(y=0;y<hg;y++)
        {
             register int dofz=(hg*64*80/pwplib_bufw)/(y+3),
	                  ofz=t*32-dofz*20-((dofz>>4)*32*256);
             {int x=pwplib_bufw;
                  for(;x;x--)*d++=texture1[((ofz+=dofz)>>8)&1023];}
	     k-=(k>>3);
	}
}