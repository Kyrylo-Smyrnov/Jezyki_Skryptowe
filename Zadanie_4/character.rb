require 'ruby2d'
require_relative 'map'

class Character
    def initialize(x, y)
        @posX = x
        @posY = y
        @speedY = 0
        @speedX = 0
        @onGround = true
        @health = 3
        @lastDamageTime = Time.at(0)
        @damaged = false
        @blinkFlag = true
        @isAlive = true
        @collectedCoins = 0
        @collectedPoints = 0
        @sprite = Sprite.new(
            "sprites/mario.png",
            width: 40,
            height: 40,
            clip_width: 16,
            clip_height: 15,
            animations: {
                idle: 1..1,
                run: 2..3,
                jump: 5..5
            }
        )
        @sprite.x = @posX
        @sprite.y = @posY
    end

    def moveLeft
        @sprite.play animation: :run, loop: true, flip: :horizontal
        @speedX -= 0.5
        @speedX = @speedX.clamp(-5, 5)
    end

    def stopMoveLeft
        @sprite.play animation: :idle, flip: :horizontal
        @speedX = 0
    end

    def moveRight
        @sprite.play animation: :run, loop: true
        @speedX += 0.5
        @speedX = @speedX.clamp(-5, 5)
    end

    def stopMoveRight
        @sprite.play animation: :idle
        @speedX = 0
    end

    def jump
        if @onGround
            @speedY = -12
            @onGround = false
        end
    end

    def update(map)
        if @damaged
            if Time.now - @lastDamageTime >= 3
                @damaged = false
                @sprite.color.opacity = 1
            else
                if @blinkFlag
                    @sprite.color.opacity = 0.3
                    @blinkFlag = false
                else
                    @sprite.color.opacity = 1
                    @blinkFlag = true
                end
            end
        end

        collectCoins(map)
        handleMovement(map)

        @sprite.x = @posX
        @sprite.y = @posY

    end

    def posX
        @posX
    end

    def posX=(posX)
        @posX = posX
    end

    def isAlive
        @isAlive
    end

    def collectedCoins
        @collectedCoins
    end

    def collectedPoints
        @collectedPoints
    end

    def collectCoins(map)

        x = @posX + 20
        y = @posY + 20

        if map.isPointOnPos?(x, y)
            @collectedCoins += 1
            map.removePoint(x, y)
        end
    end

    def takeDamage()
        if Time.now - @lastDamageTime >= 3
            @damaged = true

            @health -= 1
            @lastDamageTime = Time.now

            if @health == 0
            @isAlive = false
            end

            @speedY = -12
        end
    end

    def handleMovement(map)
        new_posY = @posY + @speedY
        new_posX = @posX + @speedX

        if @speedY > 0
            if map.isColliding?(@posX, new_posY + 40) || map.isColliding?(@posX + 40, new_posY + 40)
                @posY = ((new_posY + 40) / Map::TILE_SIZE).floor * Map::TILE_SIZE - 40
                @onGround = true
                @speedY = 0
            else
                if new_posY > 650
                    @isAlive = false
                    return
                end
                if map.isMob?(@posX, @posY + 40)|| map.isMob?(@posX + 40, @posY + 40)
                    @speedY = -12
                    map.removePoint(@posX + 40, @posY + 40)
                    map.removePoint(@posX, @posY + 40)
                    @collectedPoints += 150
                end
                @posY = new_posY
                @speedY += 0.5
                @onGround = false
            end
        elsif @speedY < 0
            if map.isColliding?(@posX, new_posY) || map.isColliding?(@posX + 40, new_posY)
                @posY = ((new_posY) / Map::TILE_SIZE).ceil * Map::TILE_SIZE
                @speedY = 0
            else
                @posY = new_posY
                @speedY += 0.5
            end
        else
            unless map.isColliding?(@posX, @posY + 41) || map.isColliding?(@posX + 35, @posY + 45)
                @onGround = false
                @speedY += 0.5
            end
        end
        
        if @speedX != 0
            if @speedX < 0
                if map.isColliding?(new_posX, @posY) || map.isColliding?(new_posX, @posY + 35)
                    @posX = ((new_posX) / Map::TILE_SIZE).ceil * Map::TILE_SIZE
                    @speedX = 0
                else
                    if map.isMob?(new_posX, @posY)|| map.isMob?(new_posX, @posY + 40)
                        takeDamage()
                    end
                    @posX = new_posX
                end
            else
                if map.isColliding?(new_posX + 40, @posY) || map.isColliding?(new_posX + 35, @posY + 35)
                    @posX = ((new_posX + 40) / Map::TILE_SIZE).floor * Map::TILE_SIZE - 40
                    @speedX = 0
                else
                    if map.isMob?(new_posX + 40, @posY)|| map.isMob?(new_posX + 40, @posY + 40)
                        takeDamage()
                    end
                    @posX = new_posX
                end
            end
        end
    end
end
