class World
    constructor: (map) ->
        @map = map
        @actionPrecedence = {}
        @entities = []
        orderedActions = [
            'rotate'
            'sendModule'
            'setModule'
            'digTile'
            'move'
        ]
        for action, i in orderedActions
            @actionPrecedence[action] = i
    addDrone: (x, y, options) ->
        drone = new Drone(@map)
        if options
            if 'unlimited energy' in options.special
                drone.energy = 10000000
            if 'test' in options.special
                drone.loadCode CodeParser.testCode
        @entities.push drone
        drone.x = x
        drone.y = y
        return drone
    tick: (inputs) ->
        actionList = []
        for entity in @entities
            entity.tick actionList, inputs
        actionAtoms = [].concat.apply [], 
            for action in actionList
                for prop, value of action when prop isnt 'drone'
                    drone: action.drone
                    type: prop
                    value: value
        actionAtoms.sortByValue (e) => @actionPrecedence[e.type]
        for atom in actionAtoms
            switch atom.type
                when 'digTile'
                    @map.setTile atom.value.x, atom.value.y, 
                        tileIDName: 'stoneBackground'
                        tileContentName: 'sky'
                when 'rotate'
                    atom.drone.rotate atom.value.direction
                when 'move'
                    @moveEntity atom.drone, atom.value.x, atom.value.y
                when 'sendModule'
                    drone = atom.drone
                    tile = @map.getTile drone.x + drone.direction.x, drone.y + drone.direction.y
                    tile.entities.forEach (ent) ->
                        if ent instanceof Drone
                            ent.modules[atom.value] = drone.modules[atom.value]
    moveEntity: (entity, newX, newY) ->
        @map.getEntitiesList entity.x, entity.y
        .remove entity
        @map.getEntitiesList newX, newY
        .push entity
        entity.x = newX
        entity.y = newY        

window.World = World;