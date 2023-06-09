# frozen_string_literal: true

# This code reads and edits the google dictionary downloaded for the Hangman game

dic_file = File.new('edited_word_list.txt', 'w')
old_dic = File.open('google-10000-no-swears.txt', 'r')
old_dic.each do |word|
  dic_file.puts "#{word.strip}\n" if word.strip.length.between?(5, 12)
  # allows for the newline character at the end of each line, so the words chosen
  # have between 5 and 12 characters as required
  # even if original dictionary had trailing whitespace, the edited list will not
end
old_dic.close
dic_file.close
