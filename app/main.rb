HERO_SCALE = 4 # Image ratio
FALL = -1.8 # Kind of gravity
RL_SPEED = 5 # Right/left speed
IMPULSE = 4 # Jetpack power
IMPULSE_DECREASE = 0.9 # Jetpack power ratio decrease per frame

def tick(args)
  defaults(args)
  render(args)
  input(args)
  calc(args)
end

def defaults(args)
  args.state.hero ||= {
    x: 120,
    y: 700,
    w: 7 * HERO_SCALE,
    h: 17 * HERO_SCALE,
    path: 'sprites/hero-flying.png',
    flip_horizontally: true,
    impulse: 0,
    moving: :none,
    jetpack_power: 100,
    ore: 0,
  }

  args.state.platforms ||= [
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

  args.state.fuel ||= [
    { x:700, y: 282, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
    { x:700, y: 582, w: 25, h: 30, path: 'sprites/fuel.png', used: false },
  ]

  args.state.ores ||= [
    { x:1220, y: 282, w: 30, h: 27, path: 'sprites/gold.png', used: false },
    { x:800, y: 432, w: 30, h: 27, path: 'sprites/gold.png', used: false },
    { x:1220, y: 432, w: 30, h: 27, path: 'sprites/gold.png', used: false },
    { x:800, y: 582, w: 30, h: 27, path: 'sprites/gold.png', used: false },
    { x:1220, y: 582, w: 30, h: 27, path: 'sprites/gold.png', used: false },
  ]

  args.state.collector ||= { x:0, y: 582, w: 80, h: 80, path: 'sprites/collector.png' }

  args.state.level ||= {
    remaining_ores: 5,
    completed: false,
  }
end

def render(args)
  args.outputs.solids << { x: 0, y: 130, w: 1280, h: 610, r: 0, g: 0, b: 0 }
  args.outputs.solids << { x: 0, y: 0, w: 1280, h: 130, r: 60, g: 60, b: 70 }
  args.outputs.solids << { x: 305, y: 54, w: 600, h: 27, r: 255, g: 0, b: 0 }
  args.outputs.solids << { x: 305, y: 54, w: args.state.hero.jetpack_power * 6, h: 27, r: 255, g: 255, b: 0 }
  args.outputs.sprites << args.state.platforms
  args.outputs.sprites << args.state.fuel
  args.outputs.sprites << args.state.ores
  if args.state.hero.ore == 1
    args.outputs.sprites << {
      x: args.state.hero.x,
      y: args.state.hero.y,
      w: 30, h: 40, path: 'sprites/gold.png'
    }
  end
  args.outputs.sprites << args.state.hero
  args.outputs.sprites << args.state.collector
  args.outputs.labels << {
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
  if args.state.level.completed
    args.outputs.labels << {
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
end

def input(args)
  if args.inputs.left
    args.state.hero.moving = :left
  elsif args.inputs.right
    args.state.hero.moving = :right
  else
    args.state.hero.moving = :none
  end

  if args.inputs.keyboard.control || args.inputs.controller_one.y
    if args.state.hero.jetpack_power > 0
      args.state.hero.impulse = IMPULSE
      args.state.hero.jetpack_power -= 0.1
      args.audio[:jetpack] = { input: "sounds/jetpack.wav" } unless args.audio[:jetpack]
    end
  end
end

def calc(args)
  y_before = args.state.hero.y
  x_before = args.state.hero.x

  args.state.hero.path = 'sprites/hero-flying.png'
  args.state.hero.impulse *= IMPULSE_DECREASE
  args.state.hero.y += FALL
  args.state.hero.y += args.state.hero.impulse

  if args.state.hero.moving == :left
    args.state.hero.x -= RL_SPEED
    args.state.hero.flip_horizontally = false
  elsif args.state.hero.moving == :right
    args.state.hero.x += RL_SPEED
    args.state.hero.flip_horizontally = true
  end

  if args.state.hero.y - y_before < 0
    ascending = false
  else
    ascending = true
  end

  if p = Geometry.find_intersect_rect(args.state.hero, args.state.platforms)
    if (x_before + args.state.hero.w) < p.x
      args.state.hero.x = x_before
    elsif x_before >= (p.x + p.w)
      args.state.hero.x = x_before
    elsif ascending
      args.state.hero.y = p.y - args.state.hero.h - 2
    else
      args.state.hero.path = 'sprites/hero-standing.png'
      args.state.hero.y = p.y + p.h
    end
  end

  args.state.fuel.each do |f|
    if args.state.hero.intersect_rect?(f)
      args.state.hero.jetpack_power += 20
      args.state.hero.jetpack_power = args.state.hero.jetpack_power.clamp(0, 100)
      f.used = true
      args.audio[:fuel] = { input: "sounds/fuel.mp3" }
    end
  end
  args.state.fuel.reject!(&:used)

  args.state.ores.each do |o|
    if args.state.hero.ore == 0 && args.state.hero.intersect_rect?(o)
      o.used = true
      args.state.hero.ore = 1
      args.audio[:gold] = { input: "sounds/gold.wav" }
    end
  end
  args.state.ores.reject!(&:used)

  if args.state.hero.ore == 1 && args.state.hero.intersect_rect?(args.state.collector)
    args.state.hero.ore = 0
    args.state.level.remaining_ores -= 1
    args.state.level.completed = true if args.state.level.remaining_ores == 0
    args.audio[:collect] = { input: "sounds/collect.wav" }
  end

  args.state.hero.x = args.state.hero.x.clamp(0, Grid.w - args.state.hero.w)
  args.state.hero.y = args.state.hero.y.clamp(0, Grid.h - args.state.hero.h)
end
