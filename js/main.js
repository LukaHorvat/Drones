window.onload = function () {
  'use strict';

  window.game = new Phaser.Game(1000, 620, Phaser.AUTO, 'drones-game');
  game.state.add('preloader', Preloader);
  game.state.add('game', Game);

  game.state.start('preloader');
};
