local logic = {}

local blocks = require("blocks")
local consts = require("consts")
local field = require("field")
local vars = require("vars")

local function checkBlockCollision ()
    for y = 1, 4 do
        for x = 1, 4 do
            if vars.currentBlock.shape[y][x] == 1 then
                local fieldX = math.floor((vars.currentBlock.x - consts.FIELD_START_POINT.x + (x - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1
                local fieldY = math.floor((vars.currentBlock.y - consts.FIELD_START_POINT.y + (y - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1

                if fieldY >= consts.FIELD_HEIGHT or field[fieldY + 1][fieldX] ~= 0 then
                    return true
                end
            end
        end
    end

    return false
end

local function isSameColor(a, b)
    return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

local function clearFilledRows()
    local clearedRows = 0
    local y = consts.FIELD_HEIGHT

    while y >= 1 do
        local full = true
        for x = 1, consts.FIELD_WIDHT do
            if field[y][x] == 0 then
                full = false
                break
            end
        end

        if full then
            for moveY = y, 2, -1 do
                for x = 1, consts.FIELD_WIDHT do
                    field[moveY][x] = field[moveY - 1][x]
                end
            end

            for x = 1, consts.FIELD_WIDHT do
                field[1][x] = 0
            end
            clearedRows = clearedRows + 1
        else
            y = y - 1
        end
    end

    vars.score = vars.score + clearedRows * 100
end

local function mapBlockIntoField()
    local color = 0

    for y = 1, 4 do
        for x = 1, 4 do
            if vars.currentBlock.shape[y][x] == 1 then
                if color == 0 then
                    if isSameColor(vars.currentBlock.color, {0, 0, 1}) then
                        color = 1
                    elseif isSameColor(vars.currentBlock.color, {0, 1, 0}) then
                        color = 2
                    elseif isSameColor(vars.currentBlock.color, {0, 1, 1}) then
                        color = 3
                    elseif isSameColor(vars.currentBlock.color, {1, 0, 0}) then
                        color = 4
                    elseif isSameColor(vars.currentBlock.color, {1, 0, 1}) then
                        color = 5 
                    elseif isSameColor(vars.currentBlock.color, {1, 1, 0}) then
                        color = 6 
                    end
                end

                local fieldX = math.floor((vars.currentBlock.x - consts.FIELD_START_POINT.x + (x - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1
                local fieldY = math.floor((vars.currentBlock.y - consts.FIELD_START_POINT.y + (y - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1
                
                field[fieldY][fieldX] = color;
            end
        end
    end

    clearFilledRows()
end

local function canPlaceShapeAt(shape, posX, posY)
    for y = 1, 4 do
        for x = 1, 4 do
            if shape[y][x] == 1 then
                local fieldX = math.floor((posX - consts.FIELD_START_POINT.x + (x - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1
                local fieldY = math.floor((posY - consts.FIELD_START_POINT.y + (y - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1

                if fieldX < 1 or fieldX > consts.FIELD_WIDHT or fieldY > consts.FIELD_HEIGHT then
                    return false
                end

                if fieldY >= 1 and field[fieldY][fieldX] ~= 0 then
                    return false
                end
            end
        end
    end
    return true
end

local function spawnNewBlock()
    local blockNum = logic.generateNextBlockNum()
    local shape = blocks[blockNum].shape
    local color = blocks[blockNum].color

    local startX = consts.BLOCK_START_POINT.x
    local startY = consts.BLOCK_START_POINT.y

    if not canPlaceShapeAt(shape, startX, startY) then
        vars.gameOver = true
        return
    end

    vars.currentBlock.shape = shape
    vars.currentBlock.color = color
    vars.currentBlock.x = startX
    vars.currentBlock.y = startY
end

local function lowerCurrentBlock ()
    if checkBlockCollision() then
        mapBlockIntoField()
        spawnNewBlock()
    else
        vars.currentBlock.y = vars.currentBlock.y + consts.BLOCK_SIZE
    end
end

local function rotateClockwise(shape)
    local newShape = {}
    for y = 1, 4 do
        newShape[y] = {}
        for x = 1, 4 do
            newShape[y][x] = shape[5 - x][y]
        end
    end
    return newShape
end

local function canPlaceShapeAt(shape, posX, posY)
    for y = 1, 4 do
        for x = 1, 4 do
            if shape[y][x] == 1 then
                local fieldX = math.floor((posX - consts.FIELD_START_POINT.x + (x - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1
                local fieldY = math.floor((posY - consts.FIELD_START_POINT.y + (y - 1) * consts.BLOCK_SIZE) / consts.BLOCK_SIZE) + 1

                if fieldX < 1 or fieldX > consts.FIELD_WIDHT or fieldY > consts.FIELD_HEIGHT then
                    return false
                end

                if fieldY >= 1 and field[fieldY][fieldX] ~= 0 then
                    return false
                end
            end
        end
    end
    return true
end

function logic.handleInput(key)
    local newX = vars.currentBlock.x
    local newY = vars.currentBlock.y
    local shape = vars.currentBlock.shape

    if key == "left" then
        newX = vars.currentBlock.x - consts.BLOCK_SIZE
    elseif key == "right" then
        newX = vars.currentBlock.x + consts.BLOCK_SIZE
    elseif key == "space" then
        local rotated = rotateClockwise(shape)
        if canPlaceShapeAt(rotated, newX, newY) then
            vars.currentBlock.shape = rotated
        end
        return
    end

    if canPlaceShapeAt(shape, newX, newY) then
        vars.currentBlock.x = newX
    end
end

function logic.updateTimer (dt)
    vars.fallTimer = vars.fallTimer - dt

    if vars.fallTimer <= 0 then
        lowerCurrentBlock()
        vars.fallTimer = consts.FALL_RATE
    end
end

function logic.generateNextBlockNum ()
    math.randomseed(os.time())
    return math.random(1, 6)
end

return logic