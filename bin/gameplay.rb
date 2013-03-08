require 'benchmark'
require './lib/puzzle'
require './lib/simple_stats'

wordTrie = DictionaryTrie.loadTrie

move_metrics = [
  {"column_height" => 1, "word_length" => 10},  
  {"column_height" => 1, "doordie" => 1000},
  {"column_height" => 1},
  {"column_height_relative" => 1, "word_length" => 10},  
  {"column_height_relative" => 1, "doordie" => 1000},
  {"column_height_relative" => 1}
]

n_cols = 7
n_rows = 12
empty_rows = n_cols
num_iterations = 10

move_metrics.each do |move_metric|
  scores = []
  moves = []
  runtimes = []

  (1..num_iterations).each do |i|
    runtimes << Benchmark.realtime { 
	  g = PuzzleGame.new(n_cols, n_rows, empty_rows, wordTrie, move_metric)
      results = g.play_game
      scores << results[:score]
      moves << results[:moves]
	}
  end

  puts "-->" + move_metric.collect { |metric,weight| "#{metric}*#{weight}" }.join(" + ")
  puts SimpleStats::pretty_stats(scores, "score") 
  puts SimpleStats::pretty_stats(moves, "moves")
  puts SimpleStats::pretty_stats(runtimes, "runtimes") 
end