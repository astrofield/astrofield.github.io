canvasGames = {}

DEFAULT_BG_COLOR = "black"

class canvasGames.Keyboard
    constructor: () ->
        @keys = []
        
        window.addEventListener('keyup', (e) =>
            @keys = (i for i in @keys when i isnt (e.keyCode || e.which))
        )
        
        window.addEventListener('keydown', (e) =>
            @keys.push e.which || e.keyCode
        )
    
    isPressed: (key) ->
        key in @keys

#Sprite Class
class canvasGames.Sprite
    constructor: (@image, @x=0, @y=0, @dx = 0, @dy = 0, @angle = 0) ->
        [@width, @height] = [@image.width, @image.height]
    
    draw: ->
        if @angle
            @screen.canvas.translate(@x, @y)
            @screen.canvas.rotate(@angle)
            @screen.canvas.drawImage(@image, -(@width/2), (@height/2))
            @screen.canvas.rotate(-@angle)
            @screen.canvas.translate(-@x, -@y)
        else
            @screen.canvas.drawImage(@image, @x-(@width/2), @y+(@height/2))
    
    move: ->
        @x += @dx
        @y += @dy
    
    update: ->
    
    loop: ->
        @draw()
        @move()
        @update()
    
    destroy: ->
        @screen.sprites = (i for i in @screen.sprites when i isnt @)
    
    is_colliding: (sprite) ->
        (Math.abs(@x - sprite.x) * 2 < Math.abs(@width + sprite.width)) and (Math.abs(@y - sprite.y) * 2 < Math.abs(@height + sprite.height))
    
    get_colliding_sprites: ->
        i for i in @screen.sprites when i isnt @ and @is_colliding(i)
    
    
#Sprite Subclasses
class canvasGames.Text extends canvasGames.Sprite
    constructor: (@text, @size, @color, @font="Monospace", others...) ->
        @set_text(text, size, color, font)
        
        super @image, others...

    set_text: (@text, @size, @color, @font="Monospace") ->
        @image = document.createElement "canvas"
        context = @image.getContext "2d"
        context.font = size + "px " + @font
        context.fillStyle = @color
        @width = @image.width = context.measureText(text).width
        @height = @image.height = @size
        context.fillText(@text, 0, 0)

class canvasGames.Animation extends canvasGames.Sprite
    constructor: (@images, others..., @speed, @n_repeats) ->
        super @images[0], others...
        
        @life = @speed
        @index = 0
        @repeats_left = @n_repeats
    
    loop: ->
        super
        
        @life--
        
        if not @life
            @index++
            @index %= @images.length
            @image = @images[@index]
            @life = @speed
            if not @index
                @repeats_left--
                if not @repeats_left
                    @destroy()

#Screen Class
class canvasGames.Screen
    constructor: (canvas) ->
        @canvas = canvas.getContext "2d"
        @sprites = []
        [@width, @height] = [canvas.width, canvas.height]
        
        @setBackground DEFAULT_BG_COLOR
    
    setBackground: (@background) ->
        background = document.createElement("canvas")
        background.width = @width
        background.height = @height
        context = background.getContext "2d"
        context.fillStyle = if typeof @background is "string" then @background else DEFAULT_BG_COLOR
        context.fillRect(0, 0, @width, @height)
        if typeof @background isnt "string"
            context.drawImage(@background, 0, 0)
        @background = background

    
    addSprite: (sprite) ->
        @sprites.push sprite
        sprite.screen = @
    
    mainloop: (timestamp) ->
        @canvas.drawImage(@background, 0, 0)
        
        for sprite in @sprites
            sprite.loop()
        
        requestAnimationFrame (t) => @mainloop(t)

#Utility Functions
canvasGames.getImagePromise = (url) ->
    new Promise (resolve, reject) ->
        imageObj = new Image
        
        imageObj.onload = () -> resolve(imageObj)
        
        imageObj.src = url
    
canvasGames.loadImage = (url, callback) ->
    canvasGames.getImagePromise(url).then(callback)

canvasGames.loadImages = (urls..., callback) ->
    promise = canvasGames.getImagePromise urls[0]
    
    canvasGames._images=[]
    for url in urls[1..]
        promise = promise.then ((_url) ->
            (image) ->
                canvasGames._images.push image
                canvasGames.getImagePromise _url
            )(url)

    promise.then (image) ->
        canvasGames._images.push image
        callback canvasGames._images

canvasGames.loadSound = (url, callback) ->
    audio = new Audio
    audio.addEventListener('canplaythrough', callback, false)
    audio.src = url
    
canvasGames.init = (canvas) ->
    document.getElementsByTagName('body')[0].style.overflow = 'hidden'
    
    canvasGames.screen = new canvasGames.Screen canvas
    canvasGames.keyboard = new canvasGames.Keyboard()

window.canvasGames = canvasGames
