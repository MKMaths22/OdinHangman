class Game
    def initialize
        'empty method for now'
    end

    def find_random_word
        dictionary = File.open('edited_word_list.txt', 'r')
        dictionary.readlines.sample.chomp
    end



end

this_game = Game.new
puts this_game.find_random_word