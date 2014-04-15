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
