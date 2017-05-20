# used for decoding ints larger than 6 bytes
POW48 = Math.pow 2, 48
NEG_POW48 = -POW48

# used for ints which are "shifted" to eliminate overlap from lower ones
# and allow for greater values.
shift = Object.create null,
  b1: configurable: false, writable: false, enumerable: true, value: 101
  b2: configurable: false, writable: false, enumerable: true, value: 357
  b3: configurable: false, writable: false, enumerable: true, value: 65893
  b4: configurable: false, writable: false, enumerable: true, value: 16843109
  b5: configurable: false, writable: false, enumerable: true, value: 4311810405
  b6: configurable: false, writable: false, enumerable: true, value: 1103823438181
  # b7: configurable: false, writable: false, enumerable: true, value: 282578800148837


class Debyte

  constructor: (options) ->

    # use specified `bytes` or try the standard package
    @B = options?.bytes ? require '@endeo/bytes'

    # unstring
    # endeo, or whatever constructs this Debyte should provide an unstring
    # to restring an unstring ID and learn a new string only *if*
    # they are actually using those (expecting them in encoded input).
    @unstring = options?.unstring ?
      # use default functions which don't support it
      restring: -> null
      learn   : -> error: 'unstring.learn() unavailable'

    # specials
    # endeo, or whatever constructs this Debyte should provide a way
    # to retrieve an "object spec" based on the ID only *if*
    # they are actually using those (expecting them in the encoded input).
    # for now, that's an array so the index is the ID.
    @specs = options?.specs ? []

    # input
    # use specified input builder or try the standard implementation
    @Input = options?.input ? require '@endeo/input'


  input: (buffer, index) -> @Input buffer, index


  generic: (input) ->
    if input.byte() is @B.OBJECT then @_generic input
    else error: 'invalid specifier'


  special: (input) ->
    id = input.byte()
    if id < @B.SPECIAL then @_special id, input
    else if id is @B.SPECIAL then @_special @int(input), input
    else error: 'invalid specifier'


  array: (input) ->
    if input.byte() is @B.ARRAY then @_array input
    else error: 'invalid specifier'


  # top-level sync-style from-input entry-point.
  # aware of first-byte special "indicator" style.
  # only looks for the top-level stuff: Og Os Ox A S
  decode: (input) ->

    byte = input.byte()

    if byte < @B.SPECIAL then return @_special byte, input

    switch byte

      when @B.OBJECT then @_generic input

      when @B.ARRAY then @_array input

      when @B.STRING then @_string input

      # in case they didn't encode with "indicator" byte variation
      when @B.SPECIAL then  @_special @int(input), input

      else error: 'invalid indicator'


  # top-level sync-style from-input re-entry-point.
  # unaware of first-byte "indicator" style.
  # looks for all types based on "specifier" style.
  value: (input) ->

    byte = input.byte()

    if byte <= @B.MAX_POS then return byte
    else if byte <= @B.MAX_NEG then return -1 * (byte - @B.MAX_POS)

    switch byte

      when @B.SPECIAL then  @_special @int(input), input

      when @B.OBJECT  then @_generic input

      when @B.ARRAY   then @_array input

      when @B.STRING  then @_string input

      when @B.TRUE  then true

      when @B.FALSE then false

      when @B.NULL  then null

      when @B.EMPTY_OBJECT then {}

      when @B.EMPTY_ARRAY  then []

      when @B.EMPTY_STRING then ''

      when @B.P1 then       input.byte() + shift.b1
      when @B.N1 then -1 * (input.byte() + shift.b1)

      when @B.P2 then       input.short() + shift.b2
      when @B.N2 then -1 * (input.short() + shift.b2)

      when @B.P3 then       input.int(3) + shift.b3
      when @B.N3 then -1 * (input.int(3) + shift.b3)

      when @B.P4 then       input.int(4) + shift.b4
      when @B.N4 then -1 * (input.int(4) + shift.b4)

      when @B.P5 then       input.int(5) + shift.b5
      when @B.N5 then -1 * (input.int(5) + shift.b5)

      when @B.P6 then       input.int(6) + shift.b6
      when @B.N6 then -1 * (input.int(6) + shift.b6)

      when @B.P7 then input.byte() * POW48 + input.int(6)
      when @B.N7 then input.byte() * NEG_POW48 - input.int(6)

      when @B.P8 then input.short() * POW48 + input.int(6)
      when @B.N8 then input.short() * NEG_POW48 - input.int(6)

      when @B.FLOAT4 then input.float4()

      when @B.FLOAT8 then input.float8()

      when @B.BYTES then input.bytes @int input

      else error: 'invalid specifier'


  # expects the first-byte (B.OBJECT) to be read already
  _generic: (input) ->

    object = {}

    # NOTE: stops for both SUB_TERMINATOR and TERMINATOR
    while input.peek() < @B.SUB_TERMINATOR
      key         = @string input
      value       = @value input
      object[key] = value

    # consume the terminator byte which stopped the loop
    input.eat()

    return object


  _special: (id, input) ->

    # due to JS mode below i'm defining the variables in JS mode
    `var array, i, end, keyInfo, n, value`

    # get the "object spec" for the `id`
    spec = @specs[id]

    unless spec? then return error: 'unknown special ID', id: id

    # create an object with all the default keys/values for us to fill.
    object = spec.creator()

    # use spec's key info to decode each value and set into object.
    # need to control the loop index var to skip over groups of defaults.
    # CoffeeScript protects the loop index var, so, switching to JS mode:
    ```
    // iterate over each index in spec's key info array
    for (array = spec.array, i = 0, end = spec.array.length; i < end; /* managed below */ ) {

      keyInfo = array[i]

      switch (input.peek()) {

        // skip it and leave the default value.
        case this.B.DEFAULT : i += 1 ; break

        // skip ahead 5 values and leave the 5 defaults.
        case this.B.DEFAULT5: i += 5 ; break

        // skip ahead `n` values by reading `n`
        case this.B.DEFAULTN:
          this.eat()
          n = this.int(input)
          i += n
          break

        // read the actual value
        default:

          // read it via the custom decode() or value()
          value = keyInfo.decode ? keyInfo.decode(this, input)
                                 : this.value(input)
          // return error object
          if (value.error) return value

          // set value into object and increment index
          object[keyInfo.key] = value
          i++
      }
    }
    ```

    # all done so return the object.
    return object


  _array: (input) ->

    array = []

    array[array.length] = @value input while input.peek() < @B.SUB_TERMINATOR

    # consume the terminator byte which stopped the loop
    input.eat()

    return array # TODO: wrap in a result object?


  # potential use cases:
  #
  #  1. debyte direct use starts with the "specifier" byte
  #    B.STRING, int (length), string (bytes)
  #    B.GET_STRING, int (id)
  #    B.NEW_STRING, int (id), int (length), string (bytes)
  #    B.EMPTY_STRING
  #
  #  2. always starts with a B.STRING:
  #    B.STRING, B.GET_STRING, int (id)
  #    B.STRING, B.NEW_STRING, int (id), int (length), string (bytes)
  #    B.STRING, int (length), string (bytes)
  #    B.STRING, B.EMPTY_STRING
  #    B.STRING, B.TERMINATOR
  #
  # this consumes B.STRING before calling _string()
  # for direct call like debyte.string(input)
  # and for _generic() to get a string for a key
  string: (input) ->

    if input.peek() is @B.STRING then input.eat()
    @_string input


  # called directly by both decode() and value().
  # expects the B.STRING to be consumed so:
  #   B.GET_STRING, int (id)
  #   B.NEW_STRING, int (id), int (length), string (bytes)
  #   int (length), string (bytes)
  _string: (input) ->

    byte = input.byte()

    switch byte

      # get the string based on the encoded ID
      when @B.GET_STRING then @unstring.restring @int input

      # get the string and its ID and learn it
      when @B.NEW_STRING
        id = @int input
        length = @int input
        string = input.string length
        @unstring.learn id, string, length
        return string

      # if a top-level string is sent with no content it'll
      # have a TERMINATOR immediately after STRING
      # which means it's an empty string.
      # inner empty strings will be B.EMPTY_STRING, see value().
      when @B.TERMINATOR then ''
      when @B.EMPTY_STRING then ''

      else # it should have started with B.STRING

        # it should be the length header before the string's bytes.

        # if byte is a tiny int then that's the length header.
        if 0 <= byte <= @B.MAX_POS then input.string byte

        # if byte is a marker for a positive int then read it as length.
        else if @B.P1 <= byte <= @B.P8 then input.string @int input.back()

        else error: 'invalid specifier'



  # reads an int value from the input.
  # NOTE: same logic is used directly in value() as part of its switch
  #       to avoid calling this function to do another switch here.
  int: (input) ->

    byte = input.byte()

    if byte <= @B.MAX_POS then return byte
    else if byte <= @B.MAX_NEG then return -1 * (byte - @B.MAX_POS)

    switch byte

      when @B.P1 then       input.byte() + shift.b1
      when @B.N1 then -1 * (input.byte() + shift.b1)

      when @B.P2 then       input.short() + shift.b2
      when @B.N2 then -1 * (input.short() + shift.b2)

      when @B.P3 then       input.int(3) + shift.b3
      when @B.N3 then -1 * (input.int(3) + shift.b3)

      when @B.P4 then       input.int(4) + shift.b4
      when @B.N4 then -1 * (input.int(4) + shift.b4)

      when @B.P5 then       input.int(5) + shift.b5
      when @B.N5 then -1 * (input.int(5) + shift.b5)

      when @B.P6 then       input.int(6) + shift.b6
      when @B.N6 then -1 * (input.int(6) + shift.b6)

      # bytes above 6 must be retrieved separately
      # and scaled by multiplying by 2^48 (six bytes).
      # using a negative one to flip the sign for negative values.
      when @B.P7 then input.byte() * POW48 + input.int(6)
      when @B.N7 then input.byte() * NEG_POW48 - input.int(6)
      when @B.P8 then input.short() * POW48 + input.int(6)
      when @B.N8 then input.short() * NEG_POW48 - input.int(6)



# builder enforces required options by returning an object with error message.
module.exports = (options) -> new Debyte options
module.exports.Debyte = Debyte
