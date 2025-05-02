class FuelAndShotCollision
  def self.detect(fuel, shot)
    if shot.intersect_rect?(fuel)
      shot.dead = true
      fuel.dead = true
      fuel.start_looping_at = Kernel.tick_count

      # Adjust size and position for the (future) new sprite
      fuel.w = 96
      fuel.h = 128
      fuel.x -= 36.5

      true
    else
      false
    end
  end
end
