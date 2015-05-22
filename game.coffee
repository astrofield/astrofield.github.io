SHIP_SPEED = 15
SCORE_INCREMENT = 5
MISSILE_SPEED = 30
MISSILE_DELAY = 25
MISSILE_BUFFER = 25
ASTEROID_SPEED = 7
ASTEROID_DELAY = 60
LEVEL_DELAY = 150
ASTEROID_NUMBER = 5
ASTEROID_INCREMENT = 5
MISSILE_LIFE = 180
BODY_PADDING = 8
SHIP_IMAGE = null
MISSILE_IMAGE = null
ASTEROID_IMAGE = null
EXPLOSION_IMAGES = null
EXPLOSION_SOUND = new Audio "explosion.wav"
MISSILE_SOUND = new Audio "missile.wav"
window.music = new Audio "music.ogg"

class Explosion extends canvasGames.Animation
    constructor: (x, y) ->
        super EXPLOSION_IMAGES, x, y, 0, 0, 0, 2, 1

class Wrapper extends canvasGames.Sprite
    update: ->
        if @x > canvasGames.screen.width
            @x = 0
        if @x < -@width
            @x = canvasGames.screen.width - @width

class Asteroid extends Wrapper
    constructor: (@ship) ->
        #TODO: [x]Implement bounds on randoms
        angle = Math.min(Math.max(Math.sqrt(-2*Math.log(Math.random()))*Math.cos(2*Math.PI*Math.random()), -.55), .55) * Math.PI/2 + 3 * Math.PI / 2 #TODO: [x]Change distribution to normal from uniform
        x = Math.random() * canvasGames.screen.width
        dx = Math.cos(angle) * ASTEROID_SPEED
        dy = -Math.sin(angle) * ASTEROID_SPEED
        super ASTEROID_IMAGE, x, 0, dx, dy
        @y = -@height
    
    update: ->
        if @y > canvasGames.screen.height + @height/2
            @destroy()
            @ship.lose_life()

        super
        
    explode: ->
        @destroy()
        canvasGames.screen.addSprite(new Explosion @x, @y)
        EXPLOSION_SOUND.currentTime = 0
        EXPLOSION_SOUND.play()

    destroy: -> 
        @ship.asteroids = (i for i in @ship.asteroids when i isnt @)
        super

class Missile extends Wrapper
    constructor: (x, y, @ship) ->
        super MISSILE_IMAGE, x, y, 0, -MISSILE_SPEED
        
        @life = MISSILE_LIFE
    
    update: ->
        @life--
        
        for sprite in @get_colliding_sprites()
            if sprite instanceof Asteroid
                @destroy()
                sprite.explode()
                @ship.score += SCORE_INCREMENT
                @ship.score_ob.innerHTML = "Score: " + @ship.score
                @ship.asteroid_count--
                return
        
        if not @life
            @destroy()

class Ship extends Wrapper
    constructor: ->
        super SHIP_IMAGE, canvasGames.screen.width/2, canvasGames.screen.height-SHIP_IMAGE.height/2-180

        @missile_counter = 0
        @asteroid_wait = LEVEL_DELAY
        @asteroid_count = 0

        @level = 0
        @first_asteroid = false
        @level_ob = document.getElementById("level")

        @score = 0
        @score_ob = document.getElementById("score")
        
        @life = 100
        @life_ob = document.getElementById("life")

        @nuke_counter = 0
        @nuke_number = 3

        @asteroids = []

    update: ->
        #Check movement
        if canvasGames.keyboard.isPressed 37
            @x -= SHIP_SPEED
        if canvasGames.keyboard.isPressed 39
            @x += SHIP_SPEED
        
        #Missile Check
        @missile_counter--
        
        if canvasGames.keyboard.isPressed(32) and @missile_counter <= 0
            @add_missile()
            @missile_counter = MISSILE_DELAY
        
        #Asteroid Check
        @asteroid_wait--
        
        if @asteroid_wait <= 0
            @add_asteroid @
            if @first_asteroid
                @first_asteroid = false
                @level_ob.style.display = "none"
            @asteroid_wait = ASTEROID_DELAY
       

         if not @asteroid_count
             @new_level()
 
         #Nuke check
         @nuke_counter--

         if canvasGames.keyboard.isPressed(13) and @nuke_counter <= 0 and @nuke_number
             document.getElementById("nuke" + @nuke_number).style.display = "none"
             for asteroid in @asteroids
                 asteroid.explode()
             @nuke_number--
             @nuke_counter = 60

        super
    
    add_missile: ->
        MISSILE_SOUND.play()
        canvasGames.screen.addSprite new Missile(@x, @y+@height/2-MISSILE_BUFFER, @)
    
    add_asteroid: ->
        asteroid = new Asteroid @
        canvasGames.screen.addSprite asteroid
        @asteroids.push(asteroid)

    lose_life: ->
        @life -= 5
        if not @life
            @destroy()
            alert "Game Over! You got #{@score} points!"
            if confirm "Play Again?"
                document.location = "index.html"
            else
                window.close()
        @life_ob.style.width = if @life>0 then @life * 2 else 0
    
    new_level: ->
        @level += 1
        @level_ob.style.display = "block"
        @level_ob.innerHTML = "Level " + @level
        ASTEROID_NUMBER += ASTEROID_INCREMENT
        @first_asteroid = true
        @asteroid_count = ASTEROID_NUMBER
        @asteroid_wait = LEVEL_DELAY

canvas = document.getElementById 'canvas'

canvas.width = window.innerWidth - BODY_PADDING * 2
canvas.height = window.innerHeight - BODY_PADDING * 2

canvasGames.init canvas

canvasGames.loadImages("bg.png", "spaceship.png", "light_missile.png", "asteroid.png", ("explosion#{ i }.png" for i in [1..9])..., (images) ->
    canvasGames.screen.setBackground images.shift()
    [SHIP_IMAGE, MISSILE_IMAGE, ASTEROID_IMAGE, EXPLOSION_IMAGES...] = images
    
    spaceship = new Ship
    canvasGames.screen.addSprite spaceship

    canvasGames.screen.mainloop()
)

music.volume = .7

music.addEventListener('ended', () ->
    @currentTime = 0;
    @play()
, false)
music.play()
