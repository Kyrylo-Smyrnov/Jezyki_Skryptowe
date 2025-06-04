local logic = {}

local blocks = require("blocks")
local consts = require("consts")
local field = require("field")
local vars = require("vars")
local sounds = require("sounds")

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

local function markRowsToClear()
    local clearedRows = 0
    vars.clearedRows = {}

    for y = consts.FIELD_HEIGHT, 1, -1 do
        local full = true
        for x = 1, consts.FIELD_WIDHT do
            if field[y][x] == 0 then
                full = false
                break
            end
        end

        if full then
            vars.clearedRows[y] = true
            clearedRows = clearedRows + 1
        end
    end

    if clearedRows > 0 then
        vars.clearing = true
        vars.clearingTimer = 1.5
        sounds.lineSound:play()
        vars.score = vars.score + clearedRows * 100
    end
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

    sounds.placedSound:play()

    markRowsToClear()
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
        sounds.gameOverSound:play()
        return
    end

    vars.currentBlock.id = blockNum
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

function logic.rotateClockwise(shape)
    local newShape = {}
    for y = 1, 4 do
        newShape[y] = {}
        for x = 1, 4 do
            newShape[y][x] = shape[5 - x][y]
        end
    end
    return newShape
end

function logic.canPlaceShapeAt(shape, posX, posY)
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

function logic.saveGame()
    local file = io.open("Zadanie_3/save.txt", "w")

    file:write(vars.currentBlock.id.. "\n")
    file:write(vars.currentBlock.x.. "\n")
    file:write(vars.currentBlock.y.. "\n")
    file:write(vars.score.. "\n")

    for y = 1, consts.FIELD_HEIGHT do
        for x = 1, consts.FIELD_WIDHT do
            file:write(field[y][x])
            if x < consts.FIELD_WIDHT then
                file:write(", ")
            end
        end
        file:write("\n")
    end

    file:close()

    vars.gameState = "menu"
    vars.isGameStarted = false

    field.reset()
end

function logic.loadGame()
    field.reset()
    vars.gameOver = false

    local file = io.open("Zadanie_3/save.txt", "r")

    vars.currentBlock.id = tonumber(file:read("*l"))
    vars.currentBlock.shape = blocks[vars.currentBlock.id].shape
    vars.currentBlock.color = blocks[vars.currentBlock.id].color
    vars.currentBlock.x = tonumber(file:read("*l"))
    vars.currentBlock.y = tonumber(file:read("*l"))

    vars.score = tonumber(file:read("*l"))

    for y = 1, consts.FIELD_HEIGHT do
        local line = file:read("*l")
        local values = {}

        for value in string.gmatch(line, "%d+") do
            table.insert(values, tonumber(value))
        end

        for x = 1, consts.FIELD_WIDHT do
            field[y][x] = values[x] or 0
        end
    end

    file:close()
end

function logic.startGame()
    field.reset()
    vars.gameOver = false
    vars.score = 0
    local firstBlockNum = logic.generateNextBlockNum()

    vars.currentBlock.id = firstBlockNum
    vars.currentBlock.shape = blocks[firstBlockNum].shape
    vars.currentBlock.color = blocks[firstBlockNum].color
    vars.currentBlock.x = consts.BLOCK_START_POINT.x
    vars.currentBlock.y = consts.BLOCK_START_POINT.y
end

function logic.updateTimer(dt)
    dt = math.min(dt, 0.1)

    if vars.clearing then
        vars.clearingTimer = vars.clearingTimer - dt
        if vars.clearingTimer <= 0 then
            local newField = {}
            local dstY = consts.FIELD_HEIGHT

            for y = 1, consts.FIELD_HEIGHT do
                newField[y] = {}
                for x = 1, consts.FIELD_WIDHT do
                    newField[y][x] = 0
                end
            end

            for y = consts.FIELD_HEIGHT, 1, -1 do
                if not vars.clearedRows[y] then
                    for x = 1, consts.FIELD_WIDHT do
                        newField[dstY][x] = field[y][x]
                    end
                    dstY = dstY - 1
                end
            end

            for y = 1, consts.FIELD_HEIGHT do
                for x = 1, consts.FIELD_WIDHT do
                    field[y][x] = newField[y][x]
                end
            end

            vars.clearing = false
            vars.clearedRows = {}
        end
        return
    end

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