assert = require 'assert'

B = require '@endeo/bytes'
Input = require '@endeo/input'
buildDebyte = require '../../lib/index.coffee'

debyte = -> buildDebyte bytes:B

bytes = ->
  args = new Array arguments.length
  args[i] = arguments[i] for i in [0 ... arguments.length]
  Buffer.from args

tests = [

  [ 0, bytes 0 ]

  [  1, bytes 1 ]
  [ -1, bytes 101 ]

  [  100, bytes 100 ]
  [ -100, bytes 200 ]

  [  101, bytes B.P1, 0 ]
  [ -101, bytes B.N1, 0 ]

  [  356, bytes B.P1, 255 ]
  [ -356, bytes B.N1, 255 ]

  [  357, bytes B.P2, 0, 0 ]
  [ -357, bytes B.N2, 0, 0 ]

  [  65892, bytes B.P2, 255, 255 ]
  [ -65892, bytes B.N2, 255, 255 ]

  [  65893, bytes B.P3, 0, 0, 0 ]
  [ -65893, bytes B.N3, 0, 0, 0 ]

  [  16843108, bytes B.P3, 255, 255, 255 ]
  [ -16843108, bytes B.N3, 255, 255, 255 ]

  [  16843109, bytes B.P4, 0, 0, 0, 0 ]
  [ -16843109, bytes B.N4, 0, 0, 0, 0 ]

  [  4311810404, bytes B.P4, 255, 255, 255, 255 ]
  [ -4311810404, bytes B.N4, 255, 255, 255, 255 ]

  [  4311810405, bytes B.P5, 0, 0, 0, 0, 0 ]
  [ -4311810405, bytes B.N5, 0, 0, 0, 0, 0 ]

  [  1103823438180, bytes B.P5, 255, 255, 255, 255, 255 ]
  [ -1103823438180, bytes B.N5, 255, 255, 255, 255, 255 ]

  [  1103823438181, bytes B.P6, 0, 0, 0, 0, 0, 0 ]
  [ -1103823438181, bytes B.N6, 0, 0, 0, 0, 0, 0 ]

  [  282578800148836, bytes B.P6, 255, 255, 255, 255, 255, 255 ]
  [ -282578800148836, bytes B.N6, 255, 255, 255, 255, 255, 255 ]

  # 7 byte numbers aren't shifted to allow for more values in the range
  # because ECMAScript only supports up to 53 bits.
  [  282578800148837, bytes B.P7, 1, 1, 1, 1, 1, 1, 0x65 ]
  [ -282578800148837, bytes B.N7, 1, 1, 1, 1, 1, 1, 0x65 ]

  [  9007199254740992, bytes B.P7, 0x20, 0, 0, 0, 0, 0, 0 ]
  [ -9007199254740992, bytes B.N7, 0x20, 0, 0, 0, 0, 0, 0 ]

  [  9007199254740992, bytes B.P8, 0, 0x20, 0, 0, 0, 0, 0, 0 ]
  [ -9007199254740992, bytes B.N8, 0, 0x20, 0, 0, 0, 0, 0, 0 ]

]

describe 'test debyte ints', ->

  for test in tests

    do (test) ->

      it 'should decode ' + test[0] + ' via int', ->

        result = debyte().int Input test[1], 0
        assert.equal result, test[0]

      it 'should decode ' + test[0] + ' via value', ->

        result = debyte().value Input test[1], 0
        assert.equal result, test[0]
