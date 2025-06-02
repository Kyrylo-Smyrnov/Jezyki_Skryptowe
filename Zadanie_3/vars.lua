local vars = {}

vars.currentBlock = {
    id, shape = {}, x, y
}

vars.fallTimer = 0.5
vars.score = 0
vars.clearingTimer = 0
vars.clearing = false
vars.clearedRows = {}
vars.gameOver = false
vars.gameState = "menu"
vars.isGameStarted = false

return vars