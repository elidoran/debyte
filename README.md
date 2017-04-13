# debyte
[![Build Status](https://travis-ci.org/elidoran/debyte.svg?branch=master)](https://travis-ci.org/elidoran/debyte)
[![Dependency Status](https://gemnasium.com/elidoran/debyte.png)](https://gemnasium.com/elidoran/debyte)
[![npm version](https://badge.fury.io/js/debyte.svg)](http://badge.fury.io/js/debyte)
[![Coverage Status](https://coveralls.io/repos/github/elidoran/debyte/badge.svg?branch=master)](https://coveralls.io/github/elidoran/debyte?branch=master)

Decode enbyte encoded objects, arrays, strings.

See packages:

1. [endeo](https://www.npmjs.com/package/endeo)
2. [enbyte](https://www.npmjs.com/package/enbyte)
3. [debytes](https://www.npmjs.com/package/debytes)
4. [destring](https://www.npmjs.com/package/destring)

NOTE: placeholder

## Install

```sh
npm install debyte --save
```


## Usage


```javascript
    // get the builder
var buildDebyte = require('debyte')

  // build one
  , debyte = buildDebyte({
    // delimiter between array elements and,
    // end of child object in a parent object
    delim: 0xFF // default delim
  })

buffer = someBuffer()
buffer[0] = 0xF0 // special byte meaning a 4 byte int
buffer.writeInt32BE(123456789)

// decode returns a single decoded thing.
// this looks at bytes starting at index.
// if it can determine what it is and read it,
// then it'll return that value.
// if it doesn't know, it'll return null
num = debyte.decode(buffer, 0)
// the above `num` is now = 123456789
// NOTE: by default it uses all "big endian" (BE) functions

input = 'some string to encode'
byteLength = Buffer.byteLength(string, 'utf8')
buffer.writeInt32BE(byteLength, 0)
buffer.write(string, 0, 'utf8')
string = debyte.decode(buffer, 0)
// string === input

// example with enbyte
buffer = enbyte.string(input)
string = debyte.decode(buffer, 0)
// string === input
```


# [MIT License](LICENSE)
