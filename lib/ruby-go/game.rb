module RubyGo
  class Game
    attr_reader :board, :moves

    def initialize(board: 19)
      @board = Board.new(board)
      @moves = Moves.new
    end

    private :moves

    def save(name="my_go_game")
      tree = SGF::Parser.new.parse(to_sgf)
      tree.save(name + '.sgf')
    end

    def to_sgf
      sgf = "(;GM[1]FF[4]CA[UTF-8]AP[jphager2]SZ[#{board.size}]PW[White]PB[Black]"

      moves.each do |move|
        sgf << move.played.to_sgf
      end

      sgf << ')'
    end

    def place_black(x, y)
      play(Stone.new(x, y, :black))
    end

    def place_white(x, y)
      play(Stone.new(x, y, :white))
    end

    def black_pass
      pass(:black)
    end

    def white_pass
      pass(:white)
    end

    def undo
      move = moves.pop

      board.remove(move.played)
      move.captures.each do |stone|
        board.place(stone)
      end
    end

    def passes
      moves.pass_count
    end

    def captures
      moves.capture_count
    end

    private

    def pass(color)
      moves.pass(NullStone.new(color))
    end

    def play(stone)
      check_illegal_placement!(stone)

      board.place(stone)
      moves.play(stone)
      record_captures!(stone)

      check_illegal_suicide!(stone)
      check_illegal_ko!(stone)
    end

    def check_illegal_placement!(stone)
      coord = stone.to_coord

      if coord.any? { |i| i < 0 || i >= board.size }
        raise(
          Game::IllegalMove,
          "You cannot place a stone off the board."
        )
      end

      intersection = board.at(*coord)

      unless intersection.empty?
        raise(
          Game::IllegalMove,
          "You cannot place a stone on top of another stone."
        )
      end
    end

    def check_illegal_ko!(stone)
      last_move = moves.prev

      return unless last_move

      if last_move.captures == [stone] && moves.current.captures.one?
        undo
        raise IllegalMove,
          "You cannot capture the ko, play a ko threat first"
      end
    end

    def check_illegal_suicide!(stone)
      if board.liberties(stone).zero?
        undo
        raise IllegalMove, "You cannot play a suicide."
      end
    end

    def record_captures!(stone)
      stones_around = board.around(*stone.to_coord).reject(&:empty?)

      captures = stones_around
                   .reject {| stn| stn.color == stone.color }
                   .select { |stn| @board.liberties(stn).zero? }

      captures.map {|stone| @board.group_of(stone)}
        .flatten.uniq.each {|stone| capture_stone(stone)}
    end

    def capture_stone(stone)
      moves.capture(stone)
      board.remove(stone)
    end

    class IllegalMove < StandardError
    end
  end
end
