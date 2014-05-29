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
                        type: 'conditional'
                        cond: words.slice(1).join ' '
                        code: line
                else if words[0] is 'module'
                    output.push
                        type: 'module declaration'
                        name: words[1]
                        code: line
                else
                    output.push
                        type: 'command'
                        action: line
                        code: line
        if indent
            subexp = lines.slice(indentStart, i).join '\n'
            output[output.length - 1].instructions = @buildAst subexp
        return output

    @reconstructCode: (ast, tabs) =>
        code = ''
        tabs = tabs || ''
        for node in ast
            code += tabs + node.code + '\n'
            if node.type in ['conditional', 'module declaration']
                code += @reconstructCode node.instructions, (tabs + '    ')

    @makeInstructions: (ast) =>
        processed = []
        for node in ast
            inst = {}
            if node.type is 'conditional'
                instructions = @makeInstructions node.instructions
                cond = node.cond.split ' '
                do (instructions, cond) ->
                    conditionFn = null
                    switch cond[0]
                        when 'see'
                            conditionFn = (action, drone, map) ->
                                seenTile = map.getTile drone.x + drone.direction.x, drone.y + drone.direction.y
                                return seenTile.tileContentName is cond[1]
                        when 'memory'
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
                                    conditionFn = (action, drone, map) ->
                                        val = getValue drone.memory
                                        return (operator is 'not' and drone.memory[name] isnt val) or
                                        (operator is 'is' and drone.memory[name] is val)

                        when 'input'
                            key = cond[1]
                            do (key) ->
                                conditionFn = (action, drone, map, inputs) ->
                                    inputs.some (inp) -> inp == Phaser.Keyboard[key]
                        else
                            throw "Unsupported condition #{cond[0]}"
                    do (conditionFn) ->
                        inst.execute = (action, drone, map, inputs) ->
                            if conditionFn action, drone, map, inputs
                                for subInstruction in instructions
                                    subInstruction.execute action, drone, map
            else if node.type is 'module declaration'
                instructions = @makeInstructions node.instructions
                module =
                    name: node.name
                    code: @reconstructCode node.instructions
                    instructions: instructions
                do (module) ->
                    inst.execute = (action, drone, map) ->
                        drone.loadModule module
            else if node.type is 'command'
                action = node.action.split ' '
                switch action[0]
                    when 'dig'
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
                    when 'rotate'
                        direction = action[1]
                        do (direction) ->
                            inst.execute = (action, drone, map) ->
                                action.rotate =
                                    direction: direction
                    when 'increment'
                        name = action[1]
                        do (name) ->
                            inst.execute = (action, drone, map) ->
                                drone.memory[name] = 0 unless drone.memory[name]?
                                drone.memory[name]++
                    when 'decrement'
                        name = action[1]
                        do (name) ->
                            inst.execute = (action, drone, map) ->
                                drone.memory[name] = 0 unless drone.memory[name]?
                                drone.memory[name]--
                    when 'set_module'
                        name = action[1]
                        do (name) ->
                            inst.execute = (action, drone, map) ->
                                drone.activeModule = name
                    when 'send_module'
                        name = action[1]
                        do (name) ->
                            inst.execute = (action, drone, map) ->
                                action.sendModule = name
                    when 'debug'
                        js = action.slice(1).join ' '
                        do (js) ->
                            inst.execute = (action, drone, map) ->
                                for prop, value of drone.memory
                                    js = "var #{prop} = #{value};" + js
                                fn = Function js
                                fn()
                    else
                        if action[0] in ['set', 'add', 'mult', 'sub', 'div']
                            name = action[1]
                            value = action[2]
                            operator = {
                                set: ''
                                add: '+'
                                mult: '*'
                                sub: '-'
                                div: '/'
                            }[action[0]]
                            do (value, operator) ->
                                getValue = null
                                unless isNaN value
                                    value = +value
                                    getValue = -> value
                                else
                                    getValue = (memory) -> memory[value] || 0
                                do (name, getValue) ->
                                    eval """
                                    inst.execute = function (action, drone, map) {
                                        drone.memory[name] #{operator}= getValue(drone.memory);
                                    }
                                    """
                        else
                            throw "Unsuported command #{action[0]}"
            processed.push inst
        return processed

    @compileCode: @makeInstructions.compose @buildAst


window.CodeParser = CodeParser;

CodeParser.testCode = '''
if input A
    rotate ccw
if input D
    rotate cw
if input W
    dig forward
'''

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