class HeroAndFuelCollision
  def self.detect(hero, fuel)
    if hero.intersect_rect?(fuel)
      hero.jetpack_power += 20
      hero.jetpack_power = hero.jetpack_power.clamp(0, 100)
      fuel.used = true

      true
    else
      false
    end
  end
end
