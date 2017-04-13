class Debyte

  constructor: (options) ->

    @delim = options?.delim ? 0xFF

  decode: (buffer, start) ->


# export a function which creates an instance
module.exports = (options) -> new Debyte options

# export the class as a sub property on the function
module.exports.Debyte = Debyte
