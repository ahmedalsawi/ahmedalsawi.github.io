---
title: "Python int/hex and bytes"
date: 2021-04-22T22:15:10+01:00

tags:
- Python
---

few years ago, i tried to write ELF parser in python and it was fun to write hacky code to parse and manipulate binary/hex (not easy though). This is quick write-up to decribe python bin/hex methods.

# ord and chr
`ord` takes string of one char and returns ascii code. The doc descibes it as:

> Given a string representing one Unicode character, return an integer representing the Unicode code point of that character. For example, ord('a') returns the integer 97 and ord('€') (Euro sign) returns 8364. This is the inverse of chr().

```python
In [22]: ord('a')
Out[22]: 97

In [23]: chr(97)
Out[23]: 'a'
```

# int, hex, bin, oct

*int* takes string and returns int based on passed *base*.

```
In [18]: int("10", base=10)
Out[18]: 10


In [20]: int("0xf", base=16)
Out[20]: 15

```

*hex*, *bin*, *oct* take integer and return string prefixed *0x*, *0o*, *0b*

```
In [24]: hex(10)
Out[24]: '0xa'

In [25]: oct(10)
Out[25]: '0o12'

In [26]: bin(10)
Out[26]: '0b1010'

```

# bytes and bytearray


> class bytes([source[, encoding[, errors]]])
> Return a new “bytes” object, which is an immutable sequence of integers in the range 0 <= x < 256. bytes is an immutable version of bytearray – it has the same non-mutating methods and the same indexing and slicing behavior.


bytes are strings prefixed with *b*

```python
In [28]: x = b''

In [29]: type(x)
Out[29]: bytes
In [41]: x = bytes()

In [42]: type(x)
Out[42]: bytes
```

Basically, bytes is list elements(each is byte) but if the byte maps to ascii it will map it that. *fromhex* can be used to convert hex string to bytes. notice *0x2e* is printed as *.*

```python
In [43]: bytes.fromhex("2ef0 ff")
Out[43]: b'.\xf0\xff'
```

and *.hex* on bytes be used to return string of hex back

```python
In [44]: x = bytes.fromhex("2ef0 ff")

In [45]: x.hex()
Out[45]: '2ef0ff'

```
 Slicing into bytes is allowed and it returns *int*. Note that Byte array is immutable so can't assign to slice.

```python
In [47]: x [1]
Out[47]: 240

In [48]: hex(x [1])
Out[48]: '0xf0'

In [49]: x [1] = 4
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-49-5f643ec4a398> in <module>
----> 1 x [1] = 4

TypeError: 'bytes' object does not support item assignment

```

on the other hand, bytearray is mutuable.
> bytearray objects are a mutable counterpart to bytes objects.

```python
In [51]: x = bytearray.fromhex("00ff")

In [52]: x [0]
Out[52]: 0


In [55]: x [0] = 16

In [56]: x
Out[56]: bytearray(b'\x10\xff')

```

# Bytearray and in conversion

`fromhex` is used to convert str to bytearray and `.hex()` for bytearray to str.
we still need to use `int` and `hex` for string and int convertion.

```
In [1]: x = 0x180000                                                                                                                  

In [2]: bytearray.fromhex(hex(x)[2:])                                                                                                 
Out[2]: bytearray(b'\x18\x00\x00')

In [3]: b = bytearray.fromhex(hex(x)[2:])                                                                                             

In [4]: for i in b: 
   ...:     print(i) 
   ...:                                                                                                                               
24
0
0

In [5]: b.hex()                                                                                                                       
Out[5]: '180000'

In [6]: int(b.hex(), base=16)                                                                                                         
Out[6]: 1572864
```
[1]: https://docs.python.org/3/library/stdtypes.html#binaryseq

