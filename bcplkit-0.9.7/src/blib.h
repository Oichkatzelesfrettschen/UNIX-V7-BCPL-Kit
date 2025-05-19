/* Copyright (c) 2004 Robert Nordier.  All rights reserved. */

/* $Id: blib.h,v 1.3 2004/12/11 11:27:20 rn Exp $ */

#ifndef BLIB_H_
#define BLIB_H_

#include <stdint.h>

/* INTCODE word access helpers */
int32_t getbyte(intptr_t, intptr_t);
void putbyte(intptr_t, intptr_t, int32_t);
void initio(void);
int findinput(intptr_t);
int findoutput(intptr_t);
void selectinput(int);
void selectoutput(int);
int input(void);
int output(void);
int rdch(void);
void wrch(int);
void endread(void);
void endwrite(void);
void mapstore(void);

#endif
