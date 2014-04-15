class GoGame 

  attr_reader :board, :pass

  def initialize(options)
    @board = GoBoard.new(options[:board])
    @pass = 0
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

  def pass_turn
    @pass += 1
    print_board
  end

  def captures 
    @moves.each_with_object({black: 0, white: 0}) do |move, total| 
      move[:captures].each {|stone| total[stone.color] += 1}
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

      @pass = 0
      @moves << {stone: stone, captures: []}
      @board.place_stone(stone) 
      check_capture
      check_illegal_move

      print_board

      return :stone_placed
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

