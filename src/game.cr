require "./cell"

class Game
  @cells : Array(Array(Cell))
  @cols : Int32
  @rows : Int32
  @bombs : Int32
  @game_over : Bool

  def initialize
    @game_over = false
    @column_separator = " "

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
      cell_at(xy[0], xy[1]).be_bomb!
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

  def won?
    if @cells.flatten.reject(&.bomb?).all? &.shown?
      @cells.flatten.select(&.bomb?).none? &.shown?
    else
      if @cells.flatten.select(&.bomb?).none? &.shown?
        @cells.flatten.select(&.bomb?).all? &.flagged?
      end
    end
  end

  def prompt
    n_shown = @cells.flatten.select(&.shown?).size
    n_cells = @cols * @rows
    n_flagged = @cells.flatten.select(&.flagged?).size
    sprintf("%d/%d %d/%d » ", n_shown, n_cells, n_flagged, @bombs)
  end

  def process(command : Command)
    puts command
    case command
    when Quit
      @game_over = true
    when Cheat
      cheat()
    when Help
      usage()
    when Flag
      flag(command.x, command.y)
    when Show
      show(command.x, command.y)
    else
      puts "No implementation for " + typeof(command).to_s
    end
  rescue ex : IndexError
    puts ex
  end

  def render
    col_digits = Math.log10(@cols).ceil.to_i
    row_digits = Math.log10(@rows).ceil.to_i
    (0...col_digits).each do |digit|
      relevant_digits = (0...@cols).map { |col| sprintf("%#{col_digits}d", col)[digit] }
      puts (" " * (row_digits)) + @column_separator + relevant_digits.join @column_separator
    end

    @cells.each.with_index do |row, row_number|
      cells_rendered = ["?"] * @cols

      row.each.with_index do |cell, col_number|
        cells_rendered[col_number] = render_cell(col_number, row_number)
      end

      puts sprintf("%#{row_digits}d", row_number) + @column_separator + cells_rendered.join @column_separator
    end
  end

  def separate_columns_with(separator)
    @column_separator = separator
  end

  private def render_cell(x, y) : String
    cell = cell_at(x, y)

    game_over = won? || @game_over

    color = case
            when x % 3 == 0, y % 3 == 0 then "\e[37m"
            else                             ""
            end

    text = case {game_over, cell.shown?, cell.flagged?, cell.bomb?}
           when {false, false, false, _}
             "\e[1m·"
           when {false, false, true, _}
             "\e[1m⚑"
           when {_, true, _, true}
             "\e[1;31m💥"
           when {true, false, false, true}
             "\e[33m💣"
           when {true, false, true, true}
             "\e[32m💣"
           else
             adjacent_bombs = count_bombs_around(x, y)
             if adjacent_bombs == 0
               "\e[2m·"
             else
               adjacent_bombs.to_s
             end
           end

    color + text + "\e[0m"
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
              yield cell_at(x, y), x, y
            end
          end
        end
      end
    end
  end

  private def show(x, y)
    cell = cell_at(x, y)

    if cell.flagged?
      puts "Toggle flag first!"
    else
      cell.unflag!
      cell.show!
      if count_bombs_around(x, y) == 0
        for_each_cell_around(x, y) do |cell, adjacent_x, adjacent_y|
          if !cell.shown?
            show(adjacent_x, adjacent_y)
          end
        end
      end
    end
  end

  private def cell_at(x, y)
    @cells[y][x]
  end

  private def cheat
    xys = (0...@cols).flat_map { |col| (0...@rows).map { |row| {col, row} } }

    viable_xys = xys.reject do |xy|
      cell = cell_at(xy[0], xy[1])
      cell.bomb? || cell.shown?
    end

    xys_by_adj_bombs = viable_xys.sort { |a, b| count_bombs_around(a[0], a[1]) <=> count_bombs_around(b[0], b[1]) }

    xy = xys_by_adj_bombs.first
    process Show.new(xy[0], xy[1])
  end

  private def usage
    puts "h(elp)"
    puts "\e[2mc(heat)\e[0m"
    puts "q(uit)"
    puts "f(lag) <x> <y>"
    puts "(s(how)) <x> <y>"
  end

  private def flag(x, y)
    cell = cell_at(x, y)

    if cell.shown?
      puts "#{x},#{y} already shown"
    else
      cell.flag!
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

struct Cheat
end

struct Help
end

alias Command = Quit | Flag | Show | Cheat | Help
