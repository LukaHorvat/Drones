(function () {
    WorldGenerator = {
        teraform: function (map) {
            this.landscape(map);
            this.spreadIronVeins(map);
        },
        landscape: function (map) {
            this.ironLocations = [];
            var y = 500;
            var dy = 0;
            for (var i = 0; i < 1000; ++i) {
                dy += (Math.random() * 0.4 - 0.2) + (-dy * 0.1)
                y += dy;
                map[i][Math.round(y)] = {
                    tileID: game.tileIndexByName.grass,
                    tileContent: game.tileIndexByName.dirt
                };
                for (var j = Math.round(y) + 1; j < 1000; ++j) {
                    if (Math.pow(Math.random(), 2) + (j - y) / 40 > 0.99) {
                        if (Math.random() > 0.999) {
                            map[i][j] = {
                                tileID: game.tileIndexByName.iron,
                                tileContent: game.tileIndexByName.iron
                            }
                            this.ironLocations.push({ x: i, y: j });
                        } else {
                            map[i][j] = {
                                tileID: game.tileIndexByName.stone,
                                tileContent: game.tileIndexByName.stone
                            }
                        }
                    } else {
                        map[i][j] = {
                            tileID: game.tileIndexByName.dirt,
                            tileContent: game.tileIndexByName.dirt
                        };
                    }
                }
            }
        },
        spreadIronVeins: function (map) {
            var directions = [{ x: 1, y: 0 }, { x: 0, y: 1 }, { x: -1, y: 0 }, { x: 0, y: -1 }];
            for (var i = 0; i < this.ironLocations.length; ++i) {
                var veinLength = Math.floor(Math.random() * 15);
                var dirIndex = Math.floor(Math.random() * 4);
                var current = this.ironLocations[i];
                for (var j = 0; j < veinLength; ++j) {
                    if (!this.inBounds(current.x, current.y, map)) continue;
                    map[current.x][current.y] = {
                        tileID: game.tileIndexByName.iron
                    };
                    current.x += directions[dirIndex].x;
                    current.y += directions[dirIndex].y;
                    if (Math.random()  > 0.66) dirIndex = (dirIndex + 1) % 4;
                    else if (Math.random() > 0.5) dirIndex = dirIndex === 0 ? 3 : dirIndex - 1;
                }
            }
        },
        inBounds: function (x, y, map) {
            if (x < 0 || y < 0 || x >= map.length || y >= map[0].length) return false;
            return true;
        }
    }

    window.WorldGenerator = WorldGenerator;
})();