class GoBoard 
  Color = {black: "x", white: "o", empty: "-"}

  def initialize(size)
    @board = []
    (1..size).each_with_object(@board) do |row_num, board| 
      board << (1..size).each_with_object([]) do |col_num, row| 
        row << Stone.new(col_num, row_num)
      end
    end
  end

  def to_str
    board = ""
    @board.each {|row| board << row.join(" ") << "\n"}
    return board
  end

  def to_s 
    to_str 
  end

  def to_ary
    @board
  end

  def to_a 
    to_ary 
  end

  def at(x, y)
    @board[y][x]
  end

  def stones_around(x, y)
    stones = [] 
    stones << @board[y][x-1] unless x == 0
    stones << @board[y][x+1] unless x == @board.length - 1
    stones << @board[y-1][x] unless y == 0
    stones << @board[y+1][x] unless y == @board.length - 1
    stones
  end

  def place_stone(stone)
    stone.place_on_board(self)
  end

  def liberties(stone)
    group = stone_group_for(stone)

    group.each_with_object([]) do |stone, libs| 
      libs << stone.liberties(self)
    end.flatten.uniq.count
  end

  def stone_group_for(stone)
    stone.group(self)
  end
end

class Stone

  attr_reader :color, :always_placable

  def initialize(x, y)
    @x = x
    @y = y
    @color = :empty 
    @always_placable = true
  end

  def ==(other)
    self.class == other.class and self.color == other.color
  end

  def to_cord 
    [@x, @y]
  end

  def to_str
    GoBoard::Color[@color]
  end

  def to_s 
    to_str 
  end

  def place_on_board(board)
    unless board.to_a[@y][@x].always_placable or @always_placable
      raise PlacementError 
    end
    board.to_a[@y][@x] = self
  end

  def group(board, group = [])
    return [self] if @color == :empty 

    stones_around = board.stones_around(*self.to_cord)

    group << self
    stones_around.each do |stone|

      if stone.color == self.color
        unless group.any? {|s| s.object_id == stone.object_id}
          group += stone.group(board, group)
        end
      end
    end

    group.flatten.uniq
  end

  def liberties(board)
    return [self] if @color == :empty 
     
    board.stones_around(*self.to_cord).each_with_object([]) do |s, libs| 
      libs << s if s.color == :empty 
    end 
  end

  class PlacementError < Exception
  end
end

class BlackStone < Stone 

  def initialize(x, y)
    super
    @color = :black
    @always_placable = false
  end
end

class WhiteStone < Stone 

  def initialize(x, y)
    super
    @color = :white
    @always_placable = false
  end
end


class GoGame 

  attr_reader :board

  def initialize(options)
    @board = GoBoard.new(options[:board])
    @moves = [] 
  end

  def place_white_stone(x, y)
    place_stone(WhiteStone.new(x,y))
  end

  def place_black_stone(x, y)
    place_stone(BlackStone.new(x,y))
  end

  def print_board
    puts @board.to_s
  end

  def captures 
    @moves.inject(0) do 
      |total, move| total + (move[:captures] || []).length
    end
  end
  
  def undo
    captures = @moves.last[:captures]
    stone = @moves.last[:stone]

    captures.each do |stone|
      @board.place_stone(stone)
    end
    @board.place_stone(Stone.new(*stone.to_cord))
    @moves.pop

    print_board
  end

  private
    def place_stone(stone)
      bad_cord = stone.to_cord.any? do |cord| 
        cord < 0 or cord > @board.to_a.length 
      end

      if bad_cord
        raise ArgumentError, 
          "Coordinates need to be between 0..#{@board.to_a.length}" 
      end

      @moves << {stone: stone, captures: []}
      @board.place_stone(stone) 
      check_capture
      check_illegal_move

      print_board
    end

    def check_illegal_move
      last_stone = @moves.last[:stone]

      unless @board.liberties(last_stone) > 0
        undo
        raise IllegalMove
      end
    end

    def check_capture
      last_stone = @moves.last[:stone] 
      
      @board.stones_around(*last_stone.to_cord).each do |stone|
        capture_group(stone) if board.liberties(stone) == 0
      end
    end

    def capture_group(stone)
      @board.stone_group_for(stone).each do |stone|
        capture(stone)
      end
    end

    def capture(stone)
      (@moves.last[:captures] ||= []) << stone 
      x, y = stone.to_cord
      @board.place_stone(Stone.new(x, y))
    end
  
  public

  class IllegalMove < Exception
  end
end

