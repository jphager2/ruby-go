class Stone

  attr_reader :color
  def initialize(x, y)
    @x, @y = x, y
    @color = :none
  end

  def to_sgf
    x = Game::LETTERS[@x]
    y = Game::LETTERS[@y]
    ";#{color.to_s[0].upcase}[#{x+y}]"
  end

  def empty?
    @color == :empty
  end

  def place_on_board(board)
    unless board.at(@x, @y).empty? 
      raise Game::IllegalMove, 
        "You cannot place a stone on top of another stone."  
    end
    board.board[@y][@x] = self
  end

  def remove_from_board(board)
    board.board[@y][@x] = Liberty.new(*self.to_coord)
  end

  def liberties(board)
    board.around(self).select {|stone| stone.empty?} 
  end

  def group(board, stones = [])
    return stones if stones.any? {|stone| stone.eql?(self)} 
    stones << self

    board.around(self).each do |stone|
      if stone.color == @color
        stone.group(board, stones)
      end
    end

    stones
  end

  def to_coord
    [@x, @y]
  end

  def to_str
    Board::Colors[@color] 
  end

  def to_s
    to_str
  end

  def ==(other)
    (self.color == other.color) and (self.to_coord == other.to_coord)
  end
end

class Liberty < Stone 
  def initialize(x, y)
    super
    @color = :empty
  end

  def liberties(board)
    [self]
  end
end

class BlackStone < Stone
  def initialize(x, y)
    super
    @color = :black
  end
end

class WhiteStone < Stone
  def initialize(x, y)
    super
    @color = :white
  end
end

class NullStone < Stone 
  def initialize(*args)
    @x, @y = nil, nil
  end
  
  def remove_from_board(board)
  end

  def to_sfg
    ""
  end
end
