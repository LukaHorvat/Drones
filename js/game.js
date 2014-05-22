(function() {
    'use strict';

    var map = [];
    var grid = [];
    var camera = {};
    var graphics;
    
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
            game.world.setBounds(-10000000, -10000000, 20000000, 20000000);
            this.cursors = game.input.keyboard.createCursorKeys();

            for (var i = 0; i < 1000; ++i) {
                var col = [];
                for (var j = 0; j < 1000; ++j) {
                    col.push({
                        tileID: 0,
                        tileContent: 0
                    });
                }
                map.push(col);
            }

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
            for (i = 0; map[500][i].tileID != game.tileIndexByName.grass; ++i);
            i--;

            camera.y = i - 20;
            camera.x = 490;

            this.world = new World(map);
            this.world.addDrone(500, i, { special: [ 'unlimited energy', 'test' ] })

            game.time.advancedTiming = true;

            game.time.events.repeat(200, 100, this.world.tick, this.world);

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
            var right = Math.ceil(game.width / 16);
            var bottom = Math.ceil(game.height / 16);
            for (var i = 0; i < right; ++i) {
                for (var j = 0; j < bottom; ++j) {
                    var tileX = i + camera.x;
                    var tileY = j + camera.y;
                    if (tileX < 0 || tileY < 0 || tileX >= map.length || tileY >= map[0].length) {
                        grid[i][j].frame = game.tileIndexByName.sky;
                    } else {
                        grid[i][j].frame = map[tileX][tileY].tileID;
                    }
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
                    if (map[tileX][tileY].tileContent === game.tileIndexByName.sky) {
                        if (map[tileX - 1][tileY].tileContent !== game.tileIndexByName.sky) {
                            graphics.moveTo(i * 16, j * 16);
                            graphics.lineTo(i * 16, j * 16 + 16);
                        }
                        if (map[tileX][tileY - 1].tileContent !== game.tileIndexByName.sky) {
                            graphics.moveTo(i * 16, j * 16);
                            graphics.lineTo(i * 16 + 16, j * 16);
                        }
                    }
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
