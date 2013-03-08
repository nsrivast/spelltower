class Board
  LETTER_FREQUENCIES = { 'a'=>0.082, 'b'=>0.015, 'c'=>0.028, 'd'=>0.043, 'e'=>0.127, 'f'=>0.022, 'g'=>0.02, 'h'=>0.061, 'i'=>0.07, 'j'=>0.002, 'k'=>0.008, 'l'=>0.04, 'm'=>0.024, 'n'=>0.067, 'o'=>0.075, 'p'=>0.019, 'q'=>0.001, 'r'=>0.06, 's'=>0.063, 't'=>0.091, 'u'=>0.028, 'v'=>0.01, 'w'=>0.024, 'x'=>0.002, 'y'=>0.02, 'z'=>0.001 }
  MIN_WORD_LENGTH = 3

  # The matrix of characters on a board is an array of arrays:
  # [[0_0, 0_1, ...], [1_0, 1_1, ...], ...]
  # where X_Y is the character in column X and row Y.
  # Blank cells are represented by an underscore (_).

  def initialize(letters, words)
    @letter_matrix = letters
    @cols = @letter_matrix.length
    @rows = @letter_matrix[0].length
    @word_trie = words
  end
  
  def get_rows
    @rows
  end
  
  def get_column_heights
    @letter_matrix.collect { |col| @rows - col.count('_') }
  end
  
  def is_alive?
    @letter_matrix.inject(true) { |still_alive,col| still_alive && (col[-1] == '_') }
  end

  # -----
  # WORD-FINDING
  # -----
  def find_all_words_with_paths
    found = {}
    @letter_matrix.each_with_index do |col,colnum|
      col.each_with_index do |letter,rownum|
        found = found.merge(depth_first_search( letter, [[colnum, rownum]] ))
      end
    end
    found
  end

  def depth_first_search(stub, path)
    found = {}
    found[path] = stub if (stub.length >= MIN_WORD_LENGTH && @word_trie.find(stub, true))
    
    if @word_trie.find(stub)
      adjacent_cells_not_visited(path).each do |cell|
        new_stub = stub + @letter_matrix[cell[0]][cell[1]]
        new_path = path + [cell]
        found = found.merge(depth_first_search(new_stub, new_path))
      end
    end
    found
  end

  def adjacent_cells_not_visited(path)
    x = path[-1][0]
    y = path[-1][1]
    [[x-1,y-1],[x-1,y],[x-1,y+1],[x,y-1],[x,y+1],[x+1,y-1],[x+1,y],[x+1,y+1]] .reject do |move| 
      path.include?(move) || out_of_bounds?(move)
    end
  end

  def out_of_bounds?(move)
    move[0] < 0 || move[1] < 0 || move[0] >= @cols || move[1] >= @rows
  end

  # -----
  # BOARD UPDATING
  # -----
  def play_move(path, destroy_nearby=false)
    if destroy_nearby
      path = path.collect { |pathlet| adjacent_cells_not_visited([pathlet]) }.flatten(1).uniq
    end
    
    letters = Array.new(@letter_matrix)
    path.each { |pathlet| letters[pathlet[0]][pathlet[1]] = "del" }
    letters = letters.collect { |col| col.reject { |char| char === "del" } }
    @letter_matrix = letters.collect { |col| col + ["_"]*(@rows-col.length) }
  end
  
  def add_row
    letters = Array.new(@letter_matrix)
	new_row = Board.random_letters(@cols)
    @letter_matrix = letters.each_with_index.collect { |col,i| [new_row[i]] + col[0..-2] }
  end
  
  # -----
  # OTHER
  # -----
  def self.random_letters(n)
    random_letters = LETTER_FREQUENCIES.inject([]) { |memo, (letter,freq)| memo + [letter] * (freq * 1000).floor }.shuffle  
    random_letters.pop(n)
  end

  def self.random_board(cols, rows, rows_empty = 0)
    random_letters = LETTER_FREQUENCIES.inject([]) { |memo, (letter,freq)| memo + [letter] * (freq * 1000).floor }.shuffle  
    (1..cols).collect { |i| random_letters.pop(rows-rows_empty) + ['_'] * rows_empty }  
  end
  
  def print_fancy(path = [])
    header_footer = "_" * (2 * @cols + 3) + "\n\n"
    puts header_footer
    (1..@rows).each_with_index do |row,row_num|
      row_array = @letter_matrix.each_with_index.collect do |col,col_num| 
        path.include?([col_num, @rows - row_num - 1]) ? col[@rows - row] : col[@rows - row].upcase
      end
      puts "| " + row_array.join(" ") + " |"
    end
    puts header_footer
  end
end
