require 'ruby2d'
require_relative 'character'
require_relative 'map'

set title: "Super Mario"
set width: 800, height: 600

@map = nil
@character = nil
@coinsText = nil
@pointsText = nil
@enemy = nil
@gameState = :menu

@menuBackground = Sprite.new("sprites/main_menu/menu_bg.png", width: 800, height: 600)
@startButton = Sprite.new("sprites/main_menu/button_play.png", width: 500, height: 50, x: 150, y: 350)

on :key_held do |e|
    if @gameState == :game
        @character.moveLeft if e.key == 'left'
        @character.moveRight if e.key == 'right'
    end
end

on :key_down do |e|
    if @gameState == :game
        @character.jump if e.key == 'up'
    end
end

on :key_up do |e|
    if @gameState == :game
        @character.stopMoveLeft if e.key == 'left'
        @character.stopMoveRight if e.key == 'right'
    end
end

def switch_to_game
    @map = Map.new
    @character = Character.new(100, 100)

    @coinsIcon = Sprite.new('sprites/coin.png', width: 40, height: 40, x: 450, y: 10, clip_width: 16)
    @coinsText = Text.new("0", x: 490, y: 15, size: 28, font: "font.ttf", color: 'white')
    @pointsText = Text.new("0", x: 290, y: 15, size: 28, font: "font.ttf", color: 'white')

    @gameState = :game
    @menuBackground.remove
    @startButton.remove
end

def switch_to_menu
    @gameState = :menu

    @menuBackground = Sprite.new("sprites/main_menu/menu_bg.png", width: 800, height: 600)
    @startButton = Sprite.new("sprites/main_menu/button_play.png", width: 500, height: 50, x: 150, y: 350)
end

on :mouse_down do |event|
    if @gameState == :menu
        if event.x >= @startButton.x && event.x <= @startButton.x + @startButton.width &&
        event.y >= @startButton.y && event.y <= @startButton.y + @startButton.height
        switch_to_game
        end
    end
end

update do
    if @gameState == :game
        @map.update(@character)
        @character.update(@map)
        @coinsText.text = "#{@character.collectedCoins}"
        @pointsText.text = "#{@character.collectedPoints}"

        if @character.isAlive() == false
            switch_to_menu
        end
    end
end

show