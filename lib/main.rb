require_relative "constant"
require_relative "game"

game = Game.new()
while true
  while game.turn()
  end
  puts "Game is over! Press any key to restart, or q to exit."
  input = gets.chomp()
  if input == "q"
    break
  end 
end 