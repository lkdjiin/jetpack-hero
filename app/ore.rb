class Ore
  attr_sprite
  attr :used

  def initialize(x:, y:)
    @x = x
    @y = y
    @w = 30
    @h = 27
    @path = 'sprites/gold.png'
    @used = false
  end
end
