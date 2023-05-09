require 'yaml'

class Game
    
    attr_accessor :guesses_remaining, :all_guessed_letters, :incorrect_guessed_letters, :state_of_word, :secret_word, :player_name, :game_saved, :solved, :failed, :saved, :save_slot, :reloaded
    
    ALPHA_REGEX = /^[A-Z]$/
    REGEX_ERROR = "Not accepted. Please enter one letter from the alphabet."
    DUP_ERROR = "You've already guessed that letter. Please choose another."
    MAX_GUESSES = 7
    
    def initialize(name)
        @guesses_remaining = MAX_GUESSES
        @all_guessed_letters = []
        @incorrect_guessed_letters = []
        @state_of_word = ''
        @secret_word = ''
        @player_name = name
        @solved = false
        @failed = false
        @saved = false
        @save_slot = nil
        @reloaded = false
        # when the game is saved, it's save_slot is stored as a positive integer
        # when resumed, the game, if saved again, is saved back to the same slot
    end

    def choose_reload(name)
        Dir.chdir(name)
        slots_used = Dir["./*"].map { |string| string[2..-5]}
        # removes "./" and ".txt" and outputs array of numbers as strings only
        game_or_games = slots_used.size > 1 ? "saved games" : "a saved game"
        puts "I have found #{game_or_games} of yours, numbered as follows:"
        puts slots_used.join(', ') << '.'
        puts "To resume a game, enter its number. Press anything else to start a new game."
        input = gets.strip
        Dir.chdir("..")
        slots_used.include?(input) ? load_game(name, input) : play_hangman
    end
    
    def find_random_word
        dictionary = File.open('edited_word_list.txt', 'r')
        return dictionary.readlines.sample.upcase.chomp
        dictionary.close
    end

    def save_game
        saved_game_as_yaml = YAML::dump(self)
        Dir.mkdir("#{player_name}") unless Dir.exists?("#{player_name}")
        # if game was previously saved and resumed it uses the same slot again
        
          if save_slot
            saved_game_as_yaml = YAML::dump(self)
            file_for_saving = File.new("#{player_name}/#{save_slot.to_s}.txt", 'w')
            puts "Game saved in your named folder, back into slot #{save_slot.to_s}"
          else 
            # needs to check for indices of games already saved and use
            # the smallest positive integer value that doesn't alreay exist
            i = 1
            i += 1 while File.exists?("#{player_name}/#{i.to_s}.txt")
            self.save_slot = i
            saved_game_as_yaml = YAML::dump(self)
            file_for_saving = File.new("#{player_name}/#{i.to_s}.txt", 'w')
            puts "Game saved in your named folder, in slot #{i.to_s}."
          end 
        
        file_for_saving.puts saved_game_as_yaml
        file_for_saving.close
        self.saved = true
        # this will stop play_hangman from continuing to execute its 'do' loop
        # but does not affect the game that will be reloaded
    end
    
    def find_if_saves_exist(name)
      Dir.exists?(name) && !Dir.empty?(name) ? choose_reload(name) : play_hangman
    end 
    
    def load_game(player_name, number_string)
        file_for_loading = File.open("#{player_name}/#{number_string}.txt", 'r')
        yaml_string = file_for_loading.read
        File.delete(file_for_loading)
        loaded_game = YAML::unsafe_load(yaml_string)
        self.player_name = loaded_game.player_name
        self.all_guessed_letters = loaded_game.all_guessed_letters
        self.guesses_remaining = loaded_game.guesses_remaining
        self.incorrect_guessed_letters = loaded_game.incorrect_guessed_letters
        self.state_of_word = loaded_game.state_of_word
        self.secret_word = loaded_game.secret_word
        self.solved = loaded_game.solved
        self.failed = loaded_game.failed
        self.save_slot = loaded_game.save_slot
        self.saved = loaded_game.saved
        self.reloaded = true
        # extra variable reloaded prevents a new game from being started by play_hangman
        display_score
        play_hangman
    end

    def start_the_game
        self.guesses_remaining = MAX_GUESSES
        self.all_guessed_letters = []
        self.incorrect_guessed_letters = []
        self.solved = false
        self.failed = false
        self.saved = false
        self.save_slot = nil
        self.secret_word = find_random_word
        size = @secret_word.length
        puts "\n-------NEW GAME-------\nThe computer has chosen a secret word with #{size} letters. Can you solve it, #{@player_name}?"
        self.state_of_word = '------------'[0,size]
        puts "Secret word: #{@state_of_word}"
    end
    
    def choose_a_letter
        puts "#{@player_name}, pick a letter you think might be in the word."
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
        solved_fail = "The letter #{letter} does not appear, and that was your last mistake. You have lost the game, #{@player_name} - the word was #{@secret_word}.\n\n"
        puts @guesses_remaining == 0 ? solved_fail : letter_fail
    end

    def play_again(name)
        "Would you like to start another game, #{name}?\n
        Press Y to play again, or anything else to stop."
        gets.strip.upcase == 'Y' ? find_if_saves_exist(name) : bye(name)
    end 
    
    def score_correct_guess(letter, num)
        (0..secret_word.length - 1).each do |i|
            self.state_of_word[i] = secret_word[i] if secret_word[i] == letter
        end
        letter_wow = "Well done, the letter #{letter} appears #{plural_times(num)}"
        solved_wow = "The letter #{letter} fills the remaining #{plural_space(num)} and you have solved the word #{@secret_word}. Congratulations, #{@player_name}!\n\n"
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

    def bye(name)
        puts "Goodbye #{name}, and thanks for playing Hangman!\n--------------------"
    end 

    def play_hangman 
        start_the_game unless reloaded
        # so that reloaded games don't choose a new secret word but enter the do loop
        self.reloaded = false
          loop do 
            choose_save
            break if saved
            make_a_guess
            break if solved || failed
            display_score
            self.saved = false
          end
          play_again(player_name)
    end
      
    def choose_save
          puts "Would you like to save the game, #{player_name}?"
          puts 'Type Y to save or anything else to continue.'
          save_game if gets.strip.upcase == 'Y'
    end
          
    def make_a_guess
      letter_chosen = choose_a_letter
      self.all_guessed_letters.push(letter_chosen)
      number_of_hits = secret_word.count(letter_chosen)
      score_incorrect_guess(letter_chosen) if number_of_hits == 0
      self.failed = true if guesses_remaining == 0
      score_correct_guess(letter_chosen, number_of_hits) if number_of_hits > 0
      self.solved = true if state_of_word == secret_word
    end
          
    def display_score
      puts "Your knowledge of the secret word so far is: #{state_of_word} \nand #{plural_guesses}"
      puts "You have #{guesses_remaining == 1 ? 'just one incorrect guess remaining!' : "#{guesses_remaining} incorrect guesses remaining"}" 
    end

    def plural_guesses
        case guesses_remaining
          when MAX_GUESSES then 'no incorrect guesses made (yet)!'
          when MAX_GUESSES - 1 then "just one incorrect guess made: #{incorrect_guessed_letters[0]}"
          else "incorrect guesses made: #{incorrect_guessed_letters.join(', ')}"
        end
    end

end
  
puts "Welcome to Hangman! What is your name?"
name = gets.strip
game = Game.new(name)
puts "Nice to see you again, #{name}!" if Dir.exists?(name)
game.find_if_saves_exist(name)

# to implement a saved games regieme in which the player is asked at the start
# of the program for their name. If their name matches a directory of saved games,
# which has  games in it already the program displays 'Hey there. I thought 
# I remembered you! You have saved games available in slots numbered {num_one,
# num_two ....}. Type one of those numbers to load that game, or anything else
# to start a new game'.
# Also when you save, it should automatically find the lowest numbered slot available
# in your folder, or make the new folder with your name on it.
# When loading a saved game, it should be deleted.
