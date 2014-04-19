class GPS
    constructor: (@town=null) ->

    get_travel_time_between: (point_a, point_b, travel_speed=1) ->
        distance = Address.distance_between(point_a, point_b)
        time = 0

        if distance
            time = distance * travel_speed

        time

World.GPS = GPS
