// Generated by CoffeeScript 1.7.1
(function() {
  var NameGenerator;

  NameGenerator = (function() {
    function NameGenerator() {}

    NameGenerator.adjectives = ['old', 'new', 'big', 'small', 'hairy', 'vanilla', 'hard', 'soft', 'funny'];

    NameGenerator.nouns = ['apple', 'lemon', 'fish', 'racoon', 'hobbit', 'tomato', 'chair', 'man', 'drone'];

    NameGenerator.generate = function() {
      var adj, noun;
      adj = this.adjectives[Math.floor(Math.random() * this.adjectives.length)];
      noun = this.nouns[Math.floor(Math.random() * this.nouns.length)];
      return "" + adj + " " + noun;
    };

    return NameGenerator;

  })();

  window.NameGenerator = NameGenerator;

}).call(this);

//# sourceMappingURL=NameGenerator.map
