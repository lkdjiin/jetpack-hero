HERO_SCALE = 4

def tick args
  args.state.hero ||= {
    x: 600,
    y: 40,
    w: 7 * HERO_SCALE,
    h: 17 * HERO_SCALE,
    path: 'sprites/hero.png'
  }

  if args.inputs.left
    args.state.hero.x -= 5
  elsif args.inputs.right
    args.state.hero.x += 5
  end

  if args.inputs.up
    args.state.hero.y += 5
  elsif args.inputs.down
    args.state.hero.y -= 5
  end

  args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0 }
  args.outputs.sprites << args.state.hero
end
