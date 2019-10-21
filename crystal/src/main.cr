require "./game"
require "./input"

game = Game.new

puts
puts `date "+%F %T"`
puts

COMMANDS = [
  Show.new(8, 8),
  Quit.new,
].each

until game.over?
  puts game.render
  command = get_next_command
  # command = COMMANDS.next
  case command
  when Command
    game.process command
  when Iterator::Stop
    puts "Good bye."
    break
  end
end

if game.over?
  puts game.render
  puts "Game over."
end
