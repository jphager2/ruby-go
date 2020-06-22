require_relative 'test_helper'
require 'stringio'

module RubyGo
  class GoTest < Minitest::Test
    def setup
      @row_9_str = " 8 _ _ _ _ _ _ _ _ _ \n"

      @game = Game.new(board: 9)
    end

    def test_game_has_blank_board_when_initialized
      assert @game.board.empty?
    end

    def test_printer_can_print_the_game
      out = StringIO.new
      printer = RubyGo::TextPrinter.new(out)
      printer.print_game(@game)
      out.rewind
      assert_includes out.read, @row_9_str
    end

    def test_game_can_place_a_stone
      game = Game.new(board: 9)
      game.place_black(2,2)
      assert_equal :black, game.board.at(2,2).color
    end

    def test_cannot_place_a_stone_on_top_of_another_stone
      game = Game.new(board: 9)
      game.place_black(2,2)
      assert_raises(Game::IllegalMove) do
        game.place_white(2,2)
      end
    end

    def test_can_capture_one_stone
      game = Game.new(board: 9)
      game.place_black(2,2)
      game.place_white(2,1)
      game.place_white(2,3)
      game.place_white(1,2)
      game.place_white(3,2)
      assert_equal 1, game.captures[:black]
    end

    def test_capture_removes_stone
      game = Game.new(board: 9)
      game.place_black(2,2)
      game.place_white(2,1)
      game.place_white(2,3)
      game.place_white(1,2)
      game.place_white(3,2)
      assert game.board.at(2,2).empty?
    end

    def test_capture_three_stones
      game = Game.new(board: 9)
      game.place_black(2,1)
      game.place_black(2,2)
      game.place_black(2,3)
      game.place_white(2,0)
      game.place_white(2,4)
      game.place_white(1,1)
      game.place_white(1,2)
      game.place_white(1,3)
      game.place_white(3,1)
      game.place_white(3,2)
      game.place_white(3,3)
      assert_equal 3, game.captures[:black]
    end

    def test_snap_back
      game = Game.new(board: 9)
      game.place_black(3,2)
      game.place_black(2,3)
      game.place_black(4,3)
      game.place_black(2,4)
      game.place_black(5,4)
      game.place_black(3,5)
      game.place_black(4,5)
      game.place_white(4,2)
      game.place_white(5,3)
      game.place_white(3,4)
      game.place_white(4,4)
      game.place_white(3,3)
      assert_equal 1, game.captures[:black]
      assert_equal 0, game.captures[:white]
      game.place_black(4,3)
      assert_equal 1, game.captures[:black]
      assert_equal 3, game.captures[:white]
    end

    def test_can_undo
      game = Game.new()
      game.place_black(2,2)
      game.place_white(2,3)
      game.undo
      assert game.board.at(2,3).empty?
    end

    def test_can_undo_pass
      game = Game.new
      game.place_black(2,2)
      game.white_pass
      game.undo
      assert_equal 0, game.passes
    end

    def test_can_undo_until_beginning
      game = Game.new()
      game.place_black(2,2)
      game.place_white(3,2)
      game.place_black(3,3)
      3.times {game.undo}
      assert game.board.at(2,2).empty?
    end

    def test_can_pass
      game = Game.new
      game.black_pass
      game.white_pass
      assert_equal 2, game.passes
    end

    def test_cannot_play_a_suicide
      game = Game.new
      game.place_black(3,3)
      game.place_white(2,3)
      game.place_white(4,3)
      game.place_white(3,4)
      game.place_white(3,2)
      assert_raises(Game::IllegalMove) do
        game.place_black(3,3)
      end
    end

    def test_cannot_play_a_ko
      game = Game.new
      game.place_black(3,3)
      game.place_white(2,3)
      game.place_white(4,3)
      game.place_white(3,4)
      game.place_white(3,2)
      game.place_black(4,2)
      game.place_black(4,4)
      game.place_black(5,3)
      game.place_black(3,3)
      assert_raises(Game::IllegalMove) do
        game.place_white(4,3)
      end
    end

    def big_capture_area_game
      game = Game.new
      game.place_black(0,0)
      game.place_white(1,1)
      game.place_black(0,1)
      game.place_white(0,2)
      game.place_black(1,0)
      game.place_white(2,0)
      game
    end

    def test_can_play_in_previous_capture_area_that_is_not_a_ko
      game = big_capture_area_game
      assert game.board.at(0,0).empty?
      game.place_black(0,0)
      assert_equal :black, game.board.at(0,0).color

      game = big_capture_area_game
      assert game.board.at(0,1).empty?
      game.place_black(0,1)
      assert_equal :black, game.board.at(0,1).color

      game = big_capture_area_game
      assert game.board.at(1,0).empty?
      game.place_black(1,0)
      assert_equal :black, game.board.at(1,0).color
    end
  end
end
