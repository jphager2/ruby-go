require_relative 'board'
require_relative 'game'
require_relative 'stone'

class GamePrompt
  
  def initialize(size)
    size = [9, 13, 19][size/6 - 1]
    @game = GoGame.new(board: size)
  end

  def start 
    @game.print_board

    # Black goes first
    @turns = [-> {black_turn}, -> {white_turn}]

    i = 0
    until @game.pass >= 2
      @turns[i % 2].call
      i += 1
    end
  end

  def a_turn
    print "'Pass' or 'x, y'?: "
    res = gets.chomp.downcase.gsub(/\s/, '')
    case res 
    when /pass/
      @game.pass_turn
    when /\d+,\d+/ 
      coords = res.split(',').collect {|c| c.to_i}
      yield(*coords)
    else
      puts "Sorry, you can't do that."
      return nil
    end
  end

  def black_turn 
    puts "Black's turn"
    res = a_turn { |x, y| @game.place_black_stone(x, y) }
    black_turn unless res
  end

  def white_turn 
    puts "White's turn"
    res = a_turn { |x, y| @game.place_white_stone(x, y) }
    white_turn unless res
  end
end
