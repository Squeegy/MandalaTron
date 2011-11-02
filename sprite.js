(function() {
  this.Sprite = (function() {
    Sprite.generate = function(options) {
      var i, style, _ref, _results;
      if (options == null) {
        options = {};
      }
      style = {
        speed: Random.float(150, 300, {
          curve: Curve.low
        }),
        baseWidth: Random.float(2, 10, {
          curve: Curve.low
        }),
        beatColor: new HSL(stage.mainHue + 180, Random.float(0, 80), [90 - Random.int(30), Random.int(30)].random()).toString(),
        emphasisColor: new HSL(stage.mainHue + 180, 100, 50).toString(),
        emphasisSpeed: Random.float(1, 2, {
          curve: Curve.low
        }),
        motionCurve: [Curve.low, Curve.high].random(),
        alpha: Random.float(0.35, 1, {
          curve: Curve.high
        }),
        outward: [true, true, false].random()
      };
      _results = [];
      for (i = 0, _ref = stage.beat.perMeasure; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        _results.push(new this({
          style: style,
          beat: i
        }));
      }
      return _results;
    };
    function Sprite(options) {
      if (options == null) {
        options = {};
      }
      this.style = options.style;
      this.beat = options.beat;
      this.emphasis = options.beat === 0;
      this.perMeasure = stage.beat.perMeasure;
      this.bps = stage.beat.bps;
      this.offset = this.beat / this.perMeasure;
      this.lifetime = this.perMeasure / this.bps;
      this.startedAt = stage.beat.startedAt - (this.offset * this.lifetime);
    }
    Sprite.prototype.render = function(ctx) {
      var elapsed, speed;
      ctx.globalAlpha = this.style.alpha;
      if (this.emphasis) {
        ctx.strokeStyle = this.style.emphasisColor;
        ctx.lineWidth = this.style.baseWidth * this.bps * 3 * this.style.emphasisSpeed;
      } else {
        ctx.strokeStyle = this.style.beatColor;
        ctx.lineWidth = this.style.baseWidth * this.bps;
      }
      elapsed = stage.beat.now - this.startedAt;
      if (elapsed > 0) {
        while (elapsed > this.lifetime) {
          elapsed -= this.lifetime;
          this.startedAt += this.lifetime;
        }
        speed = this.style.speed;
        if (this.emphasis) {
          speed *= this.style.emphasisSpeed;
        }
        if (this.style.outward) {
          speed *= this.style.motionCurve(elapsed / this.lifetime);
        } else {
          speed *= this.style.motionCurve(1 - elapsed / this.lifetime);
        }
        return ctx.strokeCircle(0, 0, speed);
      }
    };
    return Sprite;
  })();
}).call(this);