class Game
    
    attr_accessor :guesses_remaining, :all_guessed_letters, :incorrect_guessed_letters, :state_of_word, :secret_word, :player_name
    
    ALPHA_REGEX = /^[A-Z]$/
    REGEX_ERROR = "Not accepted. Please enter one letter from the alphabet."
    DUP_ERROR = "You've already guessed that letter. Please choose another."
    
    def initialize
        @guesses_remaining = 7
        @all_guessed_letters = []
        @incorrect_guessed_letters = []
        @state_of_word = ''
        @secret_word = ''
        @player_name = ''

    end

    def find_random_word
        dictionary = File.open('edited_word_list.txt', 'r')
        return dictionary.readlines.sample.upcase.chomp
        dictionary.close
    end

    def save_game
        # flesh this out later
    end

    def load_game
        # to be done later
    end
    
    def start_the_game
        self.secret_word = find_random_word
        size = @secret_word.length
        puts "Welcome to Hangman. What is your name?"
        self.player_name = gets.strip
        puts "The computer has chosen a secret word with #{size} letters. Can you solve it, #{@player_name}?"
        self.state_of_word = '------------'[0,size]
        puts @state_of_word
    end
    
    def choose_a_letter
        puts "#{@player_name}, pick a letter you think might be in the word. You have #{@guesses_remaining} incorrect guesses remaining."
          valid = 0
          until valid == 2
            valid = 0
            input = gets.upcase.strip 
            input.match(ALPHA_REGEX) ? valid += 1 : (puts REGEX_ERROR)
            @all_guessed_letters.include?(input) ? (puts DUP_ERROR) : valid += 1
          end
        input 
    end

    def score_incorrect_guess
        self.guesses_remaining -= 1
        puts "Hard luck, that letter does not appear in the word."
    end

end

this_game = Game.new
this_game.start_the_game

while this_game.guesses_remaining > 0
    puts "Would you like to save the game, #{this_game.player_name}?"
    save, continue = false, false
    until save || continue
      puts 'Type Y to save or N to continue.'
      save, continue = false, false
      input = gets.strip.upcase
      save = true if input == 'Y'
      continue = true if input == 'N'
    end
    break if save  
    this_game.choose_a_letter
    this_game.score_incorrect_guess
end



# end