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


  it 'decode() should error for invalid indicator byte', ->

    result = debyte().decode Input Buffer.from([]), 0
    assert result?.error


  it 'generic() should error for invalid indicator byte', ->

    result = debyte().generic Input Buffer.from([ B.STRING ]), 0
    assert result?.error


  it 'special() should error for invalid indicator byte', ->

    result = debyte().special Input Buffer.from([ B.ARRAY ]), 0
    assert result?.error


  it 'array() should error for invalid indicator byte', ->

    result = debyte().array Input Buffer.from([ B.STRING ]), 0
    assert result?.error


  it 'string() should error for invalid indicator byte', ->

    result = debyte().string Input Buffer.from([ B.ARRAY ]), 0
    assert result?.error


  it 'value() should error for invalid specifier byte', ->

    result = debyte().value Input Buffer.from([ 0xDB ])
    assert result?.error


  it '_special() should error for invalid special id', ->

    result = debyte()._special()
    assert result?.error


  it 'should build an Input by default', ->

    input = debyte().input(Buffer.alloc(2), 1)
    assert input.buffer
    assert.equal input.buffer.length, 2
    assert.equal input.index, 1


  it 'should build an Input via custom builder', ->

    $debyte = buildDebyte input: (buffer, index, options) ->
      custom:true, buffer:buffer, index:index

    buffer = Buffer.alloc 2

    input = $debyte.input buffer, 1

    assert input.custom
    assert.strictEqual input.buffer, buffer
    assert.equal input.buffer.length, buffer.length
    assert.equal input.index, 1


  it 'should decode empty object via decode() (top-level)', ->

    result = debyte().decode Input Buffer.from([ B.OBJECT, B.TERMINATOR ]), 0
    assert.deepEqual result, {}


  it 'should decode empty object via generic() (top-level)', ->

    result = debyte().generic Input Buffer.from([ B.OBJECT, B.TERMINATOR ]), 0
    assert.deepEqual result, {}


  it 'should decode empty object via value()', ->

    result = debyte().value Input Buffer.from([ B.EMPTY_OBJECT ]), 0
    assert.deepEqual result, {}


  it 'should decode empty array via decode() (top level)', ->

    result = debyte().decode Input Buffer.from([ B.ARRAY, B.TERMINATOR ]), 0
    assert.deepEqual result, []


  it 'should decode empty array via array() (top level)', ->

    result = debyte().array Input Buffer.from([ B.ARRAY, B.TERMINATOR ]), 0
    assert.deepEqual result, []


  it 'should decode empty array via value()', ->

    result = debyte().value Input Buffer.from([ B.EMPTY_ARRAY ]), 0
    assert.deepEqual result, []


  it 'should empty string via decode() (top level)', ->

    result = debyte().decode Input Buffer.from([ B.STRING, B.TERMINATOR ]), 0
    assert.strictEqual result, ''


  it 'should decode empty string via string() (top level)', ->

    result = debyte().string Input Buffer.from([ B.STRING, B.TERMINATOR ]), 0
    assert.strictEqual result, ''


  it 'should decode empty string via string()', ->

    result = debyte().string Input Buffer.from([ B.EMPTY_STRING ]), 0
    assert.strictEqual result, ''


  it 'should decode empty string via value()', ->

    result = debyte().value Input Buffer.from([ B.EMPTY_STRING ]), 0
    assert.strictEqual result, ''


  it 'should decode null via value()', ->

    result = debyte().value Input Buffer.from([ B.NULL ]), 0
    assert.strictEqual result, null


  it 'should decode true via value()', ->

    result = debyte().value Input Buffer.from([ B.TRUE ]), 0
    assert.strictEqual result, true


  it 'should decode false via value()', ->

    result = debyte().value Input Buffer.from([ B.FALSE ]), 0
    assert.strictEqual result, false


  it 'should decode binary via value()', ->

    result = debyte().value Input Buffer.from([ B.BYTES, 5, 1, 2, 3, 4, 5 ]), 0
    assert.deepEqual result, Buffer.from [ 1, 2, 3, 4, 5 ]


  it 'should decode a generic object via decode()', ->

    result = debyte().decode Input Buffer.from([
      B.OBJECT, B.STRING, 1, 97, 101, B.TERMINATOR
    ]), 0
    assert.deepEqual result, { a: -1 }


  it 'should decode a generic object via decode() (multi-level)', ->

    result = debyte().decode Input Buffer.from([
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
    ]), 0
    assert.deepEqual result, { a: 1, b: { two: 2 }, c: [ 333, 3333, 333333 ], d: { four: 4, e: { f: 5 } }, g: 6 }


  it 'should decode an array via decode()', ->

    result = debyte().decode Input Buffer.from([
      B.ARRAY, B.STRING, 1, 97, 1, 100, B.TERMINATOR
    ]), 0
    assert.deepEqual result, [ 'a', 1, 100 ]


  it 'should decode a string via decode() (top-level)', ->

    result = debyte().decode Input Buffer.from([
      B.STRING, 5, 97, 98, 99, 100, 101, B.TERMINATOR
    ]), 0
    assert.equal result, 'abcde'

  it 'should decode known string via decode() (top-level)', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'abcde'

    result = $debyte.decode Input Buffer.from([
      B.STRING, B.GET_STRING, 1, B.TERMINATOR
    ]), 0
    assert.equal result, 'abcde'

  it 'should decode new string via decode() (top-level)', ->

    calledId = calledString = calledLength = null
    $debyte = buildDebyte unstring: learn: (id, string, length) ->
      calledId = id
      calledString = string
      calledLength = length

    result = $debyte.decode Input Buffer.from([
      B.STRING, B.NEW_STRING, 1, 5, 97, 98, 99, 100, 101, B.TERMINATOR
    ]), 0
    assert.equal result, 'abcde'
    assert.equal calledId, 1
    assert.equal calledString, 'abcde'
    assert.equal calledLength, 5


  it 'should decode a string via value()', ->

    result = debyte().value Input Buffer.from([
      B.STRING, 5, 97, 98, 99, 100, 101
    ]), 0
    assert.equal result, 'abcde'

  it 'should decode known string via value()', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'abcde'

    result = $debyte.value Input Buffer.from([
      B.GET_STRING, 1
    ]), 0
    assert.equal result, 'abcde'

  it 'should decode new string via value()', ->

    calledId = calledString = calledLength = null
    $debyte = buildDebyte unstring: learn: (id, string, length) ->
      calledId = id
      calledString = string
      calledLength = length

    result = $debyte.value Input Buffer.from([
      B.NEW_STRING, 1, 5, 97, 98, 99, 100, 101
    ]), 0
    assert.equal result, 'abcde'
    assert.equal calledId, 1
    assert.equal calledString, 'abcde'
    assert.equal calledLength, 5


  it 'should decode known string via value() (prefixed)', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'abcde'

    result = $debyte.value Input Buffer.from([
      B.STRING, B.GET_STRING, 1
    ]), 0
    assert.equal result, 'abcde'

  it 'should decode new string via value() (prefixed)', ->

    calledId = calledString = calledLength = null
    $debyte = buildDebyte unstring: learn: (id, string, length) ->
      calledId = id
      calledString = string
      calledLength = length

    result = $debyte.value Input Buffer.from([
      B.STRING, B.NEW_STRING, 1, 5, 97, 98, 99, 100, 101
    ]), 0
    assert.equal result, 'abcde'
    assert.equal calledId, 1
    assert.equal calledString, 'abcde'
    assert.equal calledLength, 5


  it 'should decode a long string via decode()', ->

    inputString = '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'

    result = debyte().decode Input Buffer.concat([
      Buffer.from [
        # string with length 101
        B.STRING, B.P1, 0
      ]
      Buffer.from inputString
    ]), 0
    assert.equal result, inputString

  [ 'special', 'decode' ].forEach (method) ->

    # TODO: add more which use B.DEFAULT bytes

    it 'should decode a special object via ' + method, ->

      calledId = null
      spec =
        creator: -> a:null
        array: [
          { key: 'a', default: 1 }
        ]

      $debyte = buildDebyte specs: [null, spec]
      result = $debyte[method] Input Buffer.from([
        # spec id is 1, key isn't there for specials, then value is 1
        1, 2, B.TERMINATOR
      ]), 0

      assert.deepEqual result, { a: 2 }


    it 'should decode a special object without shortened indicator via ' + method, ->

      calledId = null
      spec =
        creator: -> a:null
        array: [
          { key: 'a', default: 1 }
        ]
      $debyte = buildDebyte specs: [null, spec]
      result = $debyte[method] Input Buffer.from([
        # spec id is 1, key isn't there for specials, then value is 1
        B.SPECIAL, 1, 2, B.TERMINATOR
      ]), 0

      assert.deepEqual result, { a: 2 }


    it 'should decode a special object with longer id via ' + method, ->

      calledId = null
      spec =
        creator: -> a:null
        array: [
          { key: 'a', default: 1 }
        ]
      specsArray = []
      specsArray[101] = spec
      $debyte = buildDebyte specs: specsArray
      result = $debyte[method] Input Buffer.from([
        # spec id is extended 0=101, key isn't there for specials, then value is 1
        B.SPECIAL, B.P1, 0, 2, B.TERMINATOR
      ]), 0

      assert.deepEqual result, { a: 2 }


    it 'should decode a special object with an internal special object via ' + method, ->

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

      $debyte = buildDebyte specs: [null, spec1, spec2]

      result = $debyte[method] Input Buffer.from([
        # spec1 id is 1, key isn't there for specials
        1
        # then value for key 'a' is 1
        2
        # value for key 'b' is another special object
        # spec2 id is 2, no key
        B.SPECIAL, 2
        # value for key 'c' is 3
        3
        # then special object 2 is done
        # then the outer object is done too
        B.TERMINATOR
      ]), 0

      assert.deepEqual result, { a: 2, b: { c: 3 } }


  it 'should decode a generic object with an internal special object', ->

    spec1 =
      creator: -> c:null
      array: [
        { key: 'c', default: null }
      ]

    $debyte = buildDebyte specs: [null, spec1]

    result = $debyte.decode Input Buffer.from([
      B.OBJECT
      # a:1
      B.STRING, 1, 97, 1
      # b: { c: 3 }
      B.STRING, 1, 98
      B.SPECIAL, 1, 3
      # B.SUB_TERMINATOR
      # then the outer object is done too
      B.TERMINATOR
    ]), 0

    assert.deepEqual result, { a: 1, b: { c: 3 } }


  it 'should restring an unstring string via decode() (prefixed)', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'test'

    result = $debyte.decode Input Buffer.from([
      B.OBJECT
      B.STRING, B.GET_STRING, 1
      4
      B.TERMINATOR
    ]), 0

    assert.deepEqual result, { test: 4 }


  it 'should restring an unstring string', ->

    $debyte = buildDebyte unstring: restring: (id) -> if id is 1 then 'test'

    result = $debyte.decode Input Buffer.from([
      B.OBJECT
      B.GET_STRING, 1
      4
      B.TERMINATOR
    ]), 0

    assert.deepEqual result, { test: 4 }


  it 'should learn an unstring string (prefixed)', ->

    calledId = calledString = calledLength = null

    $debyte = buildDebyte unstring: learn: (id, string, length) ->
      calledId = id
      calledString = string
      calledLength = length

    result = $debyte.decode Input Buffer.from([
      B.OBJECT
      B.STRING, B.NEW_STRING, 1, 3, 97, 98, 99
      3
      B.TERMINATOR
    ]), 0

    assert.equal calledId, 1
    assert.equal calledString, 'abc'
    assert.equal calledLength, 3
    assert.deepEqual result, { abc: 3 }


  it 'should learn an unstring string', ->

    calledId = calledString = calledLength = null

    $debyte = buildDebyte unstring: learn: (id, string, length) ->
      calledId = id
      calledString = string
      calledLength = length

    result = $debyte.decode Input Buffer.from([
      B.OBJECT
      B.NEW_STRING, 1, 3, 97, 98, 99
      3
      B.TERMINATOR
    ]), 0

    assert.equal calledId, 1
    assert.equal calledString, 'abc'
    assert.equal calledLength, 3
    assert.deepEqual result, { abc: 3 }
