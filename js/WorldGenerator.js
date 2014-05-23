(function () {
    WorldGenerator = {
        makeEmptyMap: function (width, height) {
            var map = [];
            for (var i = 0; i < width; ++i) {
                var col = [];
                for (var j = 0; j < height; ++j) {
                    col.push({
                        tileID: 0,
                        tileContent: 0
                    });
                }
                map.push(col);
            }
            return {
                _data: map,
                getTile: function (x, y, obj) {
                    obj = obj || {};
                    if (!this.isInBounds(x, y)) {
                        obj.tileIDName = 'sky';
                        obj.tileID = 0;
                        obj.tileContent = 0;
                        obj.tileContentName = 'sky';
                    } else {
                        obj.tileIDName = game.tileNameByIndex[this._data[x][y].tileID];
                        obj.tileID = this._data[x][y].tileID;
                        obj.tileContentName = game.tileNameByIndex[this._data[x][y].tileContent];
                        obj.tileContent = this._data[x][y].tileContent;
                    }
                    return obj;
                },
                setTile: function (x, y, object) {
                    if (!this.isInBounds(x, y)) return;
                    if (object.tileID != null) this._data[x][y].tileID = object.tileID;
                    if (object.tileContent != null) this._data[x][y].tileContent = object.tileContent;
                    if (object.tileIDName != null) {
                        this._data[x][y].tileID = game.tileIndexByName[object.tileIDName];
                    }
                    if (object.tileContentName != null) {
                        this._data[x][y].tileContent = game.tileIndexByName[object.tileContentName];
                    }
                },
                isInBounds: function (x, y) {
                    return !(x < 0 || x >= this._data.length || y < 0 || y >= this._data[0].length);
                }
            };
        },
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
                map.setTile(i, Math.round(y), {
                    tileIDName: 'grass',
                    tileContentName: 'dirt'
                });
                for (var j = Math.round(y) + 1; j < 1000; ++j) {
                    if (Math.pow(Math.random(), 2) + (j - y) / 40 > 0.99) {
                        if (Math.random() > 0.999) {
                            map.setTile(i, j, {
                                tileIDName: 'iron',
                                tileContentName: 'iron'
                            });
                            this.ironLocations.push({ x: i, y: j });
                        } else {
                            map.setTile(i, j, {
                                tileIDName: 'stone',
                                tileContentName: 'stone'
                            });
                        }
                    } else {
                            map.setTile(i, j, {
                                tileIDName: 'dirt',
                                tileContentName: 'dirt'
                            });
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
                    if (!map.isInBounds(current.x, current.y)) continue;
                    map.setTile(current.x, current.y, {
                        tileIDName: 'iron',
                        tileContentName: 'iron'
                    });
                    current.x += directions[dirIndex].x;
                    current.y += directions[dirIndex].y;
                    if (Math.random()  > 0.66) dirIndex = (dirIndex + 1) % 4;
                    else if (Math.random() > 0.5) dirIndex = dirIndex === 0 ? 3 : dirIndex - 1;
                }
            }
        }
    }

    window.WorldGenerator = WorldGenerator;
})();