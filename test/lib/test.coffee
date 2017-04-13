assert = require 'assert'

buildDebyte = require '../../lib/index.coffee'

describe 'test debyte', ->

  it 'should build', -> assert buildDebyte()

  it 'should decode an object'
  it 'should decode an array'
  it 'should decode a string'
  it 'should decode a nested object'
