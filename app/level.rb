class Level
  attr_gtk
  attr_reader :time

  TIME = 120

  def initialize(args)
    @args = args
    @remaining_ores = 10
    @completed = false
    @time = TIME
  end

  def complete?
    @completed
  end

  def time_is_up?
    @time == 0
  end

  def reset_time
    @time = TIME
  end

  def collect_one_ore
    @remaining_ores -= 1
    @completed = true if @remaining_ores == 0
  end

  def render
    if complete?
      outputs.labels << {
        x: 640,
        y: 360,
        size_px: 120,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        text: "Level Completed!",
        r: 255, g: 255, b: 255,
      }
    end
  end

  def calc
    if Kernel.tick_count % 60 == 0
      @time -= 1
      audio[:time] = { input: "sounds/time.wav" } if @time <= 10
    end
  end
end
