module Levels
  def self.[](number)
    store[number - 1]
  end

  def self.store
    [
      # Level 1
      {
        platforms: [
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
        ],
        fuels: [
          Fuel.new(x: 800, y: 142),
          Fuel.new(x: 700, y: 142),
          Fuel.new(x: 600, y: 142),
          Fuel.new(x: 700, y: 282),
          Fuel.new(x: 700, y: 432),
          Fuel.new(x: 700, y: 582),
        ],
        ores_to_pick: 10,
        ores: [
          Ore.new(x: 1220, y: 282),
          Ore.new(x: 500, y: 282),
          Ore.new(x: 10, y: 282),
          Ore.new(x: 10, y: 432),
          Ore.new(x: 800, y: 432),
          Ore.new(x: 1220, y: 432),
          Ore.new(x: 800, y: 582),
          Ore.new(x: 1220, y: 582),
          Ore.new(x: 10, y: 142),
          Ore.new(x: 1220, y: 142),
        ],
        pool: [
          { x: 420, y: 582, w: ALIEN_W, h: ALIEN_H, alive: false, id: 0, speed: 5.1, x_min: 410, x_max: 1_000 },
          { x: 80, y: 432, w: ALIEN_W, h: ALIEN_H, alive: false, id: 1, speed: 1.8, x_min: 50, x_max: 120 },
          { x: 700, y: 432, w: ALIEN_W, h: ALIEN_H, alive: false, id: 2, speed: -3.8, x_min: 410, x_max: 1_000 },
          { x: 80, y: 282, w: ALIEN_W, h: ALIEN_H, alive: false, id: 3, speed: 1.7, x_min: 50, x_max: 120 },
          { x: 900, y: 282, w: ALIEN_W, h: ALIEN_H, alive: false, id: 4, speed: 4.7, x_min: 410, x_max: 1_000 },
          { x: 200, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 5, speed: 6, x_min: 50, x_max: 1_200 },
          { x: 900, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 6, speed: -4.9, x_min: 50, x_max: 1_200 },
        ],
      },
      # Level 2
      {
        platforms: [
          { x: 0, y: 570, w: 200, h: 12, path: 'sprites/tile.png' },
          { x: 0, y: 130, w: 1280, h: 12, path: 'sprites/tile.png' },
        ],
        fuels: [
          Fuel.new(x: 800, y: 142),
          Fuel.new(x: 700, y: 142),
          Fuel.new(x: 600, y: 142),
        ],
        ores_to_pick: 2,
        ores: [
          Ore.new(x: 10, y: 142),
          Ore.new(x: 1220, y: 142),
        ],
        pool: [
          { x: 200, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 0, speed: 3.5, x_min: 50, x_max: 1_200 },
          { x: 900, y: 142, w: ALIEN_W, h: ALIEN_H, alive: false, id: 1, speed: -2.9, x_min: 50, x_max: 1_200 },
        ],
      },
      # Level n
      {},
    ]
  end
end
