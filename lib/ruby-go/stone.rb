module RubyGo
  class Stone
    LETTERS = ('a'..'z').to_a

    attr_reader :color, :x_coord, :y_coord

    def initialize(x_coord, y_coord, color)
      @x_coord = x_coord
      @y_coord = y_coord 
      @color = color
    end

    def to_sgf
      x = LETTERS[x_coord]
      y = LETTERS[y_coord]
      ";#{color.to_s[0].upcase}[#{x}#{y}]"
    end

    def empty?
      false
    end

    # The stone should not be responsible for knowing what is around it,
    #
    def group(board, stones = [])
      return stones if stones.include?(self)

      stones << self

      board.around(*to_coord).each do |intersection|
        next if intersection.empty?

        intersection.group(board, stones) if intersection.color == color
      end

      stones
    end

    def to_coord
      [x_coord, y_coord]
    end

    def to_s
      Board::COLORS[color] 
    end

    def ==(other)
      other.is_a?(Stone) &&
        (color == other.color) &&
        (to_coord == other.to_coord)
    end
  end

  # This can be changed to a Pass object
  class NullStone < Stone 
    def initialize(color = :empty)
      @x_coord = nil
      @y_coord = nil
      @color = color
    end
    
    def to_sgf
      ";#{color.to_s[0].upcase}[]"
    end
  end
end
