require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'
require 'channel'
require 'securerandom'
require_relative 'game'

#Use only reactor-aware libraries--do not block the event loop!

def run(opts)

  EventMachine.run {
    @queue = []
    @channels = {}

    web_app = opts[:app]

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    Rack::Server.start({
      app: dispatch,
      server: 'thin',
      Host: '0.0.0.0',
      Port: '8181'
    })

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8081) do |ws|
      ws.onopen do
        if @queue.empty?
          @queue << ws
          @queue.first.send(JSON.dump(notification: "Waiting for a challenger", role_assign: 'x'))
          @room_id = SecureRandom.hex
          @channel = EM::Channel.new
          @channels[@room_id] = @channel
          game = Game.new(@room_id, SecureRandom.hex)
          sid = @channel.subscribe{|msg| ws.send msg}
          game.player_socks << ws
        else
          @queue << ws
          player_id = SecureRandom.hex
          game = Game.find_empty_game
          game.player_ids << player_id
          game.player_socks << ws
          sid = @channel.subscribe{|msg| ws.send msg} #This block defines how the channel responds when messages are pushed to it
          @channel.push(JSON.dump(notification: "Now starting the game!", pid: "none"))
          @queue[0].send(JSON.dump(unlock: true, pid: game.player_ids[0], notification: "Your move!", role_assign: 'x'))
          @queue[1].send(JSON.dump(notification: "Please wait for your opponent to make their move", pid: game.player_ids[1], role_assign: 'o'))
          @queue.clear
        end
      end

      ws.onclose do
        game = Game.find_by_ws(ws)
        channel = @channels[game.room_id]
        channel.push(JSON.dump(notification: "Your opponent has left"))
      #   @channel.push(JSON.dump(notification: "Now starting the game!")
      #    @players.each{|client| client.send(JSON.dump(notification: "Your opponent has signed off"))}
      end

      ws.onmessage do |msg|
        #parse the incoming string into JSON
        msg = JSON.parse(msg)
        game = Game.find_by_pid(msg["pid"])
        game.move(msg["role"], msg["move"].to_i)
        channel = @channels[game.room_id]
        channel.push(JSON.dump({opp_move: msg["move"], pid: msg["pid"]}))
        if message = game.victor?
          channel.push(JSON.dump(notification: message))
        end
      end

    end
  }

end