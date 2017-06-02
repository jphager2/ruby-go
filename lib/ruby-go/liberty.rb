module RubyGo
  # Good point made that separate classes for BlackStone and WhiteStone
  # (etc) will potentially make the code harder to maintain.
  #
  class Liberty
    attr_reader :color
    def initialize(x, y)
      @x = x
      @y = y
      @color = :empty
    end

    def liberties(board)
      [self]
    end

    def empty?
      true
    end

    def group(board, stones = [])
      return stones if stones.any? {|stone| stone.eql?(self)} 
      stones << self

      board.around(self).each do |stone|
        if stone.empty?
          stone.group(board, stones)
        end
      end

      stones
    end

    def to_s
      Board::Colors[:empty] 
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

    def remove_from_board(board)
      #no-op
    end

    def to_coord
      [@x, @y]
    end

    def ==(other)
      other.empty? && (self.to_coord == other.to_coord)
    end
  end
end
