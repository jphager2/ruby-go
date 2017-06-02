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

    # The stone should not be responsible for placing itself on the board,
    # or for raising exceptions for illegal state.
    #
    def place_on_board(board)
      unless board.at(@x, @y).empty? 
        raise Game::IllegalMove, 
          "You cannot place a stone on top of another stone."  
      end
      board.board[@y][@x] = self
    end

    # The stone should not be responsible for removing itself on the board
    #
    def remove_from_board(board)
      board.board[@y][@x] = Liberty.new(*self.to_coord)
    end

    # The stone should not be responsible for knowing what is around it,
    #
    def liberties(board)
      board.around(self).select {|stone| stone.empty?} 
    end

    # The stone should not be responsible for knowing what is around it,
    #
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
