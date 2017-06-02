module RubyGo
  class Board
    Colors = {black: 'x', white: 'o', empty: '_'}

    # rename board to internal_board, and make it private
    attr_accessor :board
    def initialize(size)
      @board = Array.new(size) { Array.new(size) { Liberty.new } }
    end

    def size
      @board.length
    end

    # use all?
    #
    def empty?
      !@board.flatten.any? do |s| 
        !s.empty?
      end
    end

    def at(x, y)
      @board[y][x]
    end

    def around(x, y)
      intersections = [] 

      intersections << at(x-1, y) unless x == 0 
      intersections << at(x+1, y) unless x == (board.length - 1) 
      intersections << at(x, y-1) unless y == 0 
      intersections << at(x, y+1) unless y == (board.length - 1)
      intersections
    end

    def remove(stone)
      x, y = stone.to_coord

      board[y][x] = Liberty.new
    end

    # Board shouldn't care about game rules
    def place(stone)
      x, y = stone.to_coord

      unless at(x, y).empty? 
        raise(
          Game::IllegalMove, 
          "You cannot place a stone on top of another stone."  
        )
      end

      board[y][x] = stone
    end

    def liberties(stone)
      libs = []

      group_of(stone).each do |stn|
        libs += around(*stn.to_coord).select(&:empty?)
      end

      libs.uniq.length
    end

    def group_of(stone)
      stone.group(self)
    end

    def to_str
      out = ""
      if @board.length < 11
        out << "\s\s\s#{(0..@board.length - 1).to_a.join(' ')}\n" 
      else
        out                                << 
          "\s\s\s#{(0..10).to_a.join(' ')}" <<
          "#{(11..@board.length - 1).to_a.join('')}\n"
      end

      @board.each_with_index do |row, i|
        i = "\s#{i}" if i < 10
        out << "#{i}\s#{(row.collect {|stn| stn.to_s}).join(' ')}\n"
      end

      out
    end

    def to_s 
      to_str
    end
  end
end
