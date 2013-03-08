require 'benchmark'
require './lib/board'
require './lib/dictionary_trie'
require './lib/simple_stats'

wordTrie = DictionaryTrie.loadTrie

min_board_size = 3
max_board_size = 5
num_iterations = 10

(min_board_size..max_board_size).each do |board_size|
  word_count = []
  word_lengths = []
  runtimes = []
  (1..num_iterations).each do |i|
    runtimes << Benchmark.realtime { 
	  b = Board.new(Board.random_board(board_size, board_size,0), wordTrie)
	  words = b.find_all_words_with_paths.keys
	  word_count << words.length
	  word_lengths << words.max { |a,b| a.length <=> b.length }.length
    }
  end
  
  puts "--> For #{board_size}-by-#{board_size} boards (#{num_iterations} iterations):"
  puts SimpleStats::pretty_stats(word_count, "word counts")
  puts SimpleStats::pretty_stats(word_lengths, "word lengths")
  puts SimpleStats::pretty_stats(runtimes, "runtimes")
end
