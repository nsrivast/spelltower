require './lib/board'
require './lib/dictionary_trie'

class PuzzleGame
  SCRABBLE_SCORING = { 'a'=>1, 'b'=>3, 'c'=>3, 'd'=>2, 'e'=>1, 'f'=>4, 'g'=>2, 'h'=>4, 'i'=>1, 'j'=>8, 'k'=>5, 'l'=>1, 'm'=>3, 'n'=>1, 'o'=>1, 'p'=>3, 'q'=>10, 'r'=>1, 's'=>1, 't'=>1, 'u'=>1, 'v'=>4, 'w'=>4, 'x'=>8, 'y'=>4, 'z'=>10 }
  MAX_MOVES = 200

  def initialize(cols, rows, rows_empty, word_trie, move_metric)
    @board = Board.new(Board.random_board(cols, rows, rows_empty), word_trie)
    @move_metric = move_metric
    @game_results = { score: 0, moves: 0 }
  end

  def play_game(verbose = false)
    while @board.is_alive? && @game_results[:moves] < MAX_MOVES
      best_move = find_best_move(@board.find_all_words_with_paths)
	  
      unless best_move.nil?
        display_move(best_move) if verbose
        @board.play_move(best_move[:path])
        @game_results[:score] += best_move[:score]
      end
      @game_results[:moves] += 1
      @board.add_row
    end
    display_final if verbose
    @game_results
  end  
    
  def display_move(move)
    @board.print_fancy(move[:path])
    pretty_path = move[:path].collect { |p| "#{p[0]}-#{p[1]}" } .join(",")
    puts "--> playing word #{move[:word]} with score #{move[:score]} and path #{pretty_path}"
  end
  
  def display_final
    @board.print_fancy
    lost = @game_results[:moves] < MAX_MOVES
    puts "#{lost ? "game over" : "move limit reached"}. score=#{@game_results[:score]}, moves=#{@game_results[:moves]}"
  end

  # -- MOVE EVALUATION    
  def find_best_move(moves)
    update_column_heights
    unless moves.keys.length == 0
      best_move = moves.max { |a,b| score_move(a) <=> score_move(b) }
      { path: best_move[0], word: best_move[1], score: score_move_official(best_move)}
    end
  end
  
  def update_column_heights
    @column_heights = @board.get_column_heights
	rshift = @column_heights[0..-2].each_with_index.collect { |h,i| h - @column_heights[i+1] } + [0]
    lshift = [0] + @column_heights[1..-1].each_with_index.collect { |h,i| h - @column_heights[i-1] }
    @column_heights_rel = @column_heights.each_with_index.collect{ |h,i| 2 * h + rshift[i] + lshift[i]}
  end

  def score_move(move)
    eval(@move_metric.collect { |key,val| "score_#{key}(move)*#{val}" }.join(" + "))
  end

  def score_move_official(move) # approximation to actual SpellTower scoring rule
    score_word_length(move)*score_word_scrabble(move)
  end
  
  # -- VARIOUS MOVE METRICS  
  def score_word_length(move)
    move[1].length
  end

  def score_word_scrabble(move)
    word_score = move[1].split('').inject(0) { |sum, letter| sum + SCRABBLE_SCORING[letter] }
  end
  
  def score_column_height(move)
    move[0].inject(0) { |sum, pathlet| sum + @column_heights[pathlet[0]] }
  end    
  
  def score_column_height_relative(move)    
    move[0].inject(0) { |sum, pathlet| sum + @column_heights_rel[pathlet[0]] }
  end

  def score_doordie(move)
    top_row = @board.get_rows - 1
    new_counts = Array.new(@column_heights)
    move[0].each { |pathlet| new_counts[pathlet[0]] -= 1 }
    alive = new_counts.inject(true) { |stillalive, count| stillalive && (count < top_row) }
    alive ? 1: 0
  end
end

class PuzzleGameLookahead < PuzzleGame
  def initialize(cols, rows, rows_empty, word_trie, move_metric, lookahead_depth, n_best)
    super(cols, rows, rows_empty, word_trie, move_metric)
    @lookahead_depth = lookahead_depth
    @n_best = n_best
  end
  
  def find_best_move(moves)
    best_moves = find_best_moves_ahead(moves, @n_best, @lookahead_depth)
  end

  def find_best_moves_ahead(moves, top=5, depth=1)
     # returns "top" best results after looking ahead "depth" moves. to be implemented
    return nil
  end
end