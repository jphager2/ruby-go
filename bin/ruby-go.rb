#!/usr/bin/env ruby

require_relative '../lib/ruby-go'

game = RubyGo::Game.new

def game.prompt_for_turn
  print "Pass or enter coordinates x, y for move (e.g. 4, 4): "
  ans = gets.chomp.downcase.gsub(/\s/, '')

  if ans =~ /pass/
    self.pass 
    nil
  else
    ans.split(',').collect {|c| Integer(c)}
  end
end 

system "clear"
game.view
turn = 0
until game.passes >= 2
  begin 
    if turn % 2 == 0
      #black's turn
      puts "Black's turn"
      ans = game.prompt_for_turn
      game.black(*ans) if ans
    else
      #white's turn 
      puts "white's turn"
      ans = game.prompt_for_turn 
      game.white(*ans) if ans
    end

    system "clear"
    game.view

    turn += 1
  rescue RubyGo::Game::IllegalMove
    next
  end
end

system "clear"
