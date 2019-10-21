require "./cell"

class Game
  @cells : Array(Array(Cell))
  @cols : Int32
  @rows : Int32
  @bombs : Int32

  def initialize
    @game_over = false

    ENV["cols"] ||= "10"
    ENV["rows"] ||= "10"
    ENV["bombs"] ||= "10"

    @cols = (ENV["cols"]?.not_nil!).to_i
    @rows = (ENV["rows"]?.not_nil!).to_i
    bombs = (ENV["bombs"]?.not_nil!).to_i

    @cells = ([[] of Cell] * @rows).map do |_|
      ([Cell.new] * @cols).map do |_|
        Cell.new
      end
    end

    bomb_xys = ([{-1, -1}] * bombs).map { |_| {Random.rand(@cols), Random.rand(@rows)} }

    bomb_xys.each do |xy|
      @cells[xy[1]][xy[0]].be_bomb!
    end

    @bombs = @cells.flatten.reduce(0) do |acc, cell|
      if cell.bomb?
        acc + 1
      else
        acc
      end
    end
  end

  def over?
    if @cells.flatten.any? { |c| c.bomb? && c.shown? }
      @game_over = true
    end

    @game_over
  end

  def process(command : Command)
    puts command
    case command
    when Quit
      @game_over = true
    when Flag
      @cells[command.y][command.x].flag!
    when Show
      self.show(command.x, command.y)
    else
      puts "No implementation for " + typeof(command).to_s
    end
  end

  def render
    col_digits = Math.log10(@cols).ceil.to_i
    row_digits = Math.log10(@rows).ceil.to_i
    (0...col_digits).each do |digit|
      relevant_digits = (0...@cols).map { |col| sprintf("%#{col_digits}d", col)[digit] }
      puts (" " * (row_digits + 1)) + relevant_digits.join " "
    end

    @cells.each.with_index do |row, row_number|
      cells_rendered = ["?"] * @cols

      row.each.with_index do |cell, col_number|
        cells_rendered[col_number] = self.render_cell(col_number, row_number)
      end

      puts sprintf("%#{row_digits}d", row_number) + " " + cells_rendered.join " "
    end
  end

  private def render_cell(x, y) : String
    cell = @cells[y][x]

    if cell.shown?
      if cell.bomb?
        "\e[1;31mB\e[0m"
      else
        adjacent_bombs = self.count_bombs_around(x, y)
        if adjacent_bombs == 0
          "\e[2m0\e[0m"
        else
          adjacent_bombs.to_s
        end
      end
    else
      if cell.flagged?
        "\e[2;7mF\e[0m"
      else
        "\e[2m?\e[0m"
      end
    end
  end

  private def count_bombs_around(target_x, target_y)
    sum = 0
    for_each_cell_around(target_x, target_y) do |cell|
      if cell.bomb?
        sum += 1
      end
    end
    sum
  end

  private def for_each_cell_around(target_x, target_y)
    (0...@cols).each do |x|
      if x >= target_x - 1 && x <= target_x + 1
        (0...@rows).each do |y|
          if y >= target_y - 1 && y <= target_y + 1
            if x != target_x || y != target_y
              yield @cells[y][x], x, y
            end
          end
        end
      end
    end
  end

  private def show(x, y)
    @cells[y][x].show!
    if count_bombs_around(x, y) == 0
      for_each_cell_around(x, y) do |cell, adjacent_x, adjacent_y|
        if !cell.shown?
          self.show(adjacent_x, adjacent_y)
        end
      end
    end
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
