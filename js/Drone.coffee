do ->
    class Drone
        constructor: (map) ->
            @map = map;
            @name = NameGenerator.generate()
            @sprite = game.add.sprite(8, 8, 'drone')
            @sprite.anchor.set(0.5);
            @sprite.inputEnabled = true
            @sprite.events.onInputUp.add () ->
                return true
            , true
            @energy = 0
            @instructions = []
            @code = ''
            @direction = 
                x: 0
                y: -1
            @memory = {}
            @modules = {}
            @activeModule = 'none'

        tick: (actionList, inputs) -> @execute actionList, inputs

        execute: (actionList, inputs) =>
            unless @activeModule is 'none'
                instructions = @modules[@activeModule].instructions
            else return
            action = {}
            action.drone = this
            for inst in instructions
                inst.execute action, this, @map, inputs
            actionList.push action if actionList?

        loadCode: (code) =>
            module = 
                code: code
                name: 'immediate'
                instructions: CodeParser.compileCode code
            @activeModule = module.name
            @modules[module.name] = module

        loadModule: (module) =>
            @modules[module.name] = module

        activeModule: (name) =>
            @activeModule = name

        destroy: () =>
            sprite.destroy()

        rotate: (direction) =>
            if direction is 'cw'
                @sprite.rotation += Math.PI / 2;
                @direction =
                    x: -@direction.y
                    y: @direction.x
            else if direction is 'ccw'
                @sprite.rotation -= Math.PI / 2;
                @direction =
                    x: @direction.y
                    y: -@direction.x

        @property 'x',
            get: () -> (@sprite.x - 8) / 16
            set: (val) -> @sprite.x = val * 16 + 8
        @property 'y',
            get: () -> (@sprite.y - 8) / 16;
            set: (val) -> @sprite.y = val * 16 + 8

    window.Drone = Drone;