module RubyGo
  class Board
    Colors = {black: 'x', white: 'o', empty: '_'}

    # rename board to internal_board, and make it private
    attr_accessor :board
    def initialize(size)
      @board = []
      size -= 1

      0.upto(size) do |y|
        row = []
        0.upto(size) do |x| 
          row << Liberty.new(x, y) 
        end
        @board << row
      end
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

    def around(intersection)
      x, y = intersection.to_coord
      stones = [] 
      stones << at(x-1, y) unless x == 0 
      stones << at(x+1, y) unless x == (@board.length - 1) 
      stones << at(x, y-1) unless y == 0 
      stones << at(x, y+1) unless y == (@board.length - 1)
      stones
    end

    def remove(stone)
      stone.remove_from_board(self)
    end

    def place(stone)
      stone.place_on_board(self)
    end

    def liberties(stone)
      group_of(stone).inject(0) do |libs, stn|
        libs + stn.liberties(self).count
      end
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
