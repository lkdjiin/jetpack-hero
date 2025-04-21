HERO_SCALE = 4 # Image ratio
FALL = -1.2 # Kind of gravity
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
    x: 600,
    y: 200,
    w: 7 * HERO_SCALE,
    h: 17 * HERO_SCALE,
    path: 'sprites/hero.png',
    impulse: 0,
  }
end

def render(args)
  args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0 }
  args.outputs.sprites << args.state.hero
end

def input(args)
  if args.inputs.left
    args.state.hero.x -= RL_SPEED
  elsif args.inputs.right
    args.state.hero.x += RL_SPEED
  end

  if args.inputs.keyboard.control || args.inputs.controller_one.y
    args.state.hero.impulse = IMPULSE
  end
end

def calc(args)
  args.state.hero.impulse *= IMPULSE_DECREASE
  args.state.hero.y += FALL
  args.state.hero.y += args.state.hero.impulse
  args.state.hero.x = args.state.hero.x.clamp(0, Grid.w - args.state.hero.w)
  args.state.hero.y = args.state.hero.y.clamp(0, Grid.h - args.state.hero.h)
end
