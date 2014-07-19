class Game

  attr_reader :player_ids
  attr_reader :room_id
  attr_reader :player_socks

  @@games = []

  def self.find_empty_game
    @@games.detect do |game|
      game.player_socks.length == 1
    end
  end

  def self.find_by_pid(pid)
    @@games.detect do |game|
      game.player_ids.any?{ |player| player == pid }
    end
  end

  def self.find_by_ws(ws)
    @@games.detect do |game|
      game.player_socks.any?{ |socket| socket == ws }
    end
  end

  def initialize(room_id, player_id)
    @turnstaken = 0
    @@games << self
    @spaces = (1..9).map{|id| id.to_s}.to_a
    @player_ids = [player_ids]
    @room_id = room_id
    @player_socks = []
  end

  def move(role, move)
    @spaces[move - 1] = role
    @turnstaken += 1
  end

  def victor?
    victory_paths = 
    [@spaces[0] + @spaces[1] + @spaces[2],
    @spaces[3] + @spaces[4] + @spaces[5],
    @spaces[6] + @spaces[7] + @spaces[8],
    @spaces[0] + @spaces[3] + @spaces[6],
    @spaces[1] + @spaces[4] + @spaces[7],
    @spaces[2] + @spaces[5] + @spaces[8],
    @spaces[0] + @spaces[4] + @spaces[8],
    @spaces[6] + @spaces[4] + @spaces[2]]
    if victory_paths.any?{|path| path == "xxx"}
      "X wins!"
    elsif victory_paths.any?{|path| path == "ooo"}
      "O wins!"
    elsif @turnstaken > 8
      "Draw!"
    else
      nil
    end
  end

end