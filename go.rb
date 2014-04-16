class Board
  Colors = {black: 'x', white: 'o', empty: '_'}

  attr_accessor :board
  def initialize(size)
    @board = []
    0.upto(size) do |y|
      row = []
      0.upto(size) do |x| 
        row << Stone.new(x, y) 
      end
      @board << row_ary
    end
  end

  def empty?
    true
  end

  def at(x, y)
    @board[y][x]
  end

  def place(stone)
    stone.place_on_board(self)
  end

  def to_str
    out = ""
    @board.each do |row|
      out << (row.collect {|stone| stone.to_s}).join(' ') << "\n"
    end

    out
  end

  def to_s 
    to_str
  end
end

class Game 

  attr_reader :board
  def initialize(board: 19)
    @board = Board.new(board)
  end

  def black(x, y)
    @board.place(BlackStone.new(x,y))
  end

  def white(x, y)
    @board.place(WhiteStone.new(x,y))
  end
end

class Stone

  attr_reader :color
  def initialize(x, y)
    @x = x
    @y = y
    @color = :empty
  end

  def place_on_board(board)
    board.board[@y][@x] = self
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

class BlackStone < Stone
  def initialize(x, y)
    super
    @color = :black
  end
end
