assert = require 'assert'

B = require '@endeo/bytes'
Input = require '@endeo/input'
buildDebyte = require '../../lib/index.coffee'

debyte = -> buildDebyte bytes:B

bytes4 = (marker, float) ->
  buffer = Buffer.alloc 5
  buffer[0] = marker
  buffer.writeFloatBE float, 1, true
  buffer

bytes8 = (marker, float) ->
  buffer = Buffer.alloc 9
  buffer[0] = marker
  buffer.writeDoubleBE float, 1, true
  buffer

tests = [

  [  '0.0',  0.0, bytes4 B.FLOAT4,    0 ]
  [ '-0.0', -0.0, bytes4 B.FLOAT4, -0.0 ]
  [  '1.0',  1.0, bytes4 B.FLOAT4,  1.0 ]
  [ '-1.0', -1.0, bytes4 B.FLOAT4, -1.0 ]

  [  '1.25',  1.25, bytes4 B.FLOAT4,  1.25 ]
  [ '-1.25', -1.25, bytes4 B.FLOAT4, -1.25 ]

  [  '123.456',  123.456, bytes8 B.FLOAT8,  123.456 ]
  [ '-123.456', -123.456, bytes8 B.FLOAT8, -123.456 ]

]

describe 'test debyte floats', ->

  for test in tests

    do (test) -> it 'should decode ' + test[0], ->

      result = debyte().value Input buffer: test[2]
      assert.equal result, test[1]
