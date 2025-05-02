class HeroAndOreCollision
  def self.detect(hero, ore)
    if hero.ore == 0 && hero.intersect_rect?(ore)
      ore.used = true
      hero.ore = 1

      true
    else
      false
    end
  end
end
