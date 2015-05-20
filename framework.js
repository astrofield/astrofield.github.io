(function() {
  var DEFAULT_BG_COLOR, canvasGames,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  canvasGames = {};

  DEFAULT_BG_COLOR = "black";

  canvasGames.Keyboard = (function() {
    function Keyboard() {
      this.keys = [];
      window.addEventListener('keyup', (function(_this) {
        return function(e) {
          var i;
          return _this.keys = (function() {
            var _i, _len, _ref, _results;
            _ref = this.keys;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              i = _ref[_i];
              if (i !== (e.keyCode || e.which)) {
                _results.push(i);
              }
            }
            return _results;
          }).call(_this);
        };
      })(this));
      window.addEventListener('keydown', (function(_this) {
        return function(e) {
          return _this.keys.push(e.which || e.keyCode);
        };
      })(this));
    }

    Keyboard.prototype.isPressed = function(key) {
      return __indexOf.call(this.keys, key) >= 0;
    };

    return Keyboard;

  })();

  canvasGames.Sprite = (function() {
    function Sprite(image, x, y, dx, dy, angle) {
      var _ref;
      this.image = image;
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.dx = dx != null ? dx : 0;
      this.dy = dy != null ? dy : 0;
      this.angle = angle != null ? angle : 0;
      _ref = [this.image.width, this.image.height], this.width = _ref[0], this.height = _ref[1];
    }

    Sprite.prototype.draw = function() {
      if (this.angle) {
        this.screen.canvas.translate(this.x, this.y);
        this.screen.canvas.rotate(this.angle);
        this.screen.canvas.drawImage(this.image, -(this.width / 2), this.height / 2);
        this.screen.canvas.rotate(-this.angle);
        return this.screen.canvas.translate(-this.x, -this.y);
      } else {
        return this.screen.canvas.drawImage(this.image, this.x - (this.width / 2), this.y + (this.height / 2));
      }
    };

    Sprite.prototype.move = function() {
      this.x += this.dx;
      return this.y += this.dy;
    };

    Sprite.prototype.update = function() {};

    Sprite.prototype.loop = function() {
      this.draw();
      this.move();
      return this.update();
    };

    Sprite.prototype.destroy = function() {
      var i;
      return this.screen.sprites = (function() {
        var _i, _len, _ref, _results;
        _ref = this.screen.sprites;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i !== this) {
            _results.push(i);
          }
        }
        return _results;
      }).call(this);
    };

    Sprite.prototype.is_colliding = function(sprite) {
      return (Math.abs(this.x - sprite.x) * 2 < Math.abs(this.width + sprite.width)) && (Math.abs(this.y - sprite.y) * 2 < Math.abs(this.height + sprite.height));
    };

    Sprite.prototype.get_colliding_sprites = function() {
      var i, _i, _len, _ref, _results;
      _ref = this.screen.sprites;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i !== this && this.is_colliding(i)) {
          _results.push(i);
        }
      }
      return _results;
    };

    return Sprite;

  })();

  canvasGames.Text = (function(_super) {
    __extends(Text, _super);

    function Text() {
      var color, font, others, size, text;
      text = arguments[0], size = arguments[1], color = arguments[2], font = arguments[3], others = 5 <= arguments.length ? __slice.call(arguments, 4) : [];
      this.text = text;
      this.size = size;
      this.color = color;
      this.font = font != null ? font : "Monospace";
      this.set_text(text, size, color, font);
      Text.__super__.constructor.apply(this, [this.image].concat(__slice.call(others)));
    }

    Text.prototype.set_text = function(text, size, color, font) {
      var context;
      this.text = text;
      this.size = size;
      this.color = color;
      this.font = font != null ? font : "Monospace";
      this.image = document.createElement("canvas");
      context = this.image.getContext("2d");
      context.font = size + "px " + this.font;
      context.fillStyle = this.color;
      this.width = this.image.width = context.measureText(text).width;
      this.height = this.image.height = this.size;
      return context.fillText(this.text, 0, 0);
    };

    return Text;

  })(canvasGames.Sprite);

  canvasGames.Animation = (function(_super) {
    __extends(Animation, _super);

    function Animation() {
      var images, n_repeats, others, speed, _i;
      images = arguments[0], others = 4 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 2) : (_i = 1, []), speed = arguments[_i++], n_repeats = arguments[_i++];
      this.images = images;
      this.speed = speed;
      this.n_repeats = n_repeats;
      Animation.__super__.constructor.apply(this, [this.images[0]].concat(__slice.call(others)));
      this.life = this.speed;
      this.index = 0;
      this.repeats_left = this.n_repeats;
    }

    Animation.prototype.loop = function() {
      Animation.__super__.loop.apply(this, arguments);
      this.life--;
      if (!this.life) {
        this.index++;
        this.index %= this.images.length;
        this.image = this.images[this.index];
        this.life = this.speed;
        if (!this.index) {
          this.repeats_left--;
          if (!this.repeats_left) {
            return this.destroy();
          }
        }
      }
    };

    return Animation;

  })(canvasGames.Sprite);

  canvasGames.Screen = (function() {
    function Screen(canvas) {
      var _ref;
      this.canvas = canvas.getContext("2d");
      this.sprites = [];
      _ref = [canvas.width, canvas.height], this.width = _ref[0], this.height = _ref[1];
      this.setBackground(DEFAULT_BG_COLOR);
    }

    Screen.prototype.setBackground = function(background) {
      var context;
      this.background = background;
      background = document.createElement("canvas");
      background.width = this.width;
      background.height = this.height;
      context = background.getContext("2d");
      context.fillStyle = typeof this.background === "string" ? this.background : DEFAULT_BG_COLOR;
      context.fillRect(0, 0, this.width, this.height);
      if (typeof this.background !== "string") {
        context.drawImage(this.background, 0, 0);
      }
      return this.background = background;
    };

    Screen.prototype.addSprite = function(sprite) {
      this.sprites.push(sprite);
      return sprite.screen = this;
    };

    Screen.prototype.mainloop = function(timestamp) {
      var sprite, _i, _len, _ref;
      this.canvas.drawImage(this.background, 0, 0);
      _ref = this.sprites;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sprite = _ref[_i];
        sprite.loop();
      }
      return requestAnimationFrame((function(_this) {
        return function(t) {
          return _this.mainloop(t);
        };
      })(this));
    };

    return Screen;

  })();

  canvasGames.getImagePromise = function(url) {
    return new Promise(function(resolve, reject) {
      var imageObj;
      imageObj = new Image;
      imageObj.onload = function() {
        return resolve(imageObj);
      };
      return imageObj.src = url;
    });
  };

  canvasGames.loadImage = function(url, callback) {
    return canvasGames.getImagePromise(url).then(callback);
  };

  canvasGames.loadImages = function() {
    var callback, promise, url, urls, _i, _j, _len, _ref;
    urls = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
    promise = canvasGames.getImagePromise(urls[0]);
    canvasGames._images = [];
    _ref = urls.slice(1);
    for (_j = 0, _len = _ref.length; _j < _len; _j++) {
      url = _ref[_j];
      promise = promise.then((function(_url) {
        return function(image) {
          canvasGames._images.push(image);
          return canvasGames.getImagePromise(_url);
        };
      })(url));
    }
    return promise.then(function(image) {
      canvasGames._images.push(image);
      return callback(canvasGames._images);
    });
  };

  canvasGames.loadSound = function(url, callback) {
    var audio;
    audio = new Audio;
    audio.addEventListener('canplaythrough', callback, false);
    return audio.src = url;
  };

  canvasGames.init = function(canvas) {
    document.getElementsByTagName('body')[0].style.overflow = 'hidden';
    canvasGames.screen = new canvasGames.Screen(canvas);
    return canvasGames.keyboard = new canvasGames.Keyboard();
  };

  window.canvasGames = canvasGames;

}).call(this);
