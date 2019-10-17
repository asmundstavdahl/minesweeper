struct Cell
  def initialize(@bomb = false, @flagged = false, @shown = false)
  end

  def flag!
    @flagged = !@flagged
  end
end
