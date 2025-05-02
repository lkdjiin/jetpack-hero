class Collector
  attr_sprite
  attr_gtk

  def initialize(args)
    @args = args
    @x = 0
    @y = 582
    @w = 80
    @h = 80
    @path = 'sprites/collector.png'
  end

  def render
    outputs.sprites << self
  end
end
