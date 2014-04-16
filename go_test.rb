require_relative 'go.rb'


require 'minitest/autorun'
require 'stringio'

class GoTest < Minitest::Unit::TestCase 
  def setup
    b,w = Board::Colors[:black], Board::Colors[:white] 
    e   = Board::Colors[:empty]

    @row_9_str = "_ _ _ _ _ _ _ _ _\n" 

    @game = Game.new(board: 9)
  end

  def test_game_has_blank_board_when_initialized
    assert @game.board.empty?
  end

  def test_empty_board_looks_like_empty_board
    assert_includes @game.board.to_s, @row_9_str 
  end

  def test_game_can_print_the_board
    out = StringIO.new
    temp = $stdout
    $stdout = out
    @game.view
    $stdout = temp
    out.rewind
    assert_includes out.read, @row_9_str
  end

  def test_game_can_place_a_stone
    game = Game.new(board: 9)
    game.black(2,2)
    assert_equal BlackStone.new(2,2), game.board.at(2,2) 
  end

  def test_cannot_place_a_stone_on_top_of_another_stone
    game = Game.new(board: 9)
    game.black(2,2)
    assert_raises(Game::IllegalMove) do
      game.white(2,2)
    end
  end

  def test_can_capture_one_stone
    game = Game.new(board: 9)
    game.black(2,2)
    game.white(2,1)
    game.white(2,3)
    game.white(1,2)
    game.white(3,2)
    assert_equal 1, game.captures[:black]
  end

  def test_capture_removes_stone
    game = Game.new(board: 9)
    game.black(2,2)
    game.white(2,1)
    game.white(2,3)
    game.white(1,2)
    game.white(3,2)
    assert_equal Liberty.new(2,2), game.board.at(2,2) 
  end

  def test_capture_three_stones
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
    assert_equal 3, game.captures[:black]
  end

  def test_can_undo
    game = Game.new()
    game.black(2,2)
    game.white(2,3)
    game.undo
    assert_equal Liberty.new(2,3), game.board.at(2,3)
  end

  def test_can_undo_until_beginning
    game = Game.new()
    game.black(2,2)
    game.white(3,2)
    game.black(3,3)
    3.times {game.undo}
    assert_equal Liberty.new(2,2), game.board.at(2,2)
  end

  def test_can_pass
    game = Game.new
    game.pass 
    game.pass
    assert_equal 2, game.passes
  end
end

