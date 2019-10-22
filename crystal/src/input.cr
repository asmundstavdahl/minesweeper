require "./game"

def get_next_command : Command
  printf(">> ")
  line = gets(true) || ""

  re = /(?<action>q(uit)?|f(lag)?|s(how)?|)(\s*(?<x>\d+)[ ,.+-\/](?<y>\d+)\s*)?/
  match = re.match line

  if !match.nil?
    case match["action"]
    when "quit", "q"
      Quit.new
    when "flag", "f"
      Flag.new(match["x"].to_i, match["y"].to_i)
    when "show", "s", ""
      Show.new(match["x"].to_i, match["y"].to_i)
    else
      puts "Action not implemented: " + match["action"]
      get_next_command
    end
  else
    puts "Bad input: " + line
    get_next_command
  end
rescue ex : KeyError
  puts ex
  get_next_command
end
