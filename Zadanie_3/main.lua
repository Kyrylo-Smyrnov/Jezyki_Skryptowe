local blocks = require("blocks")
local consts = require("consts")
local field = require("field")
local logic = require("logic")
local vars = require("vars")
local sounds = require("sounds")

local menuBackground = nil
local gameBackground = nil
local gameOverBackground = nil

function love.load()
    love.window.setTitle("TETRIS")
    love.window.setMode(consts.WINDOW_WIDTH, consts.WINDOW_HEIGHT, {resizable = false, fullscreen = false})


    local font = love.graphics.newFont("font.ttf", 30)
    love.graphics.setFont(font)

    menuBackground = love.graphics.newImage("sprites/menu_background.png")
    gameBackground = love.graphics.newImage("sprites/game_background.png")
    gameOverBackground = love.graphics.newImage("sprites/game_over_background.png")
end

local function drawMenu()
    love.graphics.draw(menuBackground, 0, 0)
    love.graphics.setColor(1, 1, 1)
end

function love.update(dt)
    if vars.gameState == "game" then
        if vars.isGameStarted == false then
            logic.startGame()
            vars.isGameStarted = true
        end

        if not vars.gameOver then
            if love.keyboard.isDown("down") then
                logic.updateTimer(dt * 10)
            else
                logic.updateTimer(dt)
            end
        end
    end
end

local function drawGame()
    love.graphics.draw(gameBackground, 0, 0)

    for y = 1, consts.FIELD_HEIGHT do
        for x = 1, consts.FIELD_WIDHT do
            if field[y][x] == 0 then
                love.graphics.setColor(consts.FIELD_BACKGROUND_COLOR)
                love.graphics.rectangle("fill", (x - 1) * consts.BLOCK_SIZE + (consts.WINDOW_WIDTH / 2 - consts.BLOCK_SIZE * consts.FIELD_WIDHT / 2),
                                                (y - 1) * consts.BLOCK_SIZE + (consts.WINDOW_HEIGHT / 2 - consts.BLOCK_SIZE * consts.FIELD_HEIGHT / 2),
                                                consts.BLOCK_SIZE, consts.BLOCK_SIZE, nil, nil, nil)
            else
                if field[y][x] == 1 then
                    love.graphics.setColor({0, 0, 1})
                elseif field[y][x] == 2 then
                    love.graphics.setColor({0, 1, 0})
                elseif field[y][x] == 3 then
                    love.graphics.setColor({0, 1, 1})
                elseif field[y][x] == 4 then
                    love.graphics.setColor({1, 0, 0})
                elseif field[y][x] == 5 then
                    love.graphics.setColor({1, 0, 1})
                elseif field[y][x] == 6 then
                    love.graphics.setColor({1, 1, 0})
                end
                love.graphics.rectangle("fill", (x - 1) * consts.BLOCK_SIZE + (consts.WINDOW_WIDTH / 2 - consts.BLOCK_SIZE * consts.FIELD_WIDHT / 2),
                                                (y - 1) * consts.BLOCK_SIZE + (consts.WINDOW_HEIGHT / 2 - consts.BLOCK_SIZE * consts.FIELD_HEIGHT / 2),
                                                consts.BLOCK_SIZE, consts.BLOCK_SIZE, nil, nil, nil)

                local blink = not vars.clearing or (math.floor(love.timer.getTime() * 10) % 2 == 0)

                if vars.clearedRows and vars.clearedRows[y] == true and blink then
                    love.graphics.setColor(1, 1, 1, 0.7)
                    love.graphics.rectangle("fill", (x - 1) * consts.BLOCK_SIZE + (consts.WINDOW_WIDTH / 2 - consts.BLOCK_SIZE * consts.FIELD_WIDHT / 2), 
                                                    (y - 1) * consts.BLOCK_SIZE + (consts.WINDOW_HEIGHT / 2 - consts.BLOCK_SIZE * consts.FIELD_HEIGHT / 2),
                                                    consts.BLOCK_SIZE, consts.BLOCK_SIZE)
                end
            end
        end
    end

    if not vars.clearing then
        for y = 1, 4 do
            for x = 1, 4 do
                if vars.currentBlock.shape[y][x] == 1 then
                    love.graphics.setColor(vars.currentBlock.color)
                    love.graphics.rectangle("fill",
                        vars.currentBlock.x + (x - 1) * consts.BLOCK_SIZE,
                        vars.currentBlock.y + (y - 1) * consts.BLOCK_SIZE,
                        consts.BLOCK_SIZE, consts.BLOCK_SIZE)
                end
            end
        end
    end

    love.graphics.setColor(consts.SCORE_COLOR)
    local text = vars.score
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()

    love.graphics.print(text, (consts.WINDOW_WIDTH - textWidth) / 2, consts.WINDOW_HEIGHT / 2 - (consts.FIELD_HEIGHT / 2) * consts.BLOCK_SIZE - textHeight - consts.BLOCK_SIZE)
end

function drawGameOver()
    love.graphics.draw(gameOverBackground, 0, 0)

    local msg = "Game Over"
    local scoreMsg = vars.score

    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    local scoreWidth = font:getWidth(scoreMsg)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(scoreMsg, (consts.WINDOW_WIDTH - scoreWidth) / 2, 350)
end

function love.draw()
    if(vars.gameState == "menu") then
        drawMenu()
    elseif (vars.gameState == "game") then
        drawGame()
        if(vars.gameOver) then
            drawGameOver()
        end
    end
end

function love.mousepressed(x, y, button)
    if vars.gameState == "menu" and button == 1 then
        if x >= 300 and x <= 500 and y >= 300 and y <= 350 then
            sounds.buttonClickSound:play()
            vars.gameState = "game"
            vars.isGameStarted = false
        elseif x >= 300 and x <= 500 and y >= 400 and y <= 450 then
            sounds.buttonClickSound:play()
            logic.loadGame()
            vars.isGameStarted = true
            vars.gameState = "game"
        end
    end
    if vars.gameOver == true and button == 1 then
        if x >= 300 and x <= 500 and y >= 500 and y <= 550 then
            sounds.buttonClickSound:play()
            vars.gameState = "menu"
        end
    end
end

local function handleKey(key)
    local newX = vars.currentBlock.x
    local newY = vars.currentBlock.y
    local shape = vars.currentBlock.shape

    if key == "left" then
        newX = vars.currentBlock.x - consts.BLOCK_SIZE
    elseif key == "right" then
        newX = vars.currentBlock.x + consts.BLOCK_SIZE
    elseif key == "space" then
        local rotated = logic.rotateClockwise(shape)
        if logic.canPlaceShapeAt(rotated, newX, newY) then
            vars.currentBlock.shape = rotated
            sounds.rotateSound:play()
        end
        return
    elseif key == "s" then
        logic.saveGame()
    end

    if logic.canPlaceShapeAt(shape, newX, newY) then
        vars.currentBlock.x = newX
        sounds.moveSound:play()
    end
end

local function handleTouchInput(x, y)
    local minY = consts.WINDOW_HEIGHT - 100

    if x >= 50 and x <= 150 and y >= minY and y <= minY + 80 then
        handleKey("left")
    elseif x >= 200 and x <= 300 and y >= minY and y <= minY + 80 then
        handleKey("right")
    elseif x >= 350 and x <= 450 and y >= minY and y <= minY + 80 then
        handleKey("space")
    end
end

function love.touchpressed(id, tx, ty, dx, dy, pressure)
    local x = tx * consts.WINDOW_WIDTH
    local y = ty * consts.WINDOW_HEIGHT

    if vars.gameState == "menu" then
        if x >= 300 and x <= 500 and y >= 300 and y <= 350 then
            sounds.buttonClickSound:play()
            vars.gameState = "game"
            vars.isGameStarted = false
        elseif x >= 300 and x <= 500 and y >= 400 and y <= 450 then
            sounds.buttonClickSound:play()
            logic.loadGame()
            vars.isGameStarted = true
            vars.gameState = "game"
        end
    elseif vars.gameOver == true then
        if x >= 300 and x <= 500 and y >= 500 and y <= 550 then
            sounds.buttonClickSound:play()
            vars.gameState = "menu"
        end
    else
        handleTouchInput(x, y)
    end
end

function love.keypressed(key)
    handleKey(key)
end