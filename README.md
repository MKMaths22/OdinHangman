# OdinHangman
Follows the TOP 'Hangman' assignment

Ruby Hangman Game

This project uses the MIT License.

I have resisted the urge to make a stick figure in this project and instead focused on the game mechanics and how saving/loading works. The saved games are purely 'continuation' saves, so it is not possible to play on more than once from the same point in a game. Each named player has their own folder for saving games, with unlimited save slots available. When you make a save the program detects if the current game was previously loaded from a save, in which case the game goes back into the same save slot again. Otherwise, the smallest numbered unused save slot is chosen to prevent overwriting a previous game.
I wasn't sure for a while whether to give the player an option to save just after they load a game, but decided I should do this because if you load a game, the program reminds you of the progress so far in terms of the secret word, guesses made and incorrect guesses remaining. This gives the player the chance to change their mind about resuming the game and do something else instead, either loading a different saved game or starting a new one instead.

Instructions:
In the same directory, place hangman.rb, this README and edited_word_list.txt. With Ruby installed and your UNIX machine/emulator looking in that directory, enter 'ruby hangman.rb'.

The game uses only words between 5 and 12 letters in length. To this end, I wrote the program dictionary.rb which chose all suitable words from the file google-10000-no-swears.txt to create edited_word_list.txt. I include the google list and dictionary.rb for completeness, these are not needed to play the game.
