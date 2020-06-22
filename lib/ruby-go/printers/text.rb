module RubyGo
  class TextPrinter
    COLORS = { black: 'x', white: 'o', empty: '_' }.freeze

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def print_game(game)
      print_board(game.board)
      io.puts  "   " + "_"*(game.board.size * 2)
      io.print "   Prisoners || White: #{game.captures[:black]} |"
      io.puts  " Black: #{game.captures[:white]}"
      io.puts  "   " + "-"*(game.board.size * 2)
    end

    private

    def print_board(board)
      if board.size < 11
        io.puts "   #{(0..board.size - 1).to_a.join(' ')}"
      else
        io.puts "   #{(0..10).to_a.join(' ')}#{(11..board.size - 1).to_a.join('')}"
      end

      board.rows.each_with_index do |row, i|
        i = " #{i}" if i < 10
        io.print "#{i} "
        row.each { |stn| print_stone(stn) }
        io.puts
      end
    end

    def print_stone(stone)
      io.print "#{COLORS[stone.color]} "
    end
  end
end
