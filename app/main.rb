HERO_SCALE = 4 # Image ratio
ALIEN_SCALE = 1.5
ALIEN_W  = 50 * ALIEN_SCALE
ALIEN_H = 35 * ALIEN_SCALE
FALL = -1.8 # Kind of gravity
RL_SPEED = 5 # Right/left speed
IMPULSE = 4 # Jetpack power
IMPULSE_DECREASE = 0.9 # Jetpack power ratio decrease per frame
LASER_SPEED = 7
FIRE_RATE = 30 # Maximum is one shoot every FIRE_RATE frames
LASER_ANIMATION = 10
ALIEN_ANIMATION = 15


class Game
  attr_gtk

  def initialize
    @game_over = false
  end

  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    state.hero ||= {
      x: 120,
      y: 700,
      w: 7 * HERO_SCALE,
      h: 17 * HERO_SCALE,
      path: 'sprites/hero-flying.png',
      flip_horizontally: true,
      impulse: 0,
      moving: :none,
      facing: :right,
      jetpack_power: 100,
      ore: 0,
      ascending: false,
      shooting: false,
      last_shoot_at: 0,
    }

    state.platforms ||= [
      { x: 0, y: 570, w: 200, h: 12, path: 'sprites/tile.png' },
      { x: 400, y: 570, w: 700, h: 12, path: 'sprites/tile.png' },
      { x: 1200, y: 570, w: 80, h: 12, path: 'sprites/tile.png' },
      { x: 0, y: 420, w: 200, h: 12, path: 'sprites/tile.png' },
      { x: 400, y: 420, w: 700, h: 12, path: 'sprites/tile.png' },
      { x: 1200, y: 420, w: 80, h: 12, path: 'sprites/tile.png' },
      { x: 0, y: 270, w: 200, h: 12, path: 'sprites/tile.png' },
      { x: 400, y: 270, w: 700, h: 12, path: 'sprites/tile.png' },
      { x: 1200, y: 270, w: 80, h: 12, path: 'sprites/tile.png' },
      { x: 0, y: 130, w: 1280, h: 12, path: 'sprites/tile.png' },
    ]

    state.fuel ||= [
      { x: 800, y: 142, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
      { x: 700, y: 142, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
      { x: 600, y: 142, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
      { x: 700, y: 282, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
      { x: 700, y: 432, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
      { x: 700, y: 582, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
    ]

    state.ores ||= [
      { x:1220, y: 282, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:500, y: 282, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:10, y: 282, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:10, y: 432, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:800, y: 432, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:1220, y: 432, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:800, y: 582, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:1220, y: 582, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:10, y: 142, w: 30, h: 27, path: 'sprites/gold.png', used: false },
      { x:1220, y: 142, w: 30, h: 27, path: 'sprites/gold.png', used: false },
    ]

    state.collector ||= { x:0, y: 582, w: 80, h: 80, path: 'sprites/collector.png' }

    state.level ||= {
      remaining_ores: 10,
      completed: false,
    }

    state.aliens ||= []
    state.aliens_apparition ||= []
    state.aliens_disparition ||= []
    state.aliens_pool ||= [
      { x: 420, y: 582, w: ALIEN_W, h: ALIEN_H, alive: false, id: 0, speed: 2, x_min: 410, x_max: 1_000 },
      { x: 80, y: 432, w: ALIEN_W, h: ALIEN_H, alive: false, id: 1, speed: 0.8, x_min: 50, x_max: 120 },
      { x: 700, y: 432, w: ALIEN_W, h: ALIEN_H, alive: false, id: 2, speed: -1.8, x_min: 410, x_max: 1_000 },
      { x: 80, y: 282, w: ALIEN_W, h: ALIEN_H, alive: false, id: 3, speed: 0.7, x_min: 50, x_max: 120 },
      { x: 900, y: 282, w: ALIEN_W, h: ALIEN_H, alive: false, id: 4, speed: 1.7, x_min: 410, x_max: 1_000 },
      { x: 200, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 5, speed: 2, x_min: 50, x_max: 1_200 },
      { x: 900, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 5, speed: -2, x_min: 50, x_max: 1_200 },
    ]

    state.shoots ||= []
  end

  def render
    outputs.solids << { x: 0, y: 130, w: 1280, h: 610, r: 0, g: 0, b: 0 }
    outputs.solids << { x: 0, y: 0, w: 1280, h: 130, r: 60, g: 60, b: 70 }
    outputs.solids << { x: 305, y: 54, w: 600, h: 27, r: 255, g: 0, b: 0 }
    outputs.solids << { x: 305, y: 54, w: state.hero.jetpack_power * 6, h: 27, r: 255, g: 255, b: 0 }
    outputs.sprites << state.platforms
    outputs.sprites << state.fuel
    outputs.sprites << state.ores
    if state.hero.ore == 1
      outputs.sprites << {
        x: state.hero.x,
        y: state.hero.y,
        w: 30, h: 40, path: 'sprites/gold.png'
      }
    end
    outputs.sprites << state.hero
    render_jetpack_flame
    outputs.sprites << state.collector
    outputs.sprites << state.aliens_apparition
    outputs.sprites << state.aliens
    outputs.sprites << state.aliens_disparition
    outputs.sprites << state.shoots
    outputs.labels << {
      x: 200,
      y: 45,
      size_px: 40,
      alignment_enum: 0,
      vertical_alignment_enum: 0,
      text: "POWER",
      r: 255,
      g: 255,
      b: 255,
    }

    if state.level.completed
      outputs.labels << {
        x: 640,
        y: 360,
        size_px: 120,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: "Level Completed!",
        r: 255,
        g: 255,
        b: 255,
      }
    end

    if @game_over
      outputs.labels << {
        x: 640,
        y: 360,
        size_px: 200,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: "GAME OVER",
        r: 255,
        g: 255,
        b: 255,
      }
    end
  end

  def render_jetpack_flame
    return if state.hero.impulse < 0.2

    flame = {
      x: state.hero.facing == :left ? state.hero.x + 14 : state.hero.x - 1,
      y: state.hero.y - 15,
      w: 16, h: 40
    }

    if state.hero.impulse > 3
      flame.merge!({ path: 'sprites/flame-0.png'})
    elsif state.hero.impulse > 2
      flame.merge!({ path: 'sprites/flame-1.png'})
    elsif state.hero.impulse > 1
      flame.merge!({ path: 'sprites/flame-2.png'})
    elsif state.hero.impulse > 0.6
      flame.merge!({ path: 'sprites/flame-3.png'})
    elsif state.hero.impulse > 0.2
      flame.merge!({ path: 'sprites/flame-4.png'})
    end

    outputs.sprites << flame
  end

  def input
    if inputs.left
      state.hero.moving = :left
      state.hero.facing = :left
    elsif inputs.right
      state.hero.moving = :right
      state.hero.facing = :right
    else
      state.hero.moving = :none
    end

    if inputs.keyboard.control || inputs.controller_one.y
      if state.hero.jetpack_power > 0
        state.hero.impulse = IMPULSE
        state.hero.jetpack_power -= 0.1
        audio[:jetpack] = { input: "sounds/jetpack.wav" } unless audio[:jetpack]
      end
    end

    if inputs.keyboard.alt || inputs.controller_one.b
      if state.hero.last_shoot_at + FIRE_RATE < Kernel.tick_count
        state.hero.shooting = true
        audio[:laser] = { input: 'sounds/laser.wav' }
      end
    end
  end

  def calc
    return if @game_over

    calc_init
    calc_aliens
    calc_hero_y_position
    calc_directions
    calc_platform_collision
    calc_alien_collision
    calc_picking_fuel
    calc_picking_ore
    calc_collecting_ore
    calc_shoot
    calc_clamp
  end

  def calc_init
    state.at_calc_start = {
      x: state.hero.x,
      y: state.hero.y,
    }
  end

  def calc_aliens
    state.aliens_pool.each do |alien|
      if alien.alive == false && rand(700) == 0
        alien.alive = true
        state.aliens_apparition << alien.dup.merge({
          start_looping_at: Kernel.tick_count,
          finished: false,
        })
        break
      end
    end

    state.aliens_apparition.each do |alien|
      sprite_index = alien.start_looping_at.frame_index(10, 8, false)
      if sprite_index
        alien.path = "sprites/apparition-#{sprite_index}.png"
      else
        alien.finished = true
        state.aliens << alien.dup.merge({
          path: 'sprites/alien.png',
          dead: false,
          flip_horizontally: false,
          animation_counter: ALIEN_ANIMATION,
        })
      end
    end
    state.aliens_apparition.reject!(&:finished)

    state.aliens.each do |alien|
      if alien.dead
        state.aliens_disparition << alien.dup.merge({
          start_looping_at: Kernel.tick_count,
          finished: false,
        })
        audio[:explosion] = { input: "sounds/explosion.wav" }
        next
      end

      alien.x += alien.speed
      if alien.x <= alien.x_min || alien.x >= alien.x_max
        alien.speed = -alien.speed
      end
      alien.animation_counter -= 1
      if alien.animation_counter == 0
        alien.animation_counter = ALIEN_ANIMATION
        alien.flip_horizontally = !alien.flip_horizontally
      end
    end
    state.aliens.reject!(&:dead)

    state.aliens_disparition.each do |alien|
      sprite_index = alien.start_looping_at.frame_index(7, 8, false)
      if sprite_index
        alien.path = "sprites/disparition-#{sprite_index}.png"
      else
        alien.finished = true
        state.aliens_pool[alien.id].alive = false
      end
    end
    state.aliens_disparition.reject!(&:finished)
  end

  def calc_hero_y_position
    state.hero.impulse *= IMPULSE_DECREASE
    state.hero.impulse = 0 if state.hero.impulse < 0.1
    state.hero.y += FALL
    state.hero.y += state.hero.impulse
  end

  def calc_directions
    if state.hero.moving == :left
      state.hero.x -= RL_SPEED
      state.hero.flip_horizontally = false
    elsif state.hero.moving == :right
      state.hero.x += RL_SPEED
      state.hero.flip_horizontally = true
    end
    state.hero.ascending = state.hero.y - state.at_calc_start.y < 0 ? false : true
  end

  def calc_platform_collision
    sprite_index = 0.frame_index(2, 9, true)
    state.hero.path = "sprites/hero-flying-#{sprite_index}.png"

    if p = Geometry.find_intersect_rect(state.hero, state.platforms)
      if (state.at_calc_start.x + state.hero.w) < p.x
        state.hero.x = state.at_calc_start.x
      elsif state.at_calc_start.x >= (p.x + p.w)
        state.hero.x = state.at_calc_start.x
      elsif state.hero.ascending
        state.hero.y = p.y - state.hero.h - 2
      else
        state.hero.path = 'sprites/hero-standing.png'
        state.hero.y = p.y + p.h
      end
    end
  end

  def calc_alien_collision
    if a = Geometry.find_intersect_rect(state.hero, state.aliens)
      @game_over = true
    end
  end

  def calc_picking_fuel
    state.fuel.each do |f|
      if state.hero.intersect_rect?(f)
        state.hero.jetpack_power += 20
        state.hero.jetpack_power = state.hero.jetpack_power.clamp(0, 100)
        f.used = true
        audio[:fuel] = { input: "sounds/fuel.mp3" }
        break
      end
    end
    state.fuel.reject!(&:used)
  end

  def calc_picking_ore
    state.ores.each do |o|
      if state.hero.ore == 0 && state.hero.intersect_rect?(o)
        o.used = true
        state.hero.ore = 1
        audio[:gold] = { input: "sounds/gold.wav" }
        break
      end
    end
    state.ores.reject!(&:used)
  end

  def calc_collecting_ore
    if state.hero.ore == 1 && state.hero.intersect_rect?(state.collector)
      state.hero.ore = 0
      state.level.remaining_ores -= 1
      state.level.completed = true if state.level.remaining_ores == 0
      audio[:collect] = { input: "sounds/collect.wav" }
    end
  end

  def calc_shoot
    if state.hero.shooting
      state.shoots << {
        x: state.hero.x,
        y: state.hero.y + 20,
        w: 24,
        h: 10,
        path: 'sprites/laser.png',
        dead: false,
        speed: state.hero.facing == :right ? LASER_SPEED : -LASER_SPEED,
        animation_counter: LASER_ANIMATION,
        flip_vertically: false,
      }
      state.hero.shooting = false
      state.hero.last_shoot_at = Kernel.tick_count
    end

    state.shoots.each do |shoot|
      shoot.animation_counter -= 1
      if shoot.animation_counter == 0
        shoot.animation_counter = LASER_ANIMATION
        shoot.flip_vertically = !shoot.flip_vertically
      end
      shoot.x += shoot.speed
      shoot.dead = true if shoot.x > Grid.w || shoot.x < 0

      state.aliens.each do |a|
        if shoot.intersect_rect?(a)
          shoot.dead = true
          a.dead = true
        end
      end
    end
    state.shoots.reject!(&:dead)
  end

  def calc_clamp
    state.hero.x = state.hero.x.clamp(0, Grid.w - state.hero.w)
    state.hero.y = state.hero.y.clamp(0, Grid.h - state.hero.h)
  end
end

$game = Game.new

def tick(args)
  $game.args = args
  $game.tick
end
