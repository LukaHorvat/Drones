do ->
    class Drone
        constructor: (map) ->
            @map = map;
            @sprite = game.add.sprite(0, 0, 'drone')
            @sprite.anchor.set(0.5);
            @name = NameGenerator.generate()
            @sprite.inputEnabled = true
            @sprite.events.onInputUp.add () ->
                return true
            , true

        tick: () ->
            return this.execute()

        execute: () ->
            action = {}
            for inst in @instructions
                inst.execute action, this, @map
            if 'digTile' of action
                @map[action.digTile.x][action.digTile.y].tileID = game.tileIndexByName.stoneBackground
                @map[action.digTile.x][action.digTile.y].tileContent = game.tileIndexByName.sky
            if 'rotate' of action
                if action.rotate.direction is 'cw'
                    @sprite.rotation += Math.PI / 2;
                    [@direction.x, @direction.y] = [-@direction.y, @direction.x]
                else if action.rotate.direction is 'ccw'
                    @sprite.rotation -= Math.PI / 2;
                    [@direction.x, @direction.y] = [@direction.y, -@direction.x]
            if 'move' of action
                @x = action.move.x
                @y = action.move.y

        addInstruction: (inst) ->
            @instructions.push inst

        destroy: () ->
            sprite.destroy()

        energy: 0

        instructions: []

        sprite: null

        direction: { x: 0, y: -1 }

        memory: {}

        name: "drone"

        @property 'x',
            get: () -> (@sprite.x - 8) / 16
            set: (val) -> @sprite.x = val * 16 + 8
        @property 'y',
            get: () -> (@sprite.y - 8) / 16;
            set: (val) -> @sprite.y = val * 16 + 8

    window.Drone = Drone;