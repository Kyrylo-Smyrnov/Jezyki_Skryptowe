require 'ruby2d'
require_relative 'enemy'

class Map
    TILE_SIZE = 40
    VIEWPORT_WIDTH = 20
    VIEWPORT_MARGIN = 800 * 0.25

    def initialize()
        @cameraOffset = 0

        @interactable = loadLevel("level/interactable.txt")
        @map = loadLevel("level/map.txt")

        @mapSizeX = @map[0].length
        @mapSizeY = @map.length
        
        @sprites = Array.new(@mapSizeY) { Array.new(@mapSizeX) }
        @interactableSprites = Array.new(@mapSizeY) { Array.new(@mapSizeX) }
        @enemies = []

        @map.each_with_index do |row, rowId|
            row.each_with_index do |tile, colId|
                x = TILE_SIZE * colId
                y = TILE_SIZE * rowId

                spriteX = 16 * tile
                sprite = Sprite.new("sprites/tiles.png", width: 40, height: 40, clip_width: 16, clip_height:16, clip_x: spriteX)

                sprite.x = x
                sprite.y = y

                @sprites[rowId][colId] = sprite
            end
        end

        @interactable.each_with_index do |row, rowId|
            row.each_with_index do |tile, colId|
                x = TILE_SIZE * colId
                y = TILE_SIZE * rowId

                if @interactable[rowId][colId] == 1
                    sprite = Sprite.new("sprites/coin.png", width: 40, height: 40, clip_width: 16, time: 300, loop: true)
                    sprite.play

                    sprite.x = x
                    sprite.y = y
 
                    @interactableSprites[rowId][colId] = sprite
                elsif @interactable[rowId][colId] == 2
                    @enemy = Enemy.new(colId * TILE_SIZE, rowId * TILE_SIZE)
                    @interactableSprites[rowId][colId] = @enemy.sprite
                    @enemies.push(@enemy)
                end
            end
        end
    end

    def loadLevel(file)
        File.readlines(file).map do |line|
            line.strip.split(',').map(&:to_i)
        end
    end

    def update(character)
        moved = 0
        lastTileX = @sprites[0][@sprites[0].length - 1].x + TILE_SIZE
        firstTileX = @sprites[0][0].x

        if character.posX > 800 - 800 * 0.25 && lastTileX > 800
            moved = 1
        elsif character.posX < 800 * 0.25 && firstTileX < 0
            moved = - 1
        end

        if moved != 0
            @sprites.each_with_index do |row, rowId|
                row.each_with_index do |sprite, colId|
                    if @interactableSprites[rowId][colId]
                        if @interactableSprites[rowId][colId]
                            @interactableSprites[rowId][colId].x -= 80 * moved
                        end
                    end
                    sprite.x -= 80 * moved
                end
            end
            character.posX = character.posX - 80 * moved
            @cameraOffset += 80 * moved
        end
    end

    def isColliding?(posX, posY)
        x = (posX + @cameraOffset) / TILE_SIZE
        y = posY / TILE_SIZE

        return false if x < 0 || y < 0
        return false if y >= @map.length || x >= @map[0].length

        @map[y][x] != 0
    end

    def isMob?(posX, posY)
        x = (posX + @cameraOffset) / TILE_SIZE
        y = posY / TILE_SIZE

        return false if x < 0 || y < 0
        return false if y >= @interactable.length || x >= @interactable[0].length

        @interactable[y][x] == 2
    end

    def removePoint(posX, posY)
        x = (posX + @cameraOffset) / TILE_SIZE
        y = posY / TILE_SIZE

        @interactable[y][x] = 0
        if @interactableSprites[y][x]
            @interactableSprites[y][x].remove
        end
    end

    def isPointOnPos?(posX, posY)
        x = (posX + @cameraOffset) / TILE_SIZE
        y = posY / TILE_SIZE

        return false if x < 0 || y < 0
        return false if y >= @interactable.length || x >= @interactable[0].length

        @interactable[y][x] == 1
    end
end
