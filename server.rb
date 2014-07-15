require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'
require_relative 'game'

def run(opts)

  EventMachine.run {
    @players = []
    @game = Game.new
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8081) do |ws|
      ws.onopen do
        if @players.empty?
          @players << ws
          @players.each{|client| client.send(JSON.dump(notification: "Waiting for a challenger"))}
        else
          @players << ws
          @players.each{|client| client.send(JSON.dump(notification: "Now starting the game!"))}
        end
      end
      ws.onclose do
        @players.reject!{|client| client == ws}.each{|client| client.send(JSON.dump(notification: "Your opponent has signed off"))}
      end
      ws.onmessage do |msg|
        puts msg #Want to test out what I get from the client when they click a box!
      end
    end
  }

end