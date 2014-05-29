(function() {
    'use strict';

    var map = [];
    var grid = [];
    var camera = {};
    var graphics;
    var inputs = [];
    
    Function.prototype.property = function(prop, desc) {
      return Object.defineProperty(this.prototype, prop, desc);
    };

    function Game() {
        this.player = null;
        this.cursors = null;
        Object.defineProperty(camera, "x", {
            get: function () {
                return game.camera.x / 16;
            },
            set: function (val) {
                game.camera.x = val * 16;
                if (Math.floor(game.camera.x / 16) !== game.camera.x / 16) debugger;
            }
        });
        Object.defineProperty(camera, "y", {
            get: function () {
                return game.camera.y / 16;
            },
            set: function (val) {
                game.camera.y = val * 16;
            }
        });
    }

    Game.prototype = {
        world: null,
        create: function () {
            Tests.doTests();

            game.world.setBounds(-10000000, -10000000, 20000000, 20000000);
            this.cursors = game.input.keyboard.createCursorKeys();

            map = WorldGenerator.makeEmptyMap(1000, 1000);

            WorldGenerator.teraform(map);

            var group = game.add.group();
            for (var i = 0; i < Math.ceil(game.width / 16); ++i) {
                var col = [];
                for (var j = 0; j < Math.ceil(game.height / 16); ++j) {
                    var sprite = group.create(i * 16, j * 16, 'tiles');
                    sprite.fixedToCamera = true;
                    col.push(sprite);
                }
                grid.push(col);
            }

            var i;
            for (i = 0; map.getTile(500, i).tileIDName !== 'grass'; ++i);
            i--;

            camera.y = i - 20;
            camera.x = 490;

            this.world = new World(map);
            this.world.addDrone(500, i, { special: [ 'unlimited energy', 'test' ] })

            game.time.advancedTiming = true;

            var world = this.world;
            game.time.events.repeat(200, 100, function () {
                world.tick(inputs);
                inputs = [];
            }, this.world);

            graphics = game.add.graphics(0, 0);
            graphics.fixedToCamera = true;
        },
        update: function () {
            if (this.cursors.up.isDown) {
                camera.y -= 1;
            }
            else if (this.cursors.down.isDown) {
                camera.y += 1;
            }

            if (this.cursors.left.isDown) {
                camera.x -= 1;
            }
            else if (this.cursors.right.isDown) {
                camera.x += 1;
            }
            //Update view
            var tile = {};
            var right = Math.ceil(game.width / 16);
            var bottom = Math.ceil(game.height / 16);
            for (var i = 0; i < right; ++i) {
                for (var j = 0; j < bottom; ++j) {
                    var tileX = i + camera.x;
                    var tileY = j + camera.y;
                    map.getTile(tileX, tileY, tile);
                    grid[i][j].frame = tile.tileID;
                }
            }
            graphics.clear();
            graphics.lineStyle(1, 0x000000);

            //Update cel shading
            var right = Math.ceil(game.width / 16);
            var bottom = Math.ceil(game.height / 16);
            for (var i = 1; i < right; ++i) {
                for (var j = 1; j < bottom; ++j) {
                    var tileX = i + camera.x;
                    var tileY = j + camera.y;
                    if (map.getTile(tileX, tileY, tile).tileContentName === 'sky') {
                        if (map.getTile(tileX - 1, tileY, tile).tileContentName !== 'sky') {
                            graphics.moveTo(i * 16, j * 16);
                            graphics.lineTo(i * 16, j * 16 + 16);
                        }
                        if (map.getTile(tileX, tileY - 1, tile).tileContentName !== 'sky') {
                            graphics.moveTo(i * 16, j * 16);
                            graphics.lineTo(i * 16 + 16, j * 16);
                        }
                    }
                }
            }

            //Register inputs
            for (var i = 0; i < 300; ++i) {
                if (game.input.keyboard.isDown(i)) {
                    inputs.push(i);
                }
            }
        },
        render: function () {
            game.debug.text(game.time.fps, 10, 10);
        },
        onInputDown: function () {
            //game.state.start('menu');
        }
    };

    window.Game = Game;

}());
