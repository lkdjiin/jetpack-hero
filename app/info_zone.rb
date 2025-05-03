class InfoZone
  attr_gtk

  def initialize(args)
    # One can read all what we want from `@args`, but one MUST NOT modify
    # anything.
    @args = args
  end

  def render
    outputs.solids << { x: 0, y: 0, w: 1280, h: 130, r: 60, g: 60, b: 70 }
    outputs.solids << { x: 305, y: 74, w: 600, h: 27, r: 255, g: 0, b: 0 }
    outputs.solids << { x: 305, y: 74, w: state.hero.jetpack_power * 6, h: 27, r: 255, g: 255, b: 0 }

    outputs.labels << {
      x: 200,
      y: 65,
      size_px: 40,
      alignment_enum: 0,
      vertical_alignment_enum: 0,
      text: "POWER",
      r: 255,
      g: 255,
      b: 255,
    }

    outputs.labels << {
      x: 900,
      y: 10,
      size_px: 55,
      alignment_enum: 2,
      vertical_alignment_enum: 0,
      text: state.score,
      r: 255,
      g: 255,
      b: 255,
    }

    state.lives.times do |i|
      outputs.sprites << {
        x: 1_000 + i * 80,
        y: 50,
        w: 7 * 3,
        h: 17 * 3,
        path: 'sprites/hero-flying-0.png'
      }
    end

    outputs.labels << {
      x: 40,
      y: 110,
      size_px: 70,
      text: state.level.time,
      r: 255, g: 255, b: 255,
    }
  end
end
