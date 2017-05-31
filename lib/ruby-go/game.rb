module RubyGo
  class Game 

    # This makes more sense to be in Board
    #
    LETTERS = ('a'..'z').to_a

    # Board does not need to be publicly exposed
    # Moves can be also a private attr_reader
    #
    attr_reader :board
    def initialize(board: 19)
      @board = Board.new(board)
      @moves = []
    end

    # The game does not need to be responsible for knowing how to serialize
    # and save itself.
    #
    def save(name="my_go_game")
      tree = SGF::Parser.new.parse(to_sgf)
      tree.save(name + '.sgf')
    end

    def to_sgf
      sgf = "(;GM[1]FF[4]CA[UTF-8]AP[jphager2]SZ[#{board.size}]PW[White]PB[Black]"

      @moves.each do |move|
        sgf << move[:stone].to_sgf
      end

      sgf << ')'
    end

    # Access @board through the getter method
    #
    def view 
      puts  @board.to_s
      puts  "   " + "_"*(@board.size * 2)
      print "   Prisoners || White: #{captures[:black]} |"
      puts  " Black: #{captures[:white]}"
      puts  "   " + "-"*(@board.size * 2)
    end

    def black(x, y)
      play(BlackStone.new(x,y))
    end

    def white(x, y)
      play(WhiteStone.new(x,y))
    end

    def black_pass
      pass(:black)
    end

    def white_pass
      pass(:white)
    end

    # This should be a private method OR change public api to use #play and 
    # #pass only (instead of #black, #white, #black_pass, #white_pass.
    #
    def pass(color)
      @moves << {stone: NullStone.new(color), captures: [], pass: true} 
    end

    def undo 
      move = @moves.pop
      @board.remove(move[:stone])
      move[:captures].each {|stone| @board.place(stone)}
    end

    # Passes do not need to be counted every time. Pass count can be stored
    # in the Game
    #
    def passes
      @moves.inject(0) {|total, move| move[:pass] ? total + 1 : 0}
    end 

    # This does not need to be calculated each time. Capture counts can be
    # stored in the Game
    #
    def captures
      @moves.each_with_object({black: 0, white: 0}) do |move, total|
        move[:captures].each do |capture|
          total[capture.color] += 1
        end
      end
    end 

    private

    def play(stone)
      @board.place(stone)
      @moves << {stone: stone, captures: [], pass: false}

      capture; suicide; ko
    end

    # The name of the method does not tell me what it does. #check_ko_rule
    # or something similar would be better
    #
    def ko 
      return if @moves.length < 2 or !@moves[-2][:captures] 

      captures = @moves[-2][:captures]
      stone = @moves.last[:stone]

      if captures == [stone]
        undo
        raise IllegalMove, 
          "You cannot capture the ko, play a ko threat first"
      end
    end

    # Same as comment above. #check_suicide_rule would be better.
    #
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

    # This name is confusing. #capture_stones or #remove_captured_stones
    def capture_group(stone)
      @board.group_of(stone).each {|stone| capture_stone(stone)}
    end

    def capture_stone(stone)
      @moves.last[:captures] << stone 
      @board.remove(stone)
    end

    public

    # This can inherit from StandardError
    #
    class IllegalMove < Exception
    end
  end
end
