require "./game"

def get_next_command : Command
  line = gets(true) || ""

  puts typeof(line).to_s + " " + line

  re = /(?<action>quit|flag|show) (?<x>\d+) (?<y>\d+)/
  match = re.match line
  puts match

  if line =~ /^quit$/
    Quit.new
  elsif line =~ /^flag /
    match = /(?<x>\d+) (?<y>\d+)$/.match(line)
    if match.nil?
      puts "Bad coordinates."
      get_next_command
    else
      Flag.new(match["x"].to_i, match["y"].to_i)
    end
  elsif line =~ /^show /
    match = /(?<x>\d+) (?<y>\d+)$/.match(line)
    if match.nil?
      puts "Bad coordinates."
      get_next_command
    else
      Show.new(match["x"].to_i, match["y"].to_i)
    end
  else
    puts "Bad input: " + line
    get_next_command
  end
end
