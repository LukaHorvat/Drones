class World
    constructor: (map) ->
        @map = map
    entities: []
    addDrone: (x, y, options) ->
        drone = new Drone(@map)
        if options
            if 'unlimited energy' in options.special
                drone.energy = 10000000
            if 'test' in options.special
                drone.instructions = CodeParser.testInstructions
        @entities.push drone
        drone.x = x
        drone.y = y
    tick: () ->
        for entity in @entities
            entity.tick()
    map: null

window.World = World;