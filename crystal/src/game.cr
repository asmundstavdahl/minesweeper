require "./cell"

struct Game
  @cells : Array(Array(Cell))

  def initialize
    @game_over = false
    @cells = [[] of Cell]
  end

  def over?
    @game_over
  end

  def process(command : Command)
    puts command
    case command
    when Quit
      @game_over = true
    when Flag
      @cells[command.x][command.y].flag!
    when Show
    else
      puts "No implementation for " + typeof(command).to_s
    end
  end

  def render
    "[Game](over?=#{@game_over})"
  end
end

struct Quit
end

module Coordinate
  def initialize(@x : Int32, @y : Int32)
  end

  def x
    @x
  end

  def y
    @y
  end
end

struct Flag
  include Coordinate
end

struct Show
  include Coordinate
end

alias Command = Quit | Flag | Show
