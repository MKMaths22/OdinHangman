require 'yaml'

class Game
    
    attr_accessor :guesses_remaining, :all_guessed_letters, :incorrect_guessed_letters, :state_of_word, :secret_word, :player_name, :game_saved, :solved, :failed
    
    ALPHA_REGEX = /^[A-Z]$/
    REGEX_ERROR = "Not accepted. Please enter one letter from the alphabet."
    DUP_ERROR = "You've already guessed that letter. Please choose another."
    
    def initialize(name = nil)
        @guesses_remaining = 7
        @all_guessed_letters = []
        @incorrect_guessed_letters = []
        @state_of_word = ''
        @secret_word = ''
        @player_name = name
        @game_saved = false
        @solved = false
        @failed = false

    end

    def find_random_word
        dictionary = File.open('edited_word_list.txt', 'r')
        return dictionary.readlines.sample.upcase.chomp
        dictionary.close
    end

    def save_game
        puts "Game saved. This message is lying until saving actually works."
        self.game_saved = true
        saved_game_as_yaml = YAML::dump(self)
        file_for_saving = File.new('gamesavedhere.txt', 'w')
        file_for_saving.puts saved_game_as_yaml
        file_for_saving.close
    end

    def load_game
        file_for_loading = File.open('gamesavedhere.txt', 'r')
        yaml_string = file_for_loading.read
        file_for_loading.close
        YAML::load(yaml_string)
        play_hangman
    end

    def start_the_game
        self.secret_word = find_random_word
        size = @secret_word.length
        puts "Welcome to Hangman. What is your name?" unless @player_name
        self.player_name = gets.strip unless @player_name
        puts "The computer has chosen a secret word with #{size} letters. Can you solve it, #{@player_name}?"
        self.state_of_word = '------------'[0,size]
        puts "Secret word: #{@state_of_word}"
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

    def score_incorrect_guess(letter)
        self.guesses_remaining -= 1
        self.incorrect_guessed_letters.push(letter)
        letter_fail = "Hard luck, the letter #{letter} does not appear in the word."
        solved_fail = "The letter #{letter} does not appear, and that was your last mistake. You have lost the game, #{@player_name} - the word was #{@secret_word}."
        puts @guesses_remaining == 0 ? solved_fail : letter_fail
    end

    def score_correct_guess(letter, num)
        (0..secret_word.length - 1).each do |i|
            self.state_of_word[i] = secret_word[i] if secret_word[i] == letter
        end
        letter_wow = "Well done, the letter #{letter} appears #{plural_times(num)} in the word!"
        solved_wow = "The letter #{letter} fills the remaining #{plural_space(num)} and you have solved the word #{@secret_word}. Congratulations, #{@player_name}!"
        puts @state_of_word == @secret_word ? solved_wow : letter_wow
    end

    def plural_times(number)
        number == 1 ? 'once' : "#{number} times"
    end

    def plural_space(number)
        number == 1 ? 'space' : "#{number} spaces"
    end

    def play_hangman
        start_the_game
      
        loop do
          puts "Would you like to save the game, #{player_name}?" unless game_saved
          save, continue = false, false
          until save || continue
            puts 'Type Y to save or N to continue.'
            input = gets.strip.upcase
            save = true if input == 'Y'
            continue = true if input == 'N'
          end
          save_game if save
          self.game_saved = false  
          letter_chosen = choose_a_letter
          self.all_guessed_letters.push(letter_chosen)
          number_of_hits = secret_word.count(letter_chosen)
          score_incorrect_guess(letter_chosen) if number_of_hits == 0
          self.failed = true if guesses_remaining == 0
          score_correct_guess(letter_chosen, number_of_hits) if number_of_hits > 0
          self.solved = true if state_of_word == secret_word
          
          break if solved || failed
         
          puts "So far we have: #{state_of_word} \nand the incorrect #{incorrect_guessed_letters.size == 1 ? 'guess is' : 'guesses are'} #{incorrect_guessed_letters.join(', ')}"
          puts "You have #{guesses_remaining == 1 ? 'just one incorrect guess remaining!' : "#{guesses_remaining} incorrect guesses remaining"}" 
        end
      
        sleep(2)
      
        puts "To play again, #{player_name}, press Y."
        play_hangman(Game.new(player_name)) if gets.upcase.strip == 'Y'
      
    end

end
  
puts "Would you like to load a previously saved game? Type Y for yes, anything else to continue."
if gets.strip.upcase == 'Y' 
    Game.new.play_hangman
else Game.new.load_game
end