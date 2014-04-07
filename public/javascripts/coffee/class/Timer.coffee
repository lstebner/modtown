class Timer
    constructor: (@duration=0, @on_complete=null, @on_tick=null)->
        @ticks = 0
        @timeout = null

    on: (what, fn) ->
        switch what
            when 'on_tick' then @on_tick = fn
            when 'complete' then @on_complete = fn

    tick: (repeat=false, tick_every=1000)->
        return if @complete()

        @on_tick?(@ticks)

        if repeat
            clearTimeout(@timeout) if @timeout

            @timeout = setTimeout =>
                @tick(true, tick_every)
            , tick_every

        @update()

    update: ->
        @ticks += 1

        @finish() if @ticks > @duration

    remaining: ->
        @duration - @ticks

    remaining_percent: ->
        @ticks / @duration

    complete: ->
        @ticks > @duration

    finish: ->
        @on_complete?()

    reset: (begin_ticking=false) ->
        @ticks = 0

        @tick() if begin_ticking

World.Timer = Timer
