class Board
  Colors = {black: 'x', white: 'o', empty: '_'}

  attr_accessor :board
  def initialize(size)
    @board = []
    size -= 1

    0.upto(size) do |y|
      row = []
      0.upto(size) do |x| 
        row << Liberty.new(x, y) 
      end
      @board << row
    end
  end

  def empty?
    !@board.flatten.any? do |s| 
      !s.empty?
    end
  end

  def at(x, y)
    @board[y][x]
  end

  def around(x, y = :y_not_given)
    x, y = x.to_coord if x.kind_of?(Stone)
    stones = [] 
    stones << at(x-1, y) unless x == 0 
    stones << at(x+1, y) unless x == (@board.length - 1) 
    stones << at(x, y-1) unless y == 0 
    stones << at(x, y+1) unless y == (@board.length - 1)
    stones
  end

  def remove(stone)
    stone.remove_from_board(self)
  end

  def place(stone)
    stone.place_on_board(self)
  end

  def liberties(stone)
    group_of(stone).inject(0) do |libs, stn|
      libs + stn.liberties(self).count
    end
  end

  def group_of(stone)
    stone.group(self)
  end

  def to_str
    out = ""
    if @board.length < 11
      out << "\s\s\s#{(0..@board.length - 1).to_a.join(' ')}\n" 
    else
      out                                << 
        "\s\s\s#{(0..10).to_a.join(' ')}" <<
        "#{(11..@board.length - 1).to_a.join('')}\n"
    end

    @board.each_with_index do |row, i|
      i = "\s#{i}" if i < 10
      out << "#{i}\s#{(row.collect {|stn| stn.to_s}).join(' ')}\n"
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
    @moves = []
  end

  def view 
    puts @board.to_s
  end

  def black(x, y)
    play(BlackStone.new(x,y))
  end

  def white(x, y)
    play(WhiteStone.new(x,y))
  end

  def pass
    @moves << {stone: NullStone.new(), captures: [], pass: true} 
  end

  def undo 
    move = @moves.pop
    @board.remove(move[:stone])
    move[:captures].each {|stone| @board.place(stone)}
  end

  def passes
    @moves.inject(0) {|total, move| move[:pass] ? total + 1 : 0}
  end 

  def captures
    @moves.each_with_object({black: 0, white: 0}) do |move, total|
      move[:captures].each do |capture|
        total[capture.color] += 1
      end
    end
  end 

  private
    def play(stone)
      @passes = 0
      @board.place(stone)
      @moves << {stone: stone, captures: [], pass: false}

      capture
      suicide
      ko
    end

    def ko 
      return if @moves.length < 2 or !@moves[-2][:captures] 

      captures = @moves[-2][:captures]
      stone = @moves.last[:stone]

      if captures.include?(stone) 
        raise IllegalMove, 
          "You cannot capture the ko, play a ko threat first"
      end
    end

    def suicide
      stone = @moves.last[:stone]
      unless @board.liberties(stone) > 0
        undo
        raise IllegalMove, "You cannot play a suicide."
      end
    end

    def capture
      stone = @moves.last[:stone]
      stones_around = @board.around(stone)

      captures = stones_around.select {|stn| @board.liberties(stn) == 0}

      captures.each {|stone| capture_group(stone)}
    end

    def capture_group(stone)
      @board.group_of(stone).each {|stone| capture_stone(stone)}
    end

    def capture_stone(stone)
      @moves.last[:captures] << stone 
      @board.remove(stone)
    end

  public

  class IllegalMove < Exception
  end
end

class Stone

  attr_reader :color
  def initialize(x, y)
    @x = x
    @y = y
    @color = :none
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
end


  
