class Fuel
  attr_sprite
  attr :used, :dead, :start_looping_at

  def initialize(x:, y:)
    @x = x
    @y = y
    @w = 25
    @h = 30
    @path = 'sprites/fuel.png'
    @used = false
    @dead = false
    @start_looping_at = nil
  end

  def calc
    if @dead
      sprite_index = @start_looping_at.frame_index(9, 8, false)
      if sprite_index
        @path = "sprites/explosion-#{sprite_index}.png"
      else
        @used = true
      end
    end
  end
end
