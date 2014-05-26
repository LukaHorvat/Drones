class NameGenerator
    @adjectives = ['old', 'new', 'big', 'small', 'hairy', 'vanilla', 'hard', 'soft', 'funny']
    @nouns = ['apple', 'lemon', 'fish', 'racoon', 'hobbit', 'tomato', 'chair', 'man', 'drone']
    @generate = () ->
        adj = @adjectives[Math.floor(Math.random() * @adjectives.length)]
        noun = @nouns[Math.floor(Math.random() * @nouns.length)]
        "#{adj} #{noun}"

window.NameGenerator = NameGenerator