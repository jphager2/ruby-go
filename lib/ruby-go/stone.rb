module RubyGo
  class Stone

    attr_reader :color
    def initialize(x, y, color)
      @x, @y = x, y
      @color = color
    end

    # Stone doesn't need to know how to serialize itself.
    def to_sgf
      x = Game::LETTERS[@x]
      y = Game::LETTERS[@y]
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

        intersection.group(board, stones) if intersection.color == @color
      end

      stones
    end

    def to_coord
      [@x, @y]
    end

    def to_str
      Board::COLORS[@color] 
    end

    def to_s
      to_str
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
      @x, @y = nil, nil
      @color = color
    end
    
    def remove_from_board(board)
    end

    def to_sgf
      ";#{color.to_s[0].upcase}[]"
    end
  end
end
