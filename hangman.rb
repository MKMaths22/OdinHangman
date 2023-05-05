class Game
    
    attr_accessor :guesses_remaining, :all_guessed_letters, :incorrect_guessed_letters, :state_of_word, :secret_word, :player_name
    
    ALPHA_REGEX = /^[A-Z]$/
    
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
        valid = false
          until valid
            inputted = gets.upcase.strip 
            if inputted.match(ALPHA_REGEX)
              if @all_guessed_letters.include?(inputted)
                puts "You've already guessed that letter. Please choose another."
              else
                valid = true
              end
            else puts "Not accepted. Please enter one letter from the alphabet."
            end
          end
    end

end

this_game = Game.new
this_game.start_the_game
puts this_game.secret_word
this_game.choose_a_letter
# while this_game.guesses_remaining > 0
    # give player option to save the game
    # 


# end