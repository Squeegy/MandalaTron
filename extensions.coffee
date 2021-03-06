# Easy way to add methods to an existing prototype
extendPrototype = (base, methods) ->
  base::[name] = method for name, method of methods
  return

# Tau is more awesome than PI
Math.TAU = Math.PI * 2

Math.avg = (numbers...) ->
  total = 0
  total += n for n in numbers
  total / numbers.length

# requestAnimationFrame shim
window.requestAnimFrame = do ->
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) -> setTimeout callback, 1000 / 60

# Easy to type id grabbber
window.$ = -> document.getElementById.apply document, arguments

# now in seconds
window.now = -> new Date().getTime() / 1000

# Blend 2 values in porportions of a nromalized float
window.blend = (start, end, amount) ->
  start * (1 - amount) + end * amount

# Accurate Interval, guaranteed not to drift!
# (Though each call can still be a few milliseconds late)
window.accurateInterval = (time, fn) ->
  
  # This value is the next time the the timer should fire.
  nextAt = new Date().getTime() + time
  
  # Allow arguments to be passed in in either order.
  if typeof time is 'function'
    [fn, time] = [time, fn]
  
  # Create a function that wraps our function to run.  This is responsible for
  # scheduling the next call and aborting when canceled.
  wrapper = ->
    nextAt += time
    wrapper.timeout = setTimeout wrapper, nextAt - new Date().getTime()
    fn()
  
  # Clear the next call when canceled.
  wrapper.cancel = -> clearTimeout wrapper.timeout
  
  # Schedule the first call.
  setTimeout wrapper, nextAt - new Date().getTime()
  
  # Return the wrapper function so cancel() can later be called on it.
  return wrapper

# Convert
window.polar2rect = Math.polar2rect = (r, a) ->
  a = a.deg2rad()
  [r * Math.cos(a), r * Math.sin(a)]

window.rect2polar = Math.rect2polar = (x, y) ->
  [
    Math.sqrt(x*x + y*y)       # r
    Math.atan2(y, x).rad2deg() # a
  ]

# Enhance the 2d rendering context with some convenience methods
extendPrototype CanvasRenderingContext2D,
  
  render: (fn) ->
    @save()
    fn()
    @restore()
  
  # Circles!
  circle: (x, y, radius) ->
    @arc x, y, radius, 0, Math.TAU
    @closePath()
  
  fillCircle: (x, y, radius) ->
    @beginPath()
    @circle x, y, radius
    @fill()
  
  strokeCircle: (x, y, radius) ->
    @beginPath()
    @circle x, y, radius
    @stroke()
  
  rect: (x, y, width, height) ->
    @beginPath()
    @moveTo x,         y
    @lineTo x + width, y
    @lineTo x + width, y + height
    @lineTo x,         y + height
    @closePath()


extendPrototype Array,
  random: (options = {}) ->
    this[Random.int 0, @length, options]
  
  blend: (amount, options = {}) ->
    amount = options.curve amount if options.curve
    if @length >= 2
      blend this[0], this[1], amount
    else if @length == 1
      this[0]
    else
      return

extendPrototype Number,
  
  # (0.75).normalize(0.5, 1.0) => 0.5
  normalize: (min, max) ->
    unless max?
      max = min
      min = 0
      
    (this - min) / (max - min)
  
  limit: (min, max) ->
    unless max?
      max = min
      min = 0
    
    if this < min
      min
    else if this > max
      max
    else
      this
    
  deg2rad: ->
    this * Math.TAU / 360
  
  rad2deg: ->
    this * 360 / Math.TAU

class @HSL
  constructor: (@h, @s, @l) ->
  toString: -> "hsl(#{ @h.toFixed 1 }, #{ @s.toFixed 1 }%, #{ @l.toFixed 1 }%)"
  