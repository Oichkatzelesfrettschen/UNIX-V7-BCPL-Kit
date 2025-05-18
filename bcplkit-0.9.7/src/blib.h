/* Copyright (c) 2004 Robert Nordier.  All rights reserved. */

/* $Id: blib.h,v 1.3 2004/12/11 11:27:20 rn Exp $ */

#ifndef BLIB_H_
#define BLIB_H_

int getbyte(int, int);
void putbyte(int, int, int);
void initio(void);
int findinput(int);
int findoutput(int);
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
