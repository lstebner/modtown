class ModTownGame extends RenderedObject
    constructor: ->
        super

        @clock = new WorldClock()
        @clock.tick()

        @weather = new WeatherSystem()

        @state = new StateManager('init')
        @setup_player()
        @setup_hud()
        @setup_town()
        @setup_events()
        @setup_timeout()

        @update()
        @render()

    setup_player: ->
        @player = new Player()

        #set up player events
        #player.on ..., =>

    setup_town: ->
        town_opts = 
            name: 'AhhsumTown'
            balance: 1000

        @town = new Town @container.find('#town'), town_opts

    setup_hud: ->
        @hud = new HUD @container.find('#hud'), { town: @town }

        @hud.container.on 'btn_pressed', (e, action) =>
            $el = $("[data-action=#{action}]")

            switch action
                when 'add_street' then @town.create_street({ blocks: 1 })

                when 'pause'
                    $el.text('Resume').data('action', 'resume')
                    @pause()

                when 'resume'
                    $el.text('Pause').data('action', 'pause')
                    @resume()

    setup_timeout: ->
        @timeout = null
        #change to setInterval to make repeat forever
        @timeout = setInterval =>
            @update()
        , 60000 / 30

    pause: (resume_in=null) ->
        clearInterval(@timeout) if @timeout

        if resume_in
            setTimeout =>
                @resume()
            , resume_in

    resume: ->
        @setup_timeout()

    update: ->
        @state.update()

        @weather.update(@clock)

        @town.update(@clock, @weather)
        @hud.update 
            town: @town
            player: @player
            clock: @clock
            weather: @weather

        # todo: don't have states determined yet
        # switch state.current()
        #     when 

        @render()

    render: ->
        #this will create the container the first time
        #then rendered will be flagged true and it will
        #not do anything until that is altered
        #we handle all other elements below
        super

        @hud.render()
        @town.render()

$ ->
    World.game = new ModTownGame "#container"
