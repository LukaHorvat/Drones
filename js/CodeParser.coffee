class CodeParser
    @buildAst: (source) =>
        lines = source.split('\n').filter (line) -> line.replace(/\s/, '') isnt '';
        output = []
        indent = false
        indentStart = 0
        for line, i in lines
            if line.substr(0, 4) is '    ' 
                unless indent
                    indent = true
                    indentStart = i
                lines[i] = line.substr 4
            else if indent is true
                indent = false
                subexp = lines.slice(indentStart, i).join '\n'
                output[output.length - 1].instructions = @buildAst subexp
            unless indent
                words = line.split ' '
                if words[0] is 'if'
                    output.push
                        cond: words.slice(1).join ' '
                else
                    output.push
                        action: line
        if indent
            subexp = lines.slice(indentStart, i).join '\n'
            output[output.length - 1].instructions = @buildAst subexp
        return output

    @makeInstructions: (ast) =>
        processed = []
        for node in ast
            inst = {}
            if node.cond #Conditions
                instructions = @makeInstructions node.instructions
                cond = node.cond.split ' '
                do (instructions, cond) ->
                    if cond[0] is 'see'
                        inst.execute = (action, drone, map) ->
                            seenTile = map.getTile drone.x + drone.direction.x, drone.y + drone.direction.y
                            if seenTile.tileContentName is cond[1]
                                for subInstruction in instructions
                                    subInstruction.execute action, drone, map
                    else if cond[0] is 'memory'
                        name = cond[1]
                        operator = cond[2]
                        value = cond[3]
                        do (value) ->
                            getValue = null
                            unless isNaN value
                                value = +value
                                getValue = -> value
                            else
                                getValue = (memory) -> memory[value] || 0
                            do (name, operator, getValue) ->
                                inst.execute = (action, drone, map) ->
                                    val = getValue drone.memory
                                    if operator is 'not' and drone.memory[name] isnt val
                                        for subInstruction in instructions
                                            subInstruction.execute action, drone, map
                                    if operator is 'is' and drone.memory[name] is val
                                        for subInstruction in instructions
                                            subInstruction.execute action, drone, map
                    else
                        throw "Unsupported condition #{cond[0]}"
            else #Actions
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
                else if action[0] is 'rotate'
                    direction = action[1]
                    do (direction) ->
                        inst.execute = (action, drone, map) ->
                            action.rotate =
                                direction: direction
                else if action[0] is 'increment'
                    name = action[1]
                    do (name) ->
                        inst.execute = (action, drone, map) ->
                            drone.memory[name] = 0 unless drone.memory[name]?
                            drone.memory[name]++
                else if action[0] is 'decrement'
                    name = action[1]
                    do (name) ->
                        inst.execute = (action, drone, map) ->
                            drone.memory[name] = 0 unless drone.memory[name]?
                            drone.memory[name]--
                else if action[0] in ['set', 'add', 'mult', 'sub', 'div']
                    name = action[1]
                    value = action[2]
                    do (value) ->
                        getValue = null
                        unless isNaN value
                            value = +value
                            getValue = -> value
                        else
                            getValue = (memory) -> memory[value] || 0
                        do (name, getValue) ->
                            switch action[0]
                                when 'set'
                                    inst.execute = (action, drone, map) ->
                                        drone.memory[name] = getValue drone.memory
                                when 'add'
                                    inst.execute = (action, drone, map) ->
                                        drone.memory[name] += getValue drone.memory
                                when 'mult'
                                    inst.execute = (action, drone, map) ->
                                        drone.memory[name] *= getValue drone.memory
                                when 'sub'
                                    inst.execute = (action, drone, map) ->
                                        drone.memory[name] -= getValue drone.memory
                                when 'div'
                                    inst.execute = (action, drone, map) ->
                                        drone.memory[name] /= getValue drone.memory
                else if action[0] is 'debug'
                    js = action.slice(1).join ' '
                    do (js) ->
                        inst.execute = (action, drone, map) ->
                            for prop, value of drone.memory
                                js = "var #{prop} = #{value};" + js
                            fn = Function js
                            fn()
                else
                    throw "Unsuported command #{action[0]}"
            processed.push inst
        return processed

    @compileCode: @makeInstructions.compose @buildAst


window.CodeParser = CodeParser;

testCode = '''
set sawDirt 0
if see dirt
    dig forward
    set sawDirt 1
    set count 0
if memory sawDirt not 1
    increment count
    rotate cw
    if memory count is 4
        dig forward
        set count 0
'''

testAst = CodeParser.buildAst testCode

CodeParser.testInstructions = CodeParser.makeInstructions(testAst)

###
Language docs
instruction ::= 'if' cond | action
value       ::= identifier | number
cond        ::= 'see' tile |
                'memory' identifier compare value
tile        ::= 'dirt' | 'stone' | ...
identifier  ::= string
compare     ::= 'is' | 'not'
action      ::= 'set' identifier value |
                'dig forward' |
                'rotate' rot_dir |
                'increment' identifier |
                'decrement' identifier |
                'add' identifier value |
                'sub' identifier value |
                'mult' identifier value |
                'div' identifier value
rot_dir     ::= 'cw' | 'ccw'
###