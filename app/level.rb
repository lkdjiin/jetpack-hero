class Level
  attr_gtk
  attr_accessor :animation_started_at, :animation_phase, :bonus_points, :time

  TIME = 120

  def initialize(args, remaining_ores:)
    @args = args
    @remaining_ores = remaining_ores
    @completed = false
    @time = TIME

    # Bonus
    @bonus_points = 0
    @animation_phase = 1
    @animation_started_at = nil
  end

  def new_level(remaining_ores:)
    @remaining_ores = remaining_ores
    @completed = false
    @time = TIME
    @bonus_points = 0
    @animation_phase = 1
    @animation_started_at = nil
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

  def calc
    if Kernel.tick_count % 60 == 0
      @time -= 1
      audio[:time] = { input: "sounds/time.wav" } if @time <= 10
    end
  end
end
