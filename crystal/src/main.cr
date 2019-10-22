require "./game"
require "./input"

game = Game.new

ARGV.each do |arg|
  case arg
  when "-c", "--compact"
    game.separate_columns_with ""
  else
    puts "Unknown parameter '#{arg}'"
  end
end

COMMANDS = [
  Show.new(8, 8),
  Quit.new,
].each

until game.over? || game.won?
  puts game.render
  command = get_next_command game.prompt
  # command = COMMANDS.next
  case command
  when Command
    game.process command
  when Iterator::Stop
    puts "Good bye."
    break
  end
end

if game.won?
  puts game.render
  puts "You win!"
elsif game.over?
  puts game.render
  puts "Game over."
end
