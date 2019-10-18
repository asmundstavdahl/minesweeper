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
  # command = get_next_command
  command = COMMANDS.next
  case command
  when Command
    game.process command
    puts game.render
  when Iterator::Stop
    puts "Good bye."
    break
  end
end

if game.over?
  puts "Game over."
end
