(function() {
  var extendPrototype;
  var __slice = Array.prototype.slice;
  extendPrototype = function(base, methods) {
    var method, name;
    for (name in methods) {
      method = methods[name];
      base.prototype[name] = method;
    }
  };
  Math.TAU = Math.PI * 2;
  Math.avg = function() {
    var n, numbers, total, _i, _len;
    numbers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    total = 0;
    for (_i = 0, _len = numbers.length; _i < _len; _i++) {
      n = numbers[_i];
      total += n;
    }
    return total / numbers.length;
  };
  window.requestAnimFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
      return setTimeout(callback, 1000 / 60);
    };
  })();
  window.$ = function() {
    return document.getElementById.apply(document, arguments);
  };
  window.now = function() {
    return new Date().getTime() / 1000;
  };
  window.blend = function(start, end, amount) {
    return start * (1 - amount) + end * amount;
  };
  window.accurateInterval = function(time, fn) {
    var nextAt, wrapper, _ref;
    nextAt = new Date().getTime() + time;
    if (typeof time === 'function') {
      _ref = [time, fn], fn = _ref[0], time = _ref[1];
    }
    wrapper = function() {
      nextAt += time;
      wrapper.timeout = setTimeout(wrapper, nextAt - new Date().getTime());
      return fn();
    };
    wrapper.cancel = function() {
      return clearTimeout(wrapper.timeout);
    };
    setTimeout(wrapper, nextAt - new Date().getTime());
    return wrapper;
  };
  window.polar2rect = Math.polar2rect = function(r, a) {
    a = a.deg2rad();
    return [r * Math.cos(a), r * Math.sin(a)];
  };
  window.rect2polar = Math.rect2polar = function(x, y) {
    return [Math.sqrt(x * x + y * y), Math.atan2(y, x).rad2deg()];
  };
  extendPrototype(CanvasRenderingContext2D, {
    render: function(fn) {
      this.save();
      fn();
      return this.restore();
    },
    circle: function(x, y, radius) {
      this.arc(x, y, radius, 0, Math.TAU);
      return this.closePath();
    },
    fillCircle: function(x, y, radius) {
      this.beginPath();
      this.circle(x, y, radius);
      return this.fill();
    },
    strokeCircle: function(x, y, radius) {
      this.beginPath();
      this.circle(x, y, radius);
      return this.stroke();
    },
    rect: function(x, y, width, height) {
      this.beginPath();
      this.moveTo(x, y);
      this.lineTo(x + width, y);
      this.lineTo(x + width, y + height);
      this.lineTo(x, y + height);
      return this.closePath();
    }
  });
  extendPrototype(Array, {
    random: function(options) {
      if (options == null) {
        options = {};
      }
      return this[Random.int(0, this.length, options)];
    },
    blend: function(amount, options) {
      if (options == null) {
        options = {};
      }
      if (options.curve) {
        amount = options.curve(amount);
      }
      if (this.length >= 2) {
        return blend(this[0], this[1], amount);
      } else if (this.length === 1) {
        return this[0];
      } else {
        ;
      }
    }
  });
  extendPrototype(Number, {
    normalize: function(min, max) {
      if (max == null) {
        max = min;
        min = 0;
      }
      return (this - min) / (max - min);
    },
    limit: function(min, max) {
      if (max == null) {
        max = min;
        min = 0;
      }
      if (this < min) {
        return min;
      } else if (this > max) {
        return max;
      } else {
        return this;
      }
    },
    deg2rad: function() {
      return this * Math.TAU / 360;
    },
    rad2deg: function() {
      return this * 360 / Math.TAU;
    }
  });
  this.HSL = (function() {
    function HSL(h, s, l) {
      this.h = h;
      this.s = s;
      this.l = l;
    }
    HSL.prototype.toString = function() {
      return "hsl(" + (this.h.toFixed(1)) + ", " + (this.s.toFixed(1)) + "%, " + (this.l.toFixed(1)) + "%)";
    };
    return HSL;
  })();
}).call(this);
