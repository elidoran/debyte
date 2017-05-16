# debyte
[![Build Status](https://travis-ci.org/elidoran/debyte.svg?branch=master)](https://travis-ci.org/elidoran/debyte)
[![Dependency Status](https://gemnasium.com/elidoran/debyte.png)](https://gemnasium.com/elidoran/debyte)
[![npm version](https://badge.fury.io/js/debyte.svg)](http://badge.fury.io/js/debyte)
[![Coverage Status](https://coveralls.io/repos/github/elidoran/debyte/badge.svg?branch=master)](https://coveralls.io/github/elidoran/debyte?branch=master)

Decode endeo enbyte encoded objects, arrays, strings.

See packages:

1. [endeo](https://www.npmjs.com/package/endeo)
2. [enbyte](https://www.npmjs.com/package/enbyte)
3. [@endeo/bytes](https://www.npmjs.com/package/@endeo/bytes)
4. [@endeo/input](https://www.npmjs.com/package/@endeo/input)
5. [unstring](https://www.npmjs.com/package/unstring)
6. [@endeo/specials](https://www.npmjs.com/package/@endeo/specials)


## Install

```sh
# using the default bytes and input:
npm install --save debyte @endeo/bytes @endeo/input

# using debyte with custom bytes/input
npm install --save debyte
```


## Usage: With Endeo

When using debyte with [endeo](https://www.npmjs.com/package/endeo) it provides the [custom options](#usage-custom) and manages the debyte instance.

So, you only need to learn what's below to customize a debyte or use it directly.


## Usage: Direct

Shows **direct use** of debyte. For using debyte in endeo see the [endeo package](https://www.npmjs.com/package/endeo)

```javascript
// get the builder
var buildDebyte = require('debyte')

// build one
var debyte = buildDebyte()

// get a buffer somehow
var buffer = someEncodedContent()

// wrap an input helper around our buffer
var input = debyte.input(buffer, 0)

// decode returns a single decoded thing.
// this looks at bytes starting at its index.
// if it can determine what it is and read it,
// then it'll return that value.
// if it doesn't know, it'll return
// an object with an `error` message property.
result = debyte.decode(input)

if (result.error) {
  // then there was an error decoding the buffer
} else {
  // otherwise `result` *is* the decoded value.
}

// Example with enbyte:
output = enbyte.output()
enbyte.string('first string', output)
enbyte.string('second string', output)
buffer = output.complete()

input = debyte.input(buffer, 0)
string1 = debyte.string(input)
string2 = debyte.string(input)
```


## Usage: Custom

Debyte allows customizing its internals so you can alter byte markers and how it performs tasks such as string replacements and "object spec" retrieval.

By default a debyte instance will:

1. use `@endeo/bytes` for its byte markers
2. use unsupportive functions in place of an `unstring` instance which will return an error when asked to learn a new unstring string.
3. use unsupportive function in place of an `@endeo/specials` `Specials` instance which will return an error when asked to retrieve an "object spec".

If you're fine with the default bytes and won't be using `unstring` or special objects then you are all set.

Otherwise, you must provide them via options:


```javascript
var buildDebyte = require('debyte')

// an example of building one with full support
var debyte = buildDebyte({

  // the default bytes are in their own package.
  // you could specify your own object.
  bytes: require('@endeo/bytes'),

  // a default `unstring` instance.
  // you could specify a custom `unstring` instance
  // or an unstring-like object with functions:
  //  restring(id)
  //  learn(id, string)
  // this will learn all the strings it encounters,
  // probably not the best configuration...
  unstring: require('unstring')()

  // a default empty `specials`.
  // you could specify your own custom `Specials`
  // or a specials-like object with function:
  //  get(id)
  specials: require('@endeo/specials')()
})
```


## [MIT License](LICENSE)
