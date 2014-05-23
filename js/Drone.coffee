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

        tick: () => @execute()

        execute: () =>
            action = {}
            for inst in @instructions
                inst.execute action, this, @map
            if 'digTile' of action
                @map.setTile action.digTile.x, action.digTile.y, 
                    tileIDName: 'stoneBackground'
                    tileContentName: 'sky'
            if 'rotate' of action
                @rotate action.rotate.direction
            if 'move' of action
                @x = action.move.x
                @y = action.move.y

        loadCode: (code) =>
            @instructions = CodeParser.compileCode code
            @code = code

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