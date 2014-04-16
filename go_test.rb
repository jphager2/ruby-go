require_relative 'go.rb'

require 'minitest/autorun'

class GoTest < Minitest::Unit::TestCase 
  def setup
    b,w = Board::Colors[:black], Board::Colors[:white] 
    e   = Board::Colors[:empty]

    @empty_board = "" 
    9.times {@empty_board << (e*9).split(//).join(' ') << "\n"}
  end

  def test_game_has_blank_board_when_initialized
    game = Game.new(board: 9)
    board = game.board
    assert game.board.empty?
  end

  def test_empty_board_looks_like_empty_board
    game = Game.new(board: 9)
    board = game.board.to_s 
    assert_includes board, @empty_board
  end

  def test_game_can_place_place_a_stone
    game = Game.new(board: 9)
    game.black(2,2)
    assert_equal game.board.at(2,2), BlackStone.new(2,2)
  end

  def test_can_capture_one_stone
    skip 
    game = Game.new(board: 9)
    game.black(2,2)
    game.white(2,1)
    game.white(2,3)
    game.white(1,2)
    game.white(3,2)
    assert_equal game.captures[:black], 1
  end

  def test_capture_removes_stone
    skip
    game = Game.new(board: 9)
    game.black(2,2)
    game.white(2,1)
    game.white(2,3)
    game.white(1,2)
    game.white(3,2)
    assert_equal game.board.at(2,2), Liberty.new(2,2)
  end

  def test_capture_three_stones
    skip
    game = Game.new(board: 9)
    game.black(2,1)
    game.black(2,2)
    game.black(2,3)
    game.white(2,0)
    game.white(2,4)
    game.white(1,1)
    game.white(1,2)
    game.white(1,3)
    game.white(3,1)
    game.white(3,2)
    game.white(3,3)
    assert_equal game.captures[:black], 3
  end
end


