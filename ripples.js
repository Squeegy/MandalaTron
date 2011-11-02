(function() {
  var Ripple;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  this.Ripples = (function() {
    function Ripples() {
      var i, style;
      this.rotation = Random.float(30, 360, {
        curve: Curve.low
      }) * [1, -1].random();
      style = {
        speed: Random.float(160, 300, {
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
        outward: [true, true, false].random(),
        shape: ['circle', 'ngon'].random({
          curve: Curve.low
        }),
        ngon: Random.int(3, 8),
        twist: [0, Random.float(5, 45)].random() * [1, -1].random(),
        lineCap: ['round', 'square', 'butt'].random({
          curve: Curve.low
        })
      };
      this.elements = (function() {
        var _ref, _results;
        _results = [];
        for (i = 0, _ref = stage.beat.perMeasure; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
          _results.push(new Ripple({
            style: style,
            beat: i
          }));
        }
        return _results;
      })();
    }
    Ripples.prototype.render = function(ctx) {
      return ctx["do"](__bind(function() {
        var element, _i, _len, _ref, _results;
        ctx.rotate((this.rotation * stage.beat.elapsed / stage.beat.bps).deg2rad() % Math.TAU);
        _ref = this.elements;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          element = _ref[_i];
          _results.push(element.render(ctx));
        }
        return _results;
      }, this));
    };
    return Ripples;
  })();
  Ripple = (function() {
    function Ripple(options) {
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
    Ripple.prototype.drawShape = function(ctx, radius) {
      var angle, i, method, _ref;
      ctx.beginPath();
      switch (this.style.shape) {
        case 'circle':
          ctx.circle(0, 0, radius);
          break;
        case 'ngon':
          for (i = 0, _ref = this.style.ngon; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
            angle = i * Math.TAU / this.style.ngon;
            method = i === 0 ? 'moveTo' : 'lineTo';
            ctx[method](radius * Math.cos(angle), radius * Math.sin(angle));
          }
          ctx.closePath();
      }
      return ctx.stroke();
    };
    Ripple.prototype.render = function(ctx) {
      return ctx["do"](__bind(function() {
        var elapsed, speed;
        ctx.globalAlpha = this.style.alpha;
        ctx.rotate(this.style.twist.deg2rad() * this.beat);
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
          return this.drawShape(ctx, speed);
        }
      }, this));
    };
    return Ripple;
  })();
}).call(this);
