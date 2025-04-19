HERO_SCALE = 4

def tick args
  args.state.player_x ||= 600
  args.state.player_y ||= 40

  hero ||= {
    x: args.state.player_x,
    y: args.state.player_y,
    w: 7 * HERO_SCALE,
    h: 17 * HERO_SCALE,
    path: 'sprites/hero.png'
  }

  if args.inputs.left
    args.state.player_x -= 5
  elsif args.inputs.right
    args.state.player_x += 5
  end

  if args.inputs.up
    args.state.player_y += 5
  elsif args.inputs.down
    args.state.player_y -= 5
  end

  args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0 }
  args.outputs.sprites << hero
end
