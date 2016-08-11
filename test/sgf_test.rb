require_relative 'test_helper'

module RubyGo
  class SGFTest < Minitest::Test

    def test_game_converts_to_sgf
      game = Game.new
      assert_equal "(;GM[1]FF[4]CA[UTF-8]AP[jphager2]SZ[19]PW[White]PB[Black])",
        game.to_sgf
    end

    def test_game_converts_to_sgf_with_moves
      game = Game.new
      game.black(15,3)
      game.white(3,3)
      game.black(3,15)
      game.white(15,15)
      assert_equal "(;GM[1]FF[4]CA[UTF-8]AP[jphager2]SZ[19]PW[White]PB[Black];B[pd];W[dd];B[dp];W[pp])",
        game.to_sgf
    end

    def test_game_converts_correctly_with_capture
      game = Game.new
      game.black(15,3)
      game.white(16,3)
      game.black(16,2)
      game.white(15,2)
      game.black(14,2)
      game.white(14,3)
      game.black(17,3)
      game.white(15,4)
      game.black(16,4)
      game.white(15,3)

      assert_equal "(;GM[1]FF[4]CA[UTF-8]AP[jphager2]SZ[19]PW[White]PB[Black];B[pd];W[qd];B[qc];W[pc];B[oc];W[od];B[rd];W[pe];B[qe];W[pd])",
        game.to_sgf
    end

    def test_saves_sgf
      file = File.expand_path('../../my_go_game.sgf', __FILE__)
      path = File.expand_path('../../*.sgf', __FILE__)
      File.delete(file) if File.exist?(file)
      game = Game.new
      game.black(15,3)
      game.white(16,3)
      game.black(16,2)
      game.white(15,2)
      game.save
      assert_includes Dir.glob(path), file 
    end
  end
end
