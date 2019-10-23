require "./game"

def get_next_command(prompt) : Command
  printf("%s", prompt)
  line = gets(true) || ""

  re = /(?<action>q(uit)?|f(lag)?|s(how)?|c(heat)?|h(elp)?|)(\s*(?<x>\d+)[ ,.+-\/](?<y>\d+)\s*)?/
  match = re.match line

  if !match.nil?
    case match["action"]
    when "quit", "q"
      Quit.new
    when "cheat", "c"
      Cheat.new
    when "help", "h"
      Help.new
    when "flag", "f"
      Flag.new(match["x"].to_i, match["y"].to_i)
    when "show", "s", ""
      Show.new(match["x"].to_i, match["y"].to_i)
    else
      puts "Action not implemented: " + match["action"]
      get_next_command prompt
    end
  else
    puts "Bad input: " + line
    get_next_command prompt
  end
rescue ex : KeyError
  puts ex
  get_next_command prompt
end
