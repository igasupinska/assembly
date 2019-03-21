# assembly

Two programs written as an introduction to Intel x86-64 assembly language for a course in Operating Systems.

### Attack
Project that describes a fight between big-endian and little-endian nations. Both nations exchange binary files and the task is to detect whether a file contains hidden message indicating an attack.

Formally, one needs to read the file containg 32-bit numbers and determine whether:
* file doesn't contain number 68020,
* file contains number greater than 68020 and smaller than 2^31,
* file contains sequece 6, 8, 0, 2, 0,
* sum of all numbers modulo 2^32 equals 68020.

Program exits with code 1 if the file satisfies all of the above (hence there's an attack), or with code 0 otherwise.
