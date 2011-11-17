class @Orbitals
  constructor: ->
    @orbitals = []
    @lastbeat = -1
    
    @rotation = Random.float(0, 360)
    @twist    = Random.float(20, 270) * [1, -1].random() until Math.abs(@twist + 360/stage.beat.perMeasure) > 30
    @count    = Random.int(1, 6)
    @mirror   = [yes, no].random()
    
    @style =
      color: [
        new HSL(stage.mainHue + Random.float(150, 210), Random.float(75, 100), 50).toString()
        new HSL(stage.mainHue + Random.float(150, 210), Random.float(0, 80), [90 - Random.int(30), Random.int(30)].random()).toString()
      ].random()
      
      size:         Random.float(5, 40, curve:Curve.low2)
      radius:       [Random.float(20, 150), Random.float(20, 150)]
      radiusCurve:  [Curve.low3, Curve.low2, Curve.low, Curve.linear, Curve.high, Curve.high2, Curve.high3].random()
      lifetime:     Random.float(0.5, stage.beat.perMeasure) / stage.beat.bps
      alpha:        Random.float(0.4, 1)
    
    # # Make it BIG
    # if Random.float(1) < 0.2
    #   @style.size *= 1.5
    #   @style.radius *= 3
    
  render: (ctx) ->
    @orbitals = (orbital for orbital in @orbitals when orbital.alive)
    @dead = yes if @expired and @orbitals.length is 0
    
    if stage.beat.beat() != @lastbeat and not @expired
      @lastbeat = stage.beat.beat()
      @orbitals.push new Orbital(@style)
    
    @renderGroup ctx
    
    if @mirror
      ctx.render =>
        ctx.scale -1, 1
        ctx.rotate @rotation.deg2rad()
        @renderGroup ctx
    
  
  renderGroup: (ctx) ->
    for i in [0...@count]
      twist = @twist * stage.beat.elapsed / stage.beat.bps
      ctx.render =>
        ctx.rotate (@rotation + twist + i * 360/@count).deg2rad()
        orbital.render ctx for orbital in @orbitals
    
    return
  
class Orbital
  constructor: (@style)->
    @alive = yes
    @startedAt = stage.beat.now
    @a = 360/stage.beat.perMeasure * stage.beat.beat()
    
  render: (ctx) ->
    livedFor = stage.beat.now - @startedAt
    return @alive = no if livedFor > @style.lifetime
    lifetimeProgress = livedFor / @style.lifetime
    
    alphaScalar = if lifetimeProgress < 0.1
      lifetimeProgress.normalize(0, 0.1)
    else
      lifetimeProgress.normalize(1, 0.1)
    
    ctx.globalAlpha = @style.alpha * alphaScalar
    ctx.fillStyle = @style.color
    ctx.fillCircle Math.polar2rect(@style.radius.blend(lifetimeProgress, curve:@style.radiusCurve), @a)..., @style.size