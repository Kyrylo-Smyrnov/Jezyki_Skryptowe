local vars = {}

vars.currentBlock = {
    id, shape = {}, x, y
}

vars.fallTimer = 0.5
vars.score = 0
vars.gameOver = false
vars.gameState = "menu"
vars.isGameStarted = false

return vars