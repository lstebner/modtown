class BuildMenu extends FloatingMenu
    constructor: ->
        super

        @title = 'Build Menu'
        @items =
            build_farm: "Build Farm"
            build_factory: "Build Factory"
            build_housing: "Build Housing"
