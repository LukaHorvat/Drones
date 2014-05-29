(function () {
    WorldGenerator = {
        makeEmptyMap: function (width, height) {
            var map = [];
            for (var i = 0; i < width; ++i) {
                var col = [];
                for (var j = 0; j < height; ++j) {
                    col.push({
                        tileID: 0,
                        tileContent: 0,
                        entities: []
                    });
                }
                map.push(col);
            }
            var emptyTile = {
                tileID: 0,
                tileContent: 0,
                entities: []
            };
            var getTileState = function (tile, obj) {
                obj = obj || {};
                //Copy data
                obj.tileID = tile.tileID;
                obj.tileContent = tile.tileContent;
                //Generate friendly names
                obj.tileIDName = game.tileNameByIndex[obj.tileID];
                obj.tileContentName = game.tileNameByIndex[obj.tileContent];
                return obj;
            };
            return {
                _data: map,
                getTile: function (x, y, obj) {
                    obj = obj || {};
                    if (!this.isInBounds(x, y)) getTileState(emptyTile, obj);
                    else getTileState(this._data[x][y], obj);
                    return obj;
                },
                setTile: function (x, y, obj) {
                    if (!this.isInBounds(x, y)) return;
                    if (obj.tileID != null) this._data[x][y].tileID = obj.tileID;
                    if (obj.tileContent != null) this._data[x][y].tileContent = obj.tileContent;
                    if (obj.tileIDName != null) {
                        this._data[x][y].tileID = game.tileIndexByName[obj.tileIDName];
                    }
                    if (obj.tileContentName != null) {
                        this._data[x][y].tileContent = game.tileIndexByName[obj.tileContentName];
                    }
                },
                getEntitiesList: function (x, y) {
                    return this._data[x][y].entities;
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