class Enemy
  def initialize(x, y)
    @x = x
    @y = y
    @sprite = Sprite.new('sprites/goomba.png', x: @x, y: @y, height: 40, width: 40, clip_width: 16, time: 300, loop: true)
    @sprite.play
  end

  def sprite
    @sprite
  end

  def remove
    @sprite.remove
  end
end