class Time
  constructor: ->

  @now: ->
    (new Date()).getTime()

  @in_millis: (amount, of_what) ->
    conversions = 
      seconds: 1000
      minutes: 60000
      hours: 60000*60
      days: 60000*60*24

    #alias'
    conversions.s = conversions.seconds
    conversions.m = conversions.minutes
    conversions.h = conversions.hours
    conversions.d = conversions.days

    return amount unless _.has conversions, of_what

    conversions[of_what] * amount
