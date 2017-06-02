module RubyGo
  class Board
    COLORS = { black: 'x', white: 'o', empty: '_' }.freeze

    attr_accessor :internal_board, :size

    def initialize(size)
      @internal_board = Array.new(size) { Array.new(size) { Liberty.new } }
      @size = size
    end

    private :internal_board

    def empty?
      internal_board.flatten.all?(&:empty?)
    end

    def at(x, y)
      internal_board[y][x]
    end

    def around(x, y)
      intersections = [] 

      intersections << at(x-1, y) unless x == 0 
      intersections << at(x+1, y) unless x == (internal_board.length - 1) 
      intersections << at(x, y-1) unless y == 0 
      intersections << at(x, y+1) unless y == (internal_board.length - 1)
      intersections
    end

    def remove(stone)
      x, y = stone.to_coord

      internal_board[y][x] = Liberty.new
    end

    # Board shouldn't care about game rules
    def place(stone)
      x, y = stone.to_coord

      internal_board[y][x] = stone
    end

    def liberties(stone)
      libs = []

      group_of(stone).each do |stn|
        libs += around(*stn.to_coord).select(&:empty?)
      end

      libs.uniq.length
    end

    def group_of(stone, stones = [])
      return stones if stones.include?(stone)

      stones << stone

      around(*stone.to_coord).each do |intersection|
        next if intersection.empty?

        group_of(intersection, stones) if intersection.color == stone.color
      end

      stones
    end

    def to_s
      out = ""
      if size < 11
        out << "\s\s\s#{(0..size - 1).to_a.join(' ')}\n" 
      else
        out << "\s\s\s#{(0..10).to_a.join(' ')}" 
        out << "#{(11..size - 1).to_a.join('')}\n"
      end

      internal_board.each_with_index do |row, i|
        i = "\s#{i}" if i < 10
        out << "#{i}\s#{(row.collect {|stn| stn.to_s}).join(' ')}\n"
      end

      out
    end
  end
end
