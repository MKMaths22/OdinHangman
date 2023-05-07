require 'yaml'

class Game
    
    attr_accessor :guesses_remaining, :all_guessed_letters, :incorrect_guessed_letters, :state_of_word, :secret_word, :player_name, :game_saved, :solved, :failed
    
    ALPHA_REGEX = /^[A-Z]$/
    REGEX_ERROR = "Not accepted. Please enter one letter from the alphabet."
    DUP_ERROR = "You've already guessed that letter. Please choose another."
    MAX_GUESSES = 7
    
    def initialize(name = nil)
        @guesses_remaining = MAX_GUESSES
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
        puts "Game saved."
        self.game_saved = true
        saved_game_as_yaml = YAML::dump(self)
        Dir.mkdir("#{player_name}") unless Dir.exists?("#{player_name}")
        file_for_saving = File.new("#{player_name}/saved_game.txt", 'w')
        file_for_saving.puts saved_game_as_yaml
        file_for_saving.close
    end

    def load_game
        file_for_loading = File.open('gamesavedhere.txt', 'r')
        yaml_string = file_for_loading.read
        File.delete(file_for_loading)
        loaded_game = YAML::unsafe_load(yaml_string)
        self.player_name = loaded_game.player_name
        self.all_guessed_letters = loaded_game.all_guessed_letters
        self.guesses_remaining = loaded_game.guesses_remaining
        self.incorrect_guessed_letters = loaded_game.incorrect_guessed_letters
        self.state_of_word = loaded_game.state_of_word
        self.secret_word = loaded_game.secret_word
        self.game_saved = loaded_game.game_saved
        self.solved = loaded_game.solved
        self.failed = loaded_game.failed
        display_score
        play_hangman(self)
    end

    def start_the_game
        self.secret_word = find_random_word
        size = @secret_word.length
        puts "What is your name?" unless @player_name
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
        letter_wow = "Well done, the letter #{letter} appears #{plural_times(num)}"
        solved_wow = "The letter #{letter} fills the remaining #{plural_space(num)} and you have solved the word #{@secret_word}. Congratulations, #{@player_name}!"
        puts @state_of_word == @secret_word ? solved_wow : letter_wow
    end

    def plural_times(number)
        case number
          when 1 then 'once in the word.'
          when 2 then 'twice in the word!'
          else "#{number} times in the word!"
        end
    end

    def plural_space(number)
        number == 1 ? 'space' : "#{number} spaces"
    end

    def play_hangman(game) 
        game.start_the_game unless game.game_saved
          loop do 
            game.choose_save unless game.game_saved 
            # a reloaded game skips those first two parts because it is already saved
            game.make_a_guess
            break if game.solved || game.failed
            game.display_score
          end 
          game.choose_play_again
    end
      
    def choose_save
          puts "Would you like to save the game, #{player_name}?"
          puts 'Type Y to save or any other key to continue.'
          save_game if gets.strip.upcase == 'Y'
    end
          
    def make_a_guess     
      self.game_saved = false  
      letter_chosen = choose_a_letter
      self.all_guessed_letters.push(letter_chosen)
      number_of_hits = secret_word.count(letter_chosen)
      score_incorrect_guess(letter_chosen) if number_of_hits == 0
      self.failed = true if guesses_remaining == 0
      score_correct_guess(letter_chosen, number_of_hits) if number_of_hits > 0
      self.solved = true if state_of_word == secret_word
    end
          
    def display_score
      puts "So far the secret word looks like: #{state_of_word} \nand #{plural_guesses}"
      puts "You have #{guesses_remaining == 1 ? 'just one incorrect guess remaining!' : "#{guesses_remaining} incorrect guesses remaining"}" 
    end

    def plural_guesses
        case guesses_remaining
          when MAX_GUESSES then 'no incorrect guesses made (yet)!'
          when MAX_GUESSES - 1 then "one incorrect guess so far: #{incorrect_guessed_letters[0]}"
          else "incorrect guesses so far: #{incorrect_guessed_letters.join(', ')}"
        end
    end
      
    def choose_play_again
        sleep(2)
        puts "To play again, #{player_name}, press Y."
        play_hangman(Game.new(player_name)) if gets.upcase.strip == 'Y'
    end

end
  
puts "Welcome to Hangman! What is your name?"
name = gets.strip.upcase
# to implement a saved games regieme in which the player is asked at the start
# of the program for their name. If their name matches a directory of saved games,
# which has saved games in it already the program displays 'Hey there. I thought 
# I remembered you! You have saved games available in slots numbered {num_one,
# num_two ....}. Type one of those numbers to load that game, or anything else
# to start a new game'.
# Also when you save, it should automatically find the lowest numbered slot available
# in your folder, or make the new folder with your name on it.
# When loading a saved game, it should be deleted.

puts "Would you like to load a previously saved game? Type Y for yes, anything else to continue."
this_game = Game.new
if gets.strip.upcase == 'Y' 
    this_game.load_game
else this_game.play_hangman(this_game)
end