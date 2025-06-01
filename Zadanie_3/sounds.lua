local sounds = {
    lineSound = love.audio.newSource("sounds/line.wav", "static"),
    moveSound = love.audio.newSource("sounds/move.wav", "static"),
    rotateSound = love.audio.newSource("sounds/rotate.wav", "static"),
    buttonClickSound = love.audio.newSource("sounds/button_click.wav", "static"),
    placedSound = love.audio.newSource("sounds/placed.wav", "static"),
    gameOverSound = love.audio.newSource("sounds/game_over.wav", "static")
}

return sounds