class Cell
  def initialize(@bomb = false, @flagged = false, @shown = false)
  end

  def flag!
    if !@flagged
      @flagged = true
    else
      @flagged = false
    end
  end

  def show!
    @shown = true
  end

  def be_bomb!
    @bomb = true
  end

  def shown?
    @shown
  end

  def flagged?
    @flagged
  end

  def bomb?
    @bomb
  end
end
