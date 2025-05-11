HERO_SCALE = 4 # Image ratio
ALIEN_SCALE = 1.5
ALIEN_W  = 50 * ALIEN_SCALE
ALIEN_H = 35 * ALIEN_SCALE
FALL = -2.8 # Kind of gravity
RL_SPEED = 5 # Right/left speed
IMPULSE = 8 # Jetpack power
IMPULSE_DECREASE = 0.9 # Jetpack power ratio decrease per frame
LASER_SPEED = 7
FIRE_RATE = 30 # Maximum is one shot every FIRE_RATE frames
LASER_ANIMATION = 10
ALIEN_ANIMATION = 15

require 'app/level.rb'
require 'app/collector.rb'
require 'app/fuel.rb'
require 'app/ore.rb'
require 'app/fuel_and_shot_collision.rb'
require 'app/hero_and_fuel_collision.rb'
require 'app/hero_and_ore_collision.rb'
require 'app/info_zone.rb'
require 'app/levels.rb'

class Game
  attr_gtk

  def initialize
    @game_over = false
    @level_number = 1
  end

  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    return if Kernel.tick_count > 0

    state.hero ||= {
      x: 120,
      y: 700,
      w: 7 * HERO_SCALE,
      h: 17 * HERO_SCALE,
      path: 'sprites/hero-flying-0.png',
      flip_horizontally: true,
      impulse: 0,
      moving: :none,
      facing: :right,
      jetpack_power: 100,
      ore: 0,
      ascending: false,
      shooting: false,
      last_shot_at: 0,
    }

    state.platforms ||= Levels[@level_number].platforms
    state.fuels ||= Levels[@level_number].fuels
    state.ores ||= Levels[@level_number].ores
    state.collector ||= Collector.new(@args)
    state.level ||=  Level.new(@args, remaining_ores: Levels[@level_number].ores_to_pick)

    state.aliens ||= []
    state.aliens_apparition ||= []
    state.aliens_disparition ||= []
    state.aliens_pool ||= Levels[@level_number].pool

    state.shots ||= []

    state.score ||= 0
    state.lives ||= 3
    state.info_zone ||= InfoZone.new(@args)
  end

  def render
    outputs.solids << { x: 0, y: 130, w: 1280, h: 610, r: 0, g: 0, b: 0 }
    state.info_zone.render

    if state.level.complete?
      render_level_complete_animation
      return
    end

    outputs.sprites << state.platforms
    outputs.sprites << state.fuels
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
    state.collector.render
    outputs.sprites << state.aliens_apparition
    outputs.sprites << state.aliens
    outputs.sprites << state.aliens_disparition
    outputs.sprites << state.shots

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

  def render_level_complete_animation
    if state.level.animation_phase == 1
      outputs.labels << {
        x: 640,
        y: 360,
        size_px: 120,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: "Level Completed!",
        r: 255, g: 255, b: 255,
      }
    elsif state.level.animation_phase == 2 || state.level.animation_phase == 3
      outputs.labels << {
        x: 640,
        y: 560,
        size_px: 120,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: "Bonus Points",
        r: 255, g: 255, b: 255,
      }
      outputs.labels << {
        x: 640,
        y: 360,
        size_px: 120,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: state.level.bonus_points,
        r: 255, g: 255, b: 255,
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
    return if state.level.complete?

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
        state.hero.jetpack_power -= 0.2
        audio[:jetpack] = { input: "sounds/jetpack.wav" } unless audio[:jetpack]
      end
    end

    if inputs.keyboard.alt || inputs.controller_one.b
      if state.hero.last_shot_at + FIRE_RATE < Kernel.tick_count
        state.hero.shooting = true
        audio[:laser] = { input: 'sounds/laser.wav' }
      end
    end
  end

  def calc
    return if @game_over

    if state.level.complete?
      calc_level_complete_animation
      return
    end

    calc_init
    calc_level
    calc_aliens
    calc_hero_y_position
    calc_directions
    calc_platform_collision
    calc_alien_collision
    calc_picking_fuel
    calc_picking_ore
    calc_collecting_ore
    calc_shot
    calc_fuel
    calc_clamp
  end

  def calc_level_complete_animation
    if state.level.animation_phase == 1
      if state.level.animation_started_at.nil?
        state.level.animation_started_at = Kernel.tick_count
      else
        if Kernel.tick_count > state.level.animation_started_at + 60
          state.level.animation_phase = 2
          state.level.animation_started_at = Kernel.tick_count
        end
      end
    elsif state.level.animation_phase == 2
      # each 6 frames (0.1 second)
      if Kernel.tick_count > state.level.animation_started_at + 6
        state.level.time -= 1
        state.level.animation_started_at = Kernel.tick_count
        state.level.bonus_points += 500
        audio[:gold] = { input: "sounds/gold.wav" }
        if state.level.time == 0
          state.score += state.level.bonus_points
          state.level.animation_phase = 3
        end
      end
    elsif state.level.animation_phase == 3
      if Kernel.tick_count > state.level.animation_started_at + 60
        next_level
      end
    end
  end

  def calc_init
    state.at_calc_start = {
      x: state.hero.x,
      y: state.hero.y,
    }
  end

  def calc_level
    state.level.calc

    if state.level.time_is_up?
      state.level.reset_time
      life_lost
    end
  end

  def calc_aliens
    state.aliens_pool.each do |alien|
      if alien.alive == false && rand(700) == 0
        alien.alive = true
        state.aliens_apparition << alien.dup.merge({
          x: rand(alien.x_max - alien.x_min) + alien.x_min,
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
        state.score += 100
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
        if state.hero.moving != :none
          sprite_index = 0.frame_index(8, 5, true)
          state.hero.path = "sprites/hero-running-#{sprite_index}.png"
        end
      end
    end
  end

  def calc_alien_collision
    if a = Geometry.find_intersect_rect(state.hero, state.aliens)
      life_lost
    end
  end

  def life_lost
    state.lives -= 1
    if state.lives == 0
      @game_over = true
      audio[:game_over] = { input: "sounds/game-over.wav" }
      return
    end
    audio[:live_down] = { input: "sounds/life-lost.wav" }
    state.hero.x = 120
    state.hero.y = 700
  end

  def calc_picking_fuel
    state.fuels.each do |f|
      if HeroAndFuelCollision.detect(state.hero, f)
        audio[:fuel] = { input: "sounds/fuel.mp3" }
        state.score += 10
        break
      end
    end
    state.fuels.reject!(&:used)
  end

  def calc_picking_ore
    state.ores.each do |o|
      if HeroAndOreCollision.detect(state.hero, o)
        audio[:gold] = { input: "sounds/gold.wav" }
        state.score += 50
        break
      end
    end
    state.ores.reject!(&:used)
  end

  def calc_collecting_ore
    if state.hero.ore == 1 && state.hero.intersect_rect?(state.collector)
      state.hero.ore = 0
      state.level.collect_one_ore
      audio[:collect] = { input: "sounds/collect.wav" }
      state.score += 1_000
    end
  end

  def calc_shot
    if state.hero.shooting
      state.shots << {
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
      state.hero.last_shot_at = Kernel.tick_count
    end

    state.shots.each do |shot|
      shot.animation_counter -= 1
      if shot.animation_counter == 0
        shot.animation_counter = LASER_ANIMATION
        shot.flip_vertically = !shot.flip_vertically
      end
      shot.x += shot.speed
      shot.dead = true if shot.x > Grid.w || shot.x < 0

      state.aliens.each do |a|
        if shot.intersect_rect?(a)
          shot.dead = true
          a.dead = true
        end
      end

      state.fuels.each do |f|
        if FuelAndShotCollision.detect(f, shot)
          args.audio[:explosion_fuel] = { input: "sounds/explosion2.wav" }
          break
        end
      end
    end
    state.shots.reject!(&:dead)
  end

  def calc_fuel
    state.fuels.each(&:calc)
  end

  def calc_clamp
    state.hero.x = state.hero.x.clamp(0, Grid.w - state.hero.w)
    state.hero.y = state.hero.y.clamp(0, Grid.h - state.hero.h)
  end

  def next_level
    @level_number += 1
    # FIXME Is there another level or is it the last?

    state.platforms = Levels[@level_number].platforms
    state.fuels = Levels[@level_number].fuels
    state.ores = Levels[@level_number].ores
    state.aliens_pool = Levels[@level_number].pool
    state.aliens = []

    state.level.new_level(remaining_ores: Levels[@level_number].ores_to_pick)
  end
end

$game = Game.new

def tick(args)
  $game.args = args
  $game.tick
end
