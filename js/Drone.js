// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function() {
    var Drone;
    Drone = (function() {
      function Drone(map) {
        this.rotate = __bind(this.rotate, this);
        this.destroy = __bind(this.destroy, this);
        this.loadCode = __bind(this.loadCode, this);
        this.execute = __bind(this.execute, this);
        this.tick = __bind(this.tick, this);
        this.map = map;
        this.name = NameGenerator.generate();
        this.sprite = game.add.sprite(8, 8, 'drone');
        this.sprite.anchor.set(0.5);
        this.sprite.inputEnabled = true;
        this.sprite.events.onInputUp.add(function() {
          return true;
        }, true);
        this.energy = 0;
        this.instructions = [];
        this.code = '';
        this.direction = {
          x: 0,
          y: -1
        };
        this.memory = {};
      }

      Drone.prototype.tick = function() {
        return this.execute();
      };

      Drone.prototype.execute = function() {
        var action, inst, _i, _len, _ref;
        action = {};
        _ref = this.instructions;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          inst = _ref[_i];
          inst.execute(action, this, this.map);
        }
        if ('digTile' in action) {
          this.map.setTile(action.digTile.x, action.digTile.y, {
            tileIDName: 'stoneBackground',
            tileContentName: 'sky'
          });
        }
        if ('rotate' in action) {
          this.rotate(action.rotate.direction);
        }
        if ('move' in action) {
          this.x = action.move.x;
          return this.y = action.move.y;
        }
      };

      Drone.prototype.loadCode = function(code) {
        this.instructions = CodeParser.compileCode(code);
        return this.code = code;
      };

      Drone.prototype.destroy = function() {
        return sprite.destroy();
      };

      Drone.prototype.rotate = function(direction) {
        if (direction === 'cw') {
          this.sprite.rotation += Math.PI / 2;
          return this.direction = {
            x: -this.direction.y,
            y: this.direction.x
          };
        } else if (direction === 'ccw') {
          this.sprite.rotation -= Math.PI / 2;
          return this.direction = {
            x: this.direction.y,
            y: -this.direction.x
          };
        }
      };

      Drone.property('x', {
        get: function() {
          return (this.sprite.x - 8) / 16;
        },
        set: function(val) {
          return this.sprite.x = val * 16 + 8;
        }
      });

      Drone.property('y', {
        get: function() {
          return (this.sprite.y - 8) / 16;
        },
        set: function(val) {
          return this.sprite.y = val * 16 + 8;
        }
      });

      return Drone;

    })();
    return window.Drone = Drone;
  })();

}).call(this);
