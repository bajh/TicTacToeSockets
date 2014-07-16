require 'pry'

class Game

  attr_reader :players

  def initialize
    @players = {}
    @turnstaken = 0
    @spaces = (1..9).map{|id| id.to_s}.to_a
  end

  def move(connection, message)
    @spaces[message.to_i - 1] = find_player_symbol(connection, message).to_s
  end

  def find_opponent(connection)
    @players.reject{|ws| ws == connection}.values.first
  end

  def find_player_symbol(connection, message)
    @players.select{|sym, ws| ws == connection }.keys[0]
  end

  def victor?
    victory_paths = [@spaces[0] + @spaces[1] + @spaces[2], @spaces[3] + @spaces[4] + @spaces[5], @spaces[6] + @spaces[7] + @spaces[8], @spaces[0] + @spaces[3] + @spaces[6], @spaces[1] + @spaces[4] + @spaces[7], @spaces[2] + @spaces[5] + @spaces[8], @spaces[0] + @spaces[4] + @spaces[8], @spaces[6] + @spaces[4] + @spaces[2]]
    if victory_paths.any?{|path| path == "exexex"}
      "X wins!"
    elsif victory_paths.any?{|path| path == "ohohoh"}
      "O wins!"
    elsif @turnstaken 
      "Draw!"
    else
      nil
    end
  end

end