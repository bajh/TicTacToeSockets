class Game

  attr_reader :players

  def initialize
    @players = {}
    @turnstaken = 0
    @spaces = (1..9).map{|id| id.to_s}.to_a
  end

  def move(message)
    
  end

  def victor?
    victory_paths = [@spaces[0] + @spaces[1] + @spaces[2], @spaces[3] + @spaces[4] + @spaces[5], @spaces[6] + @spaces[7] + @spaces[8], @spaces[0] + @spaces[3] + @spaces[6], @spaces[1] + @spaces[4] + @spaces[7], @spaces[2] + @spaces[5] + @spaces[8], @spaces[0] + @spaces[4] + @spaces[8], @spaces[6] + @spaces[4] + @spaces[2]]
    if victory_paths.any?{|path| path == "exexex"}
      "X wins!"
    elsif victory_paths.any?{|path| path == "ohohoh"}
      "O wins!"
    elsif @turnstaken 
      "Cat's game!"
    else
      nil
    end
  end

end