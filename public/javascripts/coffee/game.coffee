class ModTownGame extends RenderedObject
    constructor: ->
        super

        @clock = new WorldClock()

        _.defer =>
            @flux_menu = new FluxMenu null,
                clock: @clock


        @weather = new WeatherSystem()

        @state = new StateManager('init')
        @setup_player()
        @setup_hud()
        @setup_overworld()
        @setup_town()
        @setup_events()

        @state.change_state('running')

        @clock.on_tick =>
            @update()

        @clock.tick()

    setup_player: ->
        @player = new Player()

        #set up player events
        #player.on ..., =>

    setup_town: ->
        town_opts = 
            name: 'AhhsumTown'
            balance: 1000

        @town = new Town @container.find('#town'), town_opts

        _.defer =>
            @town.create_street({ blocks: 2 })
            @town.create_street({ blocks: 2 })

    setup_overworld: ->
        @overworld = new Overworld()

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

    pause: (resume_in=null) ->
        @state.change_state('paused')
        clearInterval(@timeout) if @timeout

        if resume_in
            setTimeout =>
                @resume()
            , resume_in

    resume: ->
        @state.change_state('running')

    update: ->
        @state.update()

        switch @state.current()
            when 'running'
                @weather.update(@clock)

                @town.update(@clock, @weather)
                @hud.update 
                    town: @town
                    player: @player
                    clock: @clock
                    weather: @weather

        @render()

    render: ->
        #this will create the container the first time
        #then rendered will be flagged true and it will
        #not do anything until that is altered
        #we handle all other elements below
        super

        switch @state.current()
            when 'running'
                @hud.render()
                @town.render()

            when 'overworld'
                @hud.render()

$ ->
    World.game = new ModTownGame "#container"
    World.gps = new GPS World.game.town
