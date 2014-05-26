test = (name, env) ->
    logger =
        failed: false
        fail: () ->
            console.log "%c '#{name}' failed.", 'color: red' unless @failed
            @failed = true
        expectEquality: (expect, got, checkName) ->
            unless expect is got
                @fail()
                console.log "%c Discrepancy in '#{checkName}'. Expected #{expect}, got #{got}.", 
                'color: red'
        expectPresence: (value, checkName) ->
            if typeof value is 'undefined'
                @fail()
                console.log "%c Discrepancy in '#{checkName}'. Value is undefined.", 
                'color: red'

    env.call(logger)
    unless logger.failed
        console.log "%c '#{name}' passed.", 'color: green'

class Tests
    @doTests: ->
        test 'Extensions', ->
            f = (x) -> x * 2
            g = (x) -> x + 2

            @expectEquality f(g 5), ((f.compose g) 5), 'composition with argument 5'

        test 'Parsing into AST', ->
            code = '''
            set var 1
            if memory var is 1
                set var 2
            if memory var is 2
                set var 3
            '''
            ast = CodeParser.buildAst code
            @expectPresence ast[1], 'second node presence'
            @expectPresence ast[1].cond, 'condition presence'
            @expectEquality 'memory var is 1', ast[1].cond, 'condition check'
            @expectPresence ast[1].instructions, 'instruction presence'

        test 'Basic variable manipulation', ->
            code = '''
            set var 1
            increment var
            if memory var is 2
                set var 5
            increment var
            '''
            drone = new Drone(null)
            drone.loadCode code
            drone.tick()

            @expectEquality 6, drone.memory.var, 'setting, incrementing and conditions'

        test 'Arithmetic', ->
            code = '''
            set a 1
            increment a
            mult a a
            div a 2
            sub a 1
            add a 4
            '''
            drone = new Drone(null)
            drone.loadCode code
            drone.tick()

            @expectEquality 5, drone.memory.a, 'add, mult, sub and div'

        test 'Drone movement', ->
            code = '''
            increment step
            if memory step is 1
                dig forward
            if memory step is 2
                rotate cw
            if memory step is 3
                rotate cw
            if memory step is 4
                dig forward
            if memory step is 5
                dig forward
            if memory step is 6
                rotate ccw
            if memory step is 7
                dig forward
            '''

            map = WorldGenerator.makeEmptyMap(3, 3)
            drone = new Drone(map)
            drone.x = 1
            drone.y = 1
            drone.loadCode code
            for i in [1..7]
                drone.tick()

            @expectEquality 2, drone.x, 'x coordinate'
            @expectEquality 2, drone.y, 'y coordinate'

        test 'Modules', ->
            code = '''
            module rotate_ccw
                increment count
                rotate ccw
                if memory count is 2
                    set count 0
                    set_module go_left
            module go_left
                increment count
                dig forward
                if memory count is 4
                    set count 0
                    set_module rotate_cw
            module rotate_cw
                increment count
                rotate cw
                if memory count is 2
                    set count 0
                    set_module go_right
            module go_right
                increment count
                dig forward
                if memory count is 5
                    set count 0
                    set_module none
            set_module rotate_ccw
            '''

            map = WorldGenerator.makeEmptyMap 5, 1
            drone = new Drone(map)
            drone.loadCode code
            drone.rotate 'cw'
            drone.x = 4
            for i in [1..14]
                drone.tick()

            @expectEquality 5, drone.x, 'x coordinate'

        test 'Looking forward', ->
            code = '''
            if see dirt
                increment count
            increment step
            if memory step is 1
                rotate ccw
            if memory step is 2
                dig forward
            if memory step is 3
                rotate cw
            if memory step is 4
                dig forward
            if memory step is 5
                rotate cw
            '''

            map = WorldGenerator.makeEmptyMap 3, 3
            map.setTile 1, 0, 
                tileIDName: 'dirt'
                tileContentName: 'dirt'
            drone = new Drone(map)
            drone.x = 1
            drone.y = 1
            drone.loadCode code
            for i in [1..6]
                drone.tick()

            @expectEquality 2, drone.memory.count, 'dirt sightings'

window.Tests = Tests