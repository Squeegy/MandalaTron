@Random =
  seed: ->
    seedField = document.getElementById('seed')
    
    if window.location.hash
      seedField.value = window.location.hash[1..-1]
    
    if seedField.value
      Math.seedrandom seedField.value
    else
      seed = Math.floor Math.random() * 1000000
      Math.seedrandom seed.toString()
      seedField.value = seed
  
  float: (min, max, options = {}) ->
    curve = options.curve || Curve.linear
    unless max?
      max = min
      min = 0
    
    curve(Math.random()) * (max - min) + min
  
  int: ->
    Math.floor @float(arguments...)

@Curve =
  linear: (x) -> x
  low2:   (x) -> x*x
  low3:   (x) -> x*x*x
  low:    (x) -> x*x*x
  high2:  (x) -> 1 - (1-x)*(1-x)
  high3:  (x) -> 1 - (1-x)*(1-x)*(1-x)
  high:   (x) -> 1 - (1-x)*(1-x)*(1-x)
  
  test: (fn) ->
    console.log "#{ i } => #{ fn i }" for i in [0..1] by 0.1
    return