require_relative '../lib/go'

require 'minitest/autorun'
require 'stringio'

class GoBoardTest < MiniTest::Unit::TestCase
  @x = GoBoard::Color[:black]
  @y = GoBoard::Color[:white]
  @_ = GoBoard::Color[:empty]
  EmptyBoardx9 = "#{(@_ * 9).split('').join(' ')}\n" * 9

  def test_board_is_empty_when_initialized
    board = GoBoard.new(9)
    temp = $stdout
    $stdout = StringIO.new
    puts board.to_s
    $stdout.rewind 
    assert_includes $stdout.read, EmptyBoardx9
  end 

  def test_place_stone_on_board
    board = GoBoard.new(9)
    stone = BlackStone.new(3,3)
    board.place_stone(stone)
    assert_equal board.to_a[3][3], stone 
  end

  def test_cannot_place_one_stone_on_another
    board = GoBoard.new(9)
    stone = BlackStone.new(3,3)
    board.place_stone(stone)
    assert_raises(Stone::PlacementError) { board.place_stone(stone) }
  end
end

class GoGameTest < MiniTest::Unit::TestCase 
  def capture
    game = GoGame.new(board: 9)
    game.place_black_stone(2,2)
    game.place_white_stone(2,1)
    game.place_white_stone(2,3)
    game.place_white_stone(1,2)
    game.place_white_stone(3,2)
    game
  end
  
  def test_capture_removes_stone
    game = capture
    assert_equal Stone.new(2,2), game.board.at(2,2) 
  end

  def capture_two
    game = GoGame.new(board: 9)
    game.place_black_stone(2,2)
    game.place_black_stone(2,3)
    game.place_white_stone(2,1)
    game.place_white_stone(2,4)
    game.place_white_stone(1,2)
    game.place_white_stone(1,3)
    game.place_white_stone(3,2)
    game.place_white_stone(3,3)
    game
  end

  def test_capture_two_stones
    game = capture_two
    assert_equal 2, game.captures 
  end 

  def test_illegal_move
    game = GoGame.new(board: 9)
    game.place_black_stone(0,1)
    game.place_black_stone(1,0)
    assert_raises(GoGame::IllegalMove) {game.place_white_stone(0,0)}
  end
end
