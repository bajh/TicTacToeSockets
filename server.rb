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
    @turn_schedule = nil

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
          @players[0].send(JSON.dump(notification: "Waiting for a challenger", role_assign: 'x'))
        else
          @players << ws
          @turn_schedule = @players.cycle
          @turn_schedule.next
          @players[0].send(JSON.dump(unlock: true, notification: "Now starting the game! Your move!"))
          @players[1].send(JSON.dump(notification: "Now starting the game! Please wait for your opponent to make their move", role_assign: 'o'))
        end
      end
      ws.onclose do
        @players.each{|client| client.send(JSON.dump(notification: "Your opponent has signed off"))}
      end
      ws.onmessage do |msg|
        #parse the incoming string into JSON
        msg = JSON.parse(msg)
        @game.move(msg["role"], msg["move"].to_i)
        @turn_schedule.next.send(JSON.dump(opp_move: msg["move"]))
        if message = @game.victor?
          @players.each{|player| player.send(JSON.dump(notification: message))}
        end
      end
    end
  }

end