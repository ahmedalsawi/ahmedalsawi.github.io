---
title: "MD5 python implementation"
date: 2020-05-15T23:04:19+02:00
toc: false
images:
tags:
  - crypto
---

I thought it would be fun to implement MD5 from scratch. it was indeed fun but with few Gotchas. so, after shaking off PTSD, i wrote this post.

The [rfc1321](https://tools.ietf.org/html/rfc1321) defines MD5 digest algorithm. It also has reference C implementation which is nice (and needlessly complicated). That said, I don't think Python is really the best language for bit manipulations of binary files. but that is part of the fun, right?

# The padding
it starts with padding the message block. the final size of the message should be `b + p` 
```
b + p mod 512 = 448
```
where b is original message size and p is padding size. This is mentioned is this part of RFC

>   The message is "padded" (extended) so that its length (in bits) is
>   congruent to 448, modulo 512. That is, the message is extended so
>   that it is just 64 bits shy of being a multiple of 512 bits long.
>   Padding is always performed, even if the length of the message is
>   already congruent to 448, modulo 512.
>
>   Padding is performed as follows: a single "1" bit is appended to the
>   message, and then "0" bits are appended so that the length in bits of
>   the padded message becomes congruent to 448, modulo 512. In all, at
>   least one bit and at most 512 bits are appended.

it can be done with smarter way but i didn't want to burn any mental calories on this.

```python
    rem = message_len % 512
    if rem >= 448:
        num_padding = 512 -rem + 448
    else:
        num_padding = 448 - rem
    padding = bitarray('1'+ ('0' * (num_padding - 1)))
```

At this point, there are 64 bits free in the last 512 bit data block. the size of original message (b) is  appended to fill up these bits.

>   A 64-bit representation of b (the length of the message before the
>   padding bits were added) is appended to the result of the previous
>   step. In the unlikely event that b is greater than 2^64, then only
>   the low-order 64 bits of b are used. (These bits are appended as two
>   32-bit words and appended low-order word first in accordance with the
>   previous conventions.)


# The Buffers
the RFC defines 4 32-bit buffers  A,B,C,D. they are initialized with these values. 

>          word A: 01 23 45 67
>          word B: 89 ab cd ef
>          word C: fe dc ba 98
>          word D: 76 54 32 10

Gotcha, they are little endian. so, hex values are use like this.

```python
    A = hexstr_to_bitarray('67452301')
    B = hexstr_to_bitarray('efcdab89')
    C = hexstr_to_bitarray('98badcfe')
    D = hexstr_to_bitarray('10325476')

```

the final 128-bit  MD4 digest is the concatenation of 4 32-bit buffers with LITTLE ENDIAN.

# The building blocks
 first step is defining 4 operations as building block for the digest calculation 

>         F(X,Y,Z) = XY v not(X) Z
>         G(X,Y,Z) = XZ v Y not(Z)
>         H(X,Y,Z) = X xor Y xor Z
>         I(X,Y,Z) = Y xor (X v not(Z))

in python, easy enough:

```python
def F(x,y,z):
    return (x & y) | (~x & z)
def G(x,y,z):
    return (x & z) | (y & ~z)
def H(x,y,z):
    return (x ^ y ^ z)
def I(x,y,z):
    return y ^ (x | ~z)
```

Also, there is also operation that will be used in 4 rounds. more details below.

```python
"""
#a = b + ((a + func(b,c,d) + x + t) <<< s)
"""
def op(a, b, c , d, x, s, t, func):
    bit_tmp = func(b,c,d)
    bit_tmp  = add_bitarray(bit_tmp, x)
    bit_tmp  = add_bitarray(bit_tmp, a)

    bit_tmp  = add_bitarray(bit_tmp, t)
    bit_tmp  = rotate(bit_tmp,s)
    bit_tmp  = add_bitarray(bit_tmp,b)
    return bit_tmp
```
Side note, `add_bitarray` will be explained in the implementation details section

# The loop

The loop processes the 512-bit blocks and Move it to X array. X is 16 32-bit words (512 bits)

>   For i = 0 to N/16-1 do
>
>     /* Copy block i into X. */
>     For j = 0 to 15 do
>       Set X[j] to M[i*16+j].
>     end /* of loop on j */
>

the next part stores A,B,C,D in temp variables

>     /* Save A as AA, B as BB, C as CC, and D as DD. */
>     AA = A
>     BB = B
>     CC = C
>     DD = D
>

The RFC defines 4 rounds of calculations where A,B,C,D are updated by 64 operations. i am putting here only 16 operations to keep it short.

>     /* Round 1. */
>     /* Let [abcd k s i] denote the operation
>          a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s). */
>     /* Do the following 16 operations. */
>     [ABCD  0  7  1]  [DABC  1 12  2]  [CDAB  2 17  3]  [BCDA  3 22  4]
>     [ABCD  4  7  5]  [DABC  5 12  6]  [CDAB  6 17  7]  [BCDA  7 22  8]
>     [ABCD  8  7  9]  [DABC  9 12 10]  [CDAB 10 17 11]  [BCDA 11 22 12]
>     [ABCD 12  7 13]  [DABC 13 12 14]  [CDAB 14 17 15]  [BCDA 15 22 16]
>

again,  there is fancier way to do this but i wrote down the 64 operations to keep it verbose and simple. below, the first 4 operations. Note, `op` is defined above and takes the function `F` to apply on `b,c,d`. Round 2,3 and 4 use G,H,I functions for calculations.

```python
        A = op(A,B,C,D,X[0],7,T[1],F)
        D = op(D,A,B,C,X[1],12,T[2],F)
        C = op(C,D,A,B,X[2],17,T[3],F)
        B = op(B,C,D,A,X[3],22,T[4],F)
```

at the end of the loop, adding temp variables to the A,B,C,D buffers.

>     A = A + AA
>     B = B + BB
>     C = C + CC
>     D = D + DD

# Implementation details
I used `bitarray` package to to convert bytes to bits and used as main container throughout the program. it works with logical arithmetic but it doesn't work with  addition.
what make it worse, the algorithm assumes 32 bit operands and addition will overflow on `2^32` (at least in C). Obviously, i can't guarantee that in python. so, i wrote down the addition to make sure the results in under `2^32`. that can be seen in `add_bitarray`

```python
def hexstr_to_bitarray(h):
    ba = bitarray(endian='big')
    ba.frombytes(bytes.fromhex(h))
    return ba

def bitarray_to_hexstr(ba):
    return hex(int.from_bytes(ba.tobytes(),byteorder='big'))

def bitarray_to_int(ba):
    return int.from_bytes(ba.tobytes(),byteorder='big')

def int_to_bitarray(i):
     ba = bitarray()
     ba.frombytes(i.to_bytes(4,byteorder='big'))
     return ba

def add_bitarray(a,b):
    i1 = bitarray_to_int(a)
    i2 = bitarray_to_int(b)
    i3 = (i1 + i2) % pow(2,32)
    return int_to_bitarray(i3)
```