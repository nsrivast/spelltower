[SpellTower] (http://www.spelltower.com) is a fun and addictive word game, a combination of tetris and boggle. This repo contains code that I used to explore the strategy of spelltower by building a solver and testing it with a variety of word-choice metrics.

Notes:
* this strategy is relevant for the "Puzzle" mode of SpellTower, where a new row is generated each time a word is played
* we do not destroy nearby letters for large enough words, in practice this would make the game too easy with a perfect word search
* the full 7x12  board can take 10-20 seconds to run for intelligent strategies, this is a function of a large number of moves and a non-trivial word search time
* for a good visualization of the gameplay, run
    Puzzle.play_game(verbose = true)
 
Executables:
* \bin\word_search.rb returns statistics and benchmarking for the full word search described in \lib\board.rb
* \bin\gameplay.rb evaluates different word-choice metrics and returns their performance in simulated puzzle games

Questions for further research:
* how valuable is a look-ahead feature? (build out PuzzleGameLookahead class)
* what letters are most and least valuable in this game? (tweak letter frequencies used to regenerate board, see how it impacts average score)