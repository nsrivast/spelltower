class DictionaryTrie # adapted from http://en.wikipedia.org/wiki/Trie
  WORD_TRIE_PATH = 'data\wordTrie.trie'
  DICTIONARY_BLOCK = "A".upto("Z").collect { |letter| "data\\wordlists\\#{letter} words.txt" }

  def initialize(wordList)
    @root = Hash.new
    wordList.each { |word| build(word) }
  end
  
  def build(word)
    node = @root
    word.each_char do |letter|
      node[letter] ||= Hash.new
      node = node[letter]
    end
    node[:end] = true
  end

  def find(prefix, is_exact_word = false)
    node = @root
    prefix.each_char do |letter|
      return nil unless node = node[letter]
    end
    is_exact_word ? node[:end] : true
  end
  
  def self.loadTrie
    unless File.exists?(WORD_TRIE_PATH)
      dict = DICTIONARY_BLOCK.collect { |file| File.open(file).readlines }.flatten
      dict = dict.collect { |word| word.delete("\n") }
      wordTrie = DictionaryTrie.new(dict)
      Marshal.dump(wordTrie, File.new(WORD_TRIE_PATH,'w'))
    else
      wordTrie = Marshal.load(File.new(WORD_TRIE_PATH,'r'))
    end
    wordTrie
  end
end