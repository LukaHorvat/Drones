class CodeParser
    @makeInstructions: (ast) ->
        processed = []
        for node in ast
            inst = {}
            if node.cond
                instructions = @makeInstructions node.instructions
                cond = node.cond.split ' '
                do (instructions, cond) ->
                    if cond[0] is 'see'
                        inst.execute = (action, drone, map) ->
                            seenTile = map[drone.x + drone.direction.x][drone.y + drone.direction.y]
                            if seenTile.tileContent is game.tileIndexByName[cond[1]]
                                for subInstruction in instructions
                                    subInstruction.execute action, drone, map
                    if cond[0] is 'memory'
                        name = cond[1]
                        operator = cond[2]
                        value = cond[3]
                        do (name, operator, value) ->
                            inst.execute = (action, drone, map) ->
                                if operator is 'not' and drone.memory[name] isnt value
                                    for subInstruction in instructions
                                        subInstruction.execute action, drone, map
            else
                action = node.action.split ' '
                if action[0] is 'dig'
                    direction = action[1]
                    do (direction) ->
                        inst.execute = (action, drone, map) ->
                            targetCoords = { x: 0, y: 0 }
                            if direction is 'forward'
                                targetCoords = 
                                    x: drone.x + drone.direction.x
                                    y: drone.y + drone.direction.y
                            action.digTile = targetCoords
                            action.move = targetCoords
                if action[0] is 'set'
                    name = action[1]
                    value = action[2]
                    do (name, value) ->
                        inst.execute = (action, drone, map) ->
                            drone.memory[name] = value
                if action[0] is 'rotate'
                    direction = action[1]
                    do (direction) ->
                        inst.execute = (action, drone, map) ->
                            action.rotate =
                                direction: direction
            processed.push inst
        return processed



window.CodeParser = CodeParser;

testCode = [{
        action: 'set dirt 0'
    },
    {
        cond: 'see dirt'
        instructions: [
            {
                action: 'dig forward'
            },
            {
                action: 'set dirt 1'
            }
        ]
    },
    {
        cond: 'memory dirt not 1'
        instructions: [
            {
                action: 'rotate cw'
            }
        ]
    }
]

CodeParser.testInstructions = CodeParser.makeInstructions(testCode)