require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'
require_relative 'game'

#Use only reactor-aware libraries--do not block the event loop!

def run(opts)

  EventMachine.run {
    @players = []
    @game = Game.new

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
        if @players.empty?
          @players << ws
          @players.each{|client| client.send(JSON.dump(notification: "Waiting for a challenger"))}
        else
          @players << ws
          @game.players[:ex] = @players[0]
          @game.players[:oh] = @players[1]
          @players.each{|client| client.send(JSON.dump(notification: "Now starting the game!"))}
        end
      end
      ws.onclose do
        @players.reject!{|client| client == ws}.each{|client| client.send(JSON.dump(notification: "Your opponent has signed off"))}
      end
      ws.onmessage do |msg|
        @game.move(ws, msg.to_i)
        @game.find_opponent(ws).send(JSON.dump(opp_sym: @game.find_player_symbol(ws, msg).to_s, opp_move: msg))
        if message = @game.victor?
          @players.each{|player| player.send(JSON.dump("notification"=> message))}
        end
      end
    end
  }

end