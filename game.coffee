SHIP_SPEED = 25
SCORE_INCREMENT = 5
MISSILE_SPEED = 30
MISSILE_DELAY = 25
MISSILE_BUFFER = 25
ASTEROID_SPEED = 15
ASTEROID_DELAY = 100
ASTEROID_NUMBER = 10
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
    constructor: ->
        #TODO: [x]Implement bounds on randoms
        angle = Math.min(Math.max(Math.sqrt(-2*Math.log(Math.random()))*Math.cos(2*Math.PI*Math.random()), -.55), .55) * Math.PI/2 + 3 * Math.PI / 2 #TODO: [x]Change distribution to normal from uniform
        x = Math.random() * canvasGames.screen.width
        dx = Math.cos(angle) * ASTEROID_SPEED
        dy = -Math.sin(angle) * ASTEROID_SPEED
        super ASTEROID_IMAGE, x, 0, dx, dy
        @y = -@height
    
    update: ->
        if @y > canvasGames.screen.height + @height
            @destroy()

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
                sprite.destroy()
                canvasGames.screen.addSprite(new Explosion @x, @y)
                EXPLOSION_SOUND.play()
                @ship.score += SCORE_INCREMENT
                @ship.score_ob.innerHTML = "Score: " + @ship.score
                @ship.asteroid_count--
                if not @ship.asteroid_count
                     @ship.new_level()
                     5
                return
        
        if not @life
            @destroy()

class Ship extends Wrapper
    constructor: ->
        super SHIP_IMAGE, canvasGames.screen.width/2, canvasGames.screen.height-SHIP_IMAGE.height/2-180

        @missile_counter = 0
        @asteroid_counter = ASTEROID_NUMBER
        
        @level = 1
        
        @score = 0
        @score_ob = document.getElementById("score")
    
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
        @asteroid_counter--
        
        if @asteroid_counter <= 0
            @add_asteroid @
            @asteroid_counter = ASTEROID_DELAY
        
        super
    
    add_missile: ->
        MISSILE_SOUND.play()
        canvasGames.screen.addSprite new Missile(@x, @y+@height/2-MISSILE_BUFFER, @)
    
    add_asteroid: ->
        canvasGames.screen.addSprite new Asteroid

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
