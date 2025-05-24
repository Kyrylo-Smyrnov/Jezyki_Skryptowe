local blocks = require("blocks")
local consts = require("consts")
local field = require("field")
local logic = require("logic")
local vars = require("vars")

function love.load()
    love.window.setTitle("TETRIS")
    love.window.setMode(consts.WINDOW_WIDTH, consts.WINDOW_HEIGHT, {resizable = false, fullscreen = false})

    local font = love.graphics.newFont(30)
    love.graphics.setFont(font)

    local firstBlockNum = logic.generateNextBlockNum()
    vars.currentBlock.shape = blocks[firstBlockNum].shape
    vars.currentBlock.color = blocks[firstBlockNum].color
    vars.currentBlock.x = consts.BLOCK_START_POINT.x
    vars.currentBlock.y = consts.BLOCK_START_POINT.y
end

function love.update(dt)
    if not vars.gameOver then
        if love.keyboard.isDown("down") then
            logic.updateTimer(dt * 10)
        else
            logic.updateTimer(dt)
        end
    end
end

function love.draw()
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
            end
        end
    end

    for y = 1, 4 do
        for x = 1, 4 do
            if vars.currentBlock.shape[y][x] == 1 then
                love.graphics.setColor(vars.currentBlock.color)
                love.graphics.rectangle("fill", vars.currentBlock.x + (x - 1) * consts.BLOCK_SIZE,
                                                vars.currentBlock.y + (y - 1) * consts.BLOCK_SIZE,
                                                consts.BLOCK_SIZE, consts.BLOCK_SIZE, nil, nil, nil)
            end
        end
    end

    love.graphics.setColor(consts.SCORE_COLOR)
    local text = vars.score
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()

    love.graphics.print(text, (consts.WINDOW_WIDTH - textWidth) / 2, consts.WINDOW_HEIGHT / 2 - (consts.FIELD_HEIGHT / 2) * consts.BLOCK_SIZE - textHeight - consts.BLOCK_SIZE)

    if vars.gameOver then
        local msg = "Game Over"
        local scoreMsg = "Final Score: " .. vars.score

        local font = love.graphics.getFont()

        local textWidth = font:getWidth(msg)
        local scoreWidth = font:getWidth(scoreMsg)
        local textHeight = font:getHeight()

        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, consts.WINDOW_WIDTH, consts.WINDOW_HEIGHT, nil, nil, nil)

        love.graphics.setColor(1, 0, 0)
        love.graphics.print(msg, (consts.WINDOW_WIDTH - textWidth) / 2, consts.WINDOW_HEIGHT / 2 - textHeight)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(scoreMsg, (consts.WINDOW_WIDTH - scoreWidth) / 2, consts.WINDOW_HEIGHT / 2 + 5)
    end
end

function love.keypressed(key)
    logic.handleInput(key)
end