(function() {
  'use strict';

  function Preloader() {
    this.asset = null;
    this.ready = false;
  }

  Preloader.prototype = {

    preload: function () {
      this.game.tileIndexByName = {};

      var tiles = ['sky', 'dirt', 'grass', 'stone', 'iron', 'stoneBackground'];
      this.game.tileNameByIndex = tiles;
      for (var i = 0; i < tiles.length; ++i) {
        this.game.tileIndexByName[tiles[i]] = i;
      }

      this.load.spritesheet('tiles', 'assets/tiles.png', 16, 16);
      this.load.spritesheet('drone', 'assets/drone.png', 16, 16);

      this.load.onLoadComplete.addOnce(this.onLoadComplete, this);
    },

    create: function () {
    },

    update: function () {
      if (!!this.ready) {
        this.game.state.start('game');
      }
    },

    onLoadComplete: function () {
      this.ready = true;
    }
  };

  window.Preloader = Preloader;

}());
