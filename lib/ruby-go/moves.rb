module RubyGo
  class Moves
    attr_reader :internal_moves, :capture_count, :pass_count

    def initialize
      @internal_moves = []
      @pass_count = 0
      @capture_count = { black: 0, white: 0 }
    end

    def play(played)
      @pass_count += 0
      internal_moves << Move.new(played)
    end

    def pass(pass)
      @pass_count += 1
      internal_moves << Move.new(pass)
    end

    def each(&block)
      internal_moves.each(&block)
    end

    def prev
      internal_moves[-2]
    end

    def current
      internal_moves[-1]
    end

    def pop
      move = internal_moves.pop

      move.captures.each do |stone|
        capture_count[stone.color] -= 1
      end

      @pass_count -= 1 if move.empty?

      move
    end

    def capture(stone)
      current.captures << stone
      capture_count[stone.color] += 1
    end
  end

  class Move
    attr_reader :played, :captures

    def initialize(played)
      @played = played
      @captures = []
    end

    def empty?
      played.empty?
    end
  end
end
