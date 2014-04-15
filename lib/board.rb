class GoBoard 
  Color = {black: "x", white: "o", empty: "-"}
  # Stars = [ 9 => [2, 5, 7], 13 => [3, 6 ,9], 19 => [3, 9, 15] ]

  def initialize(size)
    @board = []
    (1..size).each_with_object(@board) do |row_num, board| 
      board << (1..size).each_with_object([]) do |col_num, row| 
        row << Stone.new(col_num, row_num)
      end
    end
  end

  def to_str
    board = "\s\s" + (0..@board.length-1).to_a.join(' ') + "\n" 
    @board.each_with_index {|row, i| board << "#{i} " << row.join(" ") << "\n"}
    return board
  end

  def to_s 
    to_str 
  end

  def to_ary
    @board
  end

  def to_a 
    to_ary 
  end

  def at(x, y)
    @board[y][x]
  end

  def stones_around(x, y)
    stones = [] 
    stones << @board[y][x-1] unless x == 0
    stones << @board[y][x+1] unless x == @board.length - 1
    stones << @board[y-1][x] unless y == 0
    stones << @board[y+1][x] unless y == @board.length - 1
    stones
  end

  def place_stone(stone)
    stone.place_on_board(self)
  end

  def liberties(stone)
    group = stone_group_for(stone)

    group.each_with_object([]) do |stone, libs| 
      libs << stone.liberties(self)
    end.flatten.uniq.count
  end

  def stone_group_for(stone)
    stone.group(self)
  end
end
