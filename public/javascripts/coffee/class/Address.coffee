class Address
  @block_distance: 10

  @compare: (first, second) ->
    return false unless first.is_valid() && second.is_valid()

    matched = first.street == second.street && first.block == second.block

  @distance_between: (first, second) ->
    return 0 unless first.is_valid() && second.is_valid()

    distance = Math.abs(first.street - second.street) + Math.abs(first.block - second.block) * Address.block_distance

  constructor: (street=null, block=null) ->
    @street = street
    @block = block

  is_valid: ->
    !!(@street && @block)
