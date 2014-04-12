# Helpers
# @codekit-prepend "helper/Time.coffee"

pin = (extra=null) ->
    console.log("Hit pin #{if this.id then this.id += 1 else this.id = 1}", extra)

# Classes
# @codekit-prepend "class/Calendar.coffee"
# @codekit-prepend "class/Timer.coffee"
# @codekit-prepend "class/WorldClock.coffee"
# @codekit-prepend "class/WeatherSystem.coffee"
# @codekit-prepend "class/RenderedObject.coffee"
# @codekit-prepend "class/FloatingMenu.coffee"
# @codekit-prepend "class/FloatingMenus.coffee"
# @codekit-prepend "class/Alert.coffee"
# @codekit-prepend "class/HUD.coffee"
# @codekit-prepend "class/StateManager.coffee"
# @codekit-prepend "class/Town.coffee"
# @codekit-prepend "class/Street.coffee"
# @codekit-prepend "class/Block.coffee"
# @codekit-prepend "class/Resident.coffee"
# @codekit-prepend "class/Structure.coffee"
# @codekit-prepend "class/Player.coffee"

# Execution Stuff
# @codekit-append "game.coffee"

