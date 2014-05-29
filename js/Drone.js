// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function() {
    var Drone;
    Drone = (function() {
      function Drone(map) {
        this.rotate = __bind(this.rotate, this);
        this.destroy = __bind(this.destroy, this);
        this.activeModule = __bind(this.activeModule, this);
        this.loadModule = __bind(this.loadModule, this);
        this.loadCode = __bind(this.loadCode, this);
        this.execute = __bind(this.execute, this);
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
        this.modules = {};
        this.activeModule = 'none';
      }

      Drone.prototype.tick = function(actionList, inputs) {
        return this.execute(actionList, inputs);
      };

      Drone.prototype.execute = function(actionList, inputs) {
        var action, inst, instructions, _i, _len;
        if (this.activeModule !== 'none') {
          instructions = this.modules[this.activeModule].instructions;
        } else {
          return;
        }
        action = {};
        action.drone = this;
        for (_i = 0, _len = instructions.length; _i < _len; _i++) {
          inst = instructions[_i];
          inst.execute(action, this, this.map, inputs);
        }
        if (actionList != null) {
          return actionList.push(action);
        }
      };

      Drone.prototype.loadCode = function(code) {
        var module;
        module = {
          code: code,
          name: 'immediate',
          instructions: CodeParser.compileCode(code)
        };
        this.activeModule = module.name;
        return this.modules[module.name] = module;
      };

      Drone.prototype.loadModule = function(module) {
        return this.modules[module.name] = module;
      };

      Drone.prototype.activeModule = function(name) {
        return this.activeModule = name;
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

//# sourceMappingURL=Drone.map
