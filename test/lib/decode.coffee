assert = require 'assert'
B = require '@endeo/bytes'

Input = require '@endeo/input'
buildDebyte = require '../../lib/index.coffee'

debyte = -> buildDebyte
  specials: get: (id) ->
  unstring:
    restring: (id) ->
    learn: (id, string) ->


describe 'test debyte', ->

  it 'should build', -> assert debyte()


  it 'should build without support for extras', ->

    $debyte = buildDebyte()
    assert.equal $debyte.unstring.restring(1), null
    assert.equal $debyte.unstring.learn(1, 'test')?.error, 'unstring.learn() unavailable'
    assert.equal $debyte.specials.get(1)?.error, 'specials.get() unavailable'


  it 'should error for invalid indicator byte', ->

    result = debyte().decode Input buffer: Buffer.from []
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().generic Input buffer: Buffer.from [ B.STRING ]
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().special Input buffer: Buffer.from [ B.ARRAY ]
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().array Input buffer: Buffer.from [ B.STRING ]
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().string Input buffer: Buffer.from [ B.ARRAY ]
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().string Input buffer: Buffer.from [ B.ARRAY ]
    assert result?.error


  it 'should error for invalid indicator byte', ->

    result = debyte().value Input buffer: Buffer.from [ 0xDB ]
    assert result?.error


  it 'should error for invalid special id', ->

    result = debyte()._special()
    assert result?.error


  it 'should build an Input by default', ->

    input = debyte().input(Buffer.alloc(2), 1)
    assert input.buffer
    assert.equal input.buffer.length, 2
    assert.equal input.index, 1


  it 'should build an Input via custom builder', ->

    $debyte = buildDebyte input: (options) ->
      custom:true, buffer:options.buffer, index:options.index

    buffer = Buffer.alloc 2

    input = $debyte.input buffer, 1

    assert input.custom
    assert.strictEqual input.buffer, buffer
    assert.equal input.buffer.length, buffer.length
    assert.equal input.index, 1


  it 'should decode() empty object (top level)', ->

    result = debyte().decode Input buffer: Buffer.from [ B.OBJECT, B.TERMINATOR ]
    assert.deepEqual result, {}


  it 'should generic() decode empty object (top level)', ->

    result = debyte().generic Input buffer: Buffer.from [ B.OBJECT, B.TERMINATOR ]
    assert.deepEqual result, {}


  it 'should value() decode empty object value', ->

    result = debyte().value Input buffer: Buffer.from [ B.EMPTY_OBJECT ]
    assert.deepEqual result, {}


  it 'should decode() empty array (top level)', ->

    result = debyte().decode Input buffer: Buffer.from [ B.ARRAY, B.TERMINATOR ]
    assert.deepEqual result, []


  it 'should array() decode empty array (top level)', ->

    result = debyte().array Input buffer: Buffer.from [ B.ARRAY, B.TERMINATOR ]
    assert.deepEqual result, []


  it 'should value() decode empty array value', ->

    result = debyte().value Input buffer: Buffer.from [ B.EMPTY_ARRAY ]
    assert.deepEqual result, []


  it 'should decode() empty string (top level)', ->

    result = debyte().decode Input buffer: Buffer.from [ B.STRING, B.TERMINATOR ]
    assert.strictEqual result, ''


  it 'should string() decode empty string (top level)', ->

    result = debyte().string Input buffer: Buffer.from [ B.STRING, B.TERMINATOR ]
    assert.strictEqual result, ''


  it 'should string() decode empty string (direct)', ->

    result = debyte().string Input buffer: Buffer.from [ B.EMPTY_STRING ]
    assert.strictEqual result, ''


  it 'should value() decode empty string value', ->

    result = debyte().value Input buffer: Buffer.from [ B.EMPTY_STRING ]
    assert.strictEqual result, ''


  it 'should value() decode null value', ->

    result = debyte().value Input buffer: Buffer.from [ B.NULL ]
    assert.strictEqual result, null


  it 'should value() decode true value', ->

    result = debyte().value Input buffer: Buffer.from [ B.TRUE ]
    assert.strictEqual result, true


  it 'should value() decode false value', ->

    result = debyte().value Input buffer: Buffer.from [ B.FALSE ]
    assert.strictEqual result, false


  it 'should value() decode binary value', ->

    result = debyte().value Input buffer: Buffer.from [ B.BYTES, 5, 1, 2, 3, 4, 5 ]
    assert.deepEqual result, Buffer.from [ 1, 2, 3, 4, 5 ]


  it 'should decode a generic object', ->

    result = debyte().decode Input buffer: Buffer.from [
      B.OBJECT, B.STRING, 1, 97, 101, B.TERMINATOR
    ]
    assert.deepEqual result, { a: -1 }


  it 'should decode a generic object (multi-level)', ->

    result = debyte().decode Input buffer: Buffer.from [
      B.OBJECT

      # a: 1
      B.STRING, 1, 97, 1

      # b: { two: 2 }
      B.STRING, 1, 98, B.OBJECT, B.STRING, 3, 116, 119, 111, 2, B.SUB_TERMINATOR

      # c: 3
      B.STRING, 1, 99, B.ARRAY, B.P1, 232, B.P2, 11, 160, B.P3, 4, 20, 176, B.SUB_TERMINATOR

      # d: { ... }
      B.STRING, 1, 100, B.OBJECT
      # four: 4
      B.STRING, 4, 102, 111, 117, 114, 4
      # e: { ... }
      B.STRING, 1, 101, B.OBJECT
      # f: 5
      B.STRING, 1, 102, 5
      # end of e's object
      B.SUB_TERMINATOR
      # end of d's object
      B.SUB_TERMINATOR

      # g: 6
      B.STRING, 1, 103, 6

      # all done
      B.TERMINATOR
    ]
    assert.deepEqual result, { a: 1, b: { two: 2 }, c: [ 333, 3333, 333333 ], d: { four: 4, e: { f: 5 } }, g: 6 }


  it 'should decode an array', ->

    result = debyte().decode Input buffer: Buffer.from [
      B.ARRAY, B.STRING, 1, 97, 1, 100, B.TERMINATOR
    ]
    assert.deepEqual result, [ 'a', 1, 100 ]


  it 'should decode a string', ->

    result = debyte().decode Input buffer: Buffer.from [
      B.STRING, 5, 97, 98, 99, 100, 101
    ]
    assert.equal result, 'abcde'


  it 'should decode a long string', ->

    inputString = '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'

    result = debyte().decode Input buffer: Buffer.concat [
      Buffer.from [
        # string with length 101
        B.STRING, B.P1, 0
      ]
      Buffer.from inputString
    ]
    assert.equal result, inputString


  it 'should decode a special object', ->

    calledId = null
    spec =
      creator: -> a:null
      array: [
        { key: 'a', default: 1 }
      ]
    $debyte = buildDebyte specials: get: (id) -> calledId = id ; spec
    result = $debyte.decode Input buffer: Buffer.from [
      # spec id is 1, key isn't there for specials, then value is 1
      1, 1, B.TERMINATOR
    ]

    assert.equal calledId, 1
    assert.deepEqual result, { a: 1 }


  it 'should decode a special object without shortened indicator', ->

    calledId = null
    spec =
      creator: -> a:null
      array: [
        { key: 'a', default: 1 }
      ]
    $debyte = buildDebyte specials: get: (id) -> calledId = id ; spec
    result = $debyte.decode Input buffer: Buffer.from [
      # spec id is 1, key isn't there for specials, then value is 1
      B.SPECIAL, 1, 1, B.TERMINATOR
    ]

    assert.equal calledId, 1
    assert.deepEqual result, { a: 1 }


  it 'should decode a special object with longer id', ->

    calledId = null
    spec =
      creator: -> a:null
      array: [
        { key: 'a', default: 1 }
      ]
    $debyte = buildDebyte specials: get: (id) -> calledId = id ; spec
    result = $debyte.decode Input buffer: Buffer.from [
      # spec id is extended 0=101, key isn't there for specials, then value is 1
      B.SPECIAL, B.P1, 0, 1, B.TERMINATOR
    ]

    assert.equal calledId, 101
    assert.deepEqual result, { a: 1 }


  it 'should decode a special object via special()', ->

    calledId = null
    spec =
      creator: -> a:null
      array: [
        { key: 'a', default: 1 }
      ]
    $debyte = buildDebyte specials: get: (id) -> calledId = id ; spec
    result = $debyte.special Input buffer: Buffer.from [
      # spec id is 1, key isn't there for specials, then value is 1
      1, 1, B.TERMINATOR
    ]

    assert.equal calledId, 1
    assert.deepEqual result, { a: 1 }


  it 'should decode a special object via special() without shortened indicator', ->

    calledId = null
    spec =
      creator: -> a:null
      array: [
        { key: 'a', default: 1 }
      ]
    $debyte = buildDebyte specials: get: (id) -> calledId = id ; spec
    result = $debyte.special Input buffer: Buffer.from [
      # spec id is 1, key isn't there for specials, then value is 1
      B.SPECIAL, 1, 1, B.TERMINATOR
    ]

    assert.equal calledId, 1
    assert.deepEqual result, { a: 1 }


  it 'should decode a special object with an internal special object', ->

    spec1 =
      creator: -> a:null, b:null
      array: [
        { key: 'a', default: 1 }
        { key: 'b', default: null }
      ]

    spec2 =
      creator: -> c:null
      array: [
        { key: 'c', default: 1 }
      ]

    $debyte = buildDebyte specials: get: (id) ->
      if id is 1 then spec1 else if id is 2 then spec2

    result = $debyte.decode Input buffer: Buffer.from [
      # spec1 id is 1, key isn't there for specials
      1
      # then value for key 'a' is 1
      1
      # value for key 'b' is another special object
      # spec2 id is 2, no key
      B.SPECIAL, 2
      # value for key 'c' is 3
      3
      # then special object 2 is done
      # then the outer object is done too
      B.TERMINATOR
    ]

    assert.deepEqual result, { a: 1, b: { c: 3 } }


  it 'should decode a generic object with an internal special object', ->

    spec1 =
      creator: -> c:null
      array: [
        { key: 'c', default: null }
      ]

    $debyte = buildDebyte specials: get: (id) -> if id is 1 then spec1

    result = $debyte.decode Input buffer: Buffer.from [
      B.OBJECT
      # a:1
      B.STRING, 1, 97, 1
      # b: { c: 3 }
      B.STRING, 1, 98
      B.SPECIAL, 1, 3
      # B.SUB_TERMINATOR
      # then the outer object is done too
      B.TERMINATOR
    ]

    assert.deepEqual result, { a: 1, b: { c: 3 } }


  it 'should restring an unstring string', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'test'

    result = $debyte.decode Input buffer: Buffer.from [
      B.OBJECT
      B.STRING, B.GET_STRING, 1
      4
      B.TERMINATOR
    ]

    assert.deepEqual result, { test: 4 }


  it 'should learn an unstring string', ->

    calledId = calledString = null

    $debyte = buildDebyte unstring: learn: (id, string) ->
      calledId = id
      calledString = string

    result = $debyte.decode Input buffer: Buffer.from [
      B.OBJECT
      B.STRING, B.NEW_STRING, 1, 3, 97, 98, 99
      3
      B.TERMINATOR
    ]

    assert.equal calledId, 1
    assert.equal calledString, 'abc'
    assert.deepEqual result, { abc: 3 }
