class @Particles extends Layer
  constructor: ->
    super
    
    @count = Random.int(40, 180, curve:Curve.low)
    @composite = ['source-over', 'lighter', 'darker'].random()
    
    @style =
      rotation: [
        [Random.float(-270, 270), Random.float(-270, 270)]
        [0, 0]
      ].random(curve:Curve.low2)
      
      color: [
        new HSL(stage.mainHue + Random.float(150, 210), Random.float(75, 100), 50).toString()
        new HSL(stage.mainHue + Random.float(150, 210), Random.float(0, 80), [90 - Random.int(30), Random.int(30)].random()).toString()
      ].random()
      maxAlpha: Random.float(0.25, 1, curve:Curve.high)
      
      size:       [Random.float(1, 2), Random.float(2, 8, curve:Curve.low3)]
      lifetime:   [Random.float(0.5, 2) / stage.beat.bps, Random.float(0.5, 2) / stage.beat.bps]
      
      type:       ['circle', 'arc', 'zoom'].random()
      arcWidth:   [Random.float(3, 30, curve:Curve.low), Random.float(3, 45, curve:Curve.low)]
      zoomLengthScalar: Random.float(40, 130, curve:Curve.low)
      
      emissionTime: Random.float(0.05, 0.3, curve:Curve.low3)
    
    # If compositing lighter or darker, dont be so opaque
    @style.alpha /= 2 if @composite is 'lighter' or @composite is 'darker'    
    
    # Repel from center
    if Random.int(2) == 0
      @style.speed = [0, 0]
      @style.drag = [Random.float(-100, -300) * stage.beat.bps, Random.float(-400, -800) * stage.beat.bps]
      @style.spawnRadius = [0, 0]
    
    # Attract to center
    else
      @style.speed = [Random.float(0, 80) * stage.beat.bps, Random.float(100, 400) * stage.beat.bps]
      @style.drag  = [Random.float(0, 200) * stage.beat.bps, Random.float(0, 200) * stage.beat.bps]
      @style.spawnRadius = [Random.float(0, 15, curve:Curve.low2), Random.float(0, 30, curve:Curve.low2)]
    
    switch @style.type
      when 'zoom'
        @style.spawnRadius[0] /= 2
        @style.spawnRadius[1] /= 2
        @count *= 0.75
        
      when 'arc'
        @count *= 0.6
    
    @particles = []
  
  onBeat: ->
    return if @expired
    @particles.push new Particle(@style, Random.float(0, @emissionTime)) for i in [0..@count]
    return
  
  render: (ctx) ->
    ctx.render =>
      @particles = (p for p in @particles when p.alive)
      @kill() if @expired and @particles.length == 0
      
      ctx.fillStyle = @style.color
      ctx.strokeStyle = @style.color
      ctx.globalCompositeOperation = @composite
      
      p.render ctx for p in @particles
    
class Particle
  constructor: (@style) ->
    @startedAt = stage.beat.now || now()
    @startedAt += Random.float(@style.emissionTime) / stage.beat.bps
    
    @alive     = yes
    
    @angle     = Random.float(360)
    @pos       = polar2rect Random.float(@style.spawnRadius...), @angle
    @vel       = polar2rect Random.float(@style.speed...), @angle
    @size      = Random.float(@style.size...)
    @drag      = Random.float(@style.drag...)
    @rotation  = Random.float(@style.rotation...)
    @lifetime  = Random.float(@style.lifetime...)
    @arcWidth  = Random.float(@style.arcWidth...)
    
  render: (ctx) ->
    return if stage.beat.now and @startedAt > stage.beat.now
    
    livedFor = stage.beat.now - @startedAt
    lifeProgession = livedFor / @lifetime
    return @alive = no if livedFor > @lifetime
      
    @update()
    
    ctx.render =>
      ctx.globalAlpha = @style.maxAlpha * Curve.high(1 - lifeProgession)
      ctx.rotate @rotation.deg2rad() * lifeProgession
      
      switch @style.type
        when 'circle'
          @renderCircle ctx
          
        when 'arc'
          @renderArc ctx
        
        when 'zoom'
          @renderZoom ctx
            
    
  renderCircle: (ctx) ->
    ctx.fillCircle @pos..., @size
  
  renderArc: (ctx) ->
    ctx.lineWidth = @size
    ctx.lineCap = 'round'
    
    [r, a] = rect2polar @pos...
    ctx.beginPath()
    ctx.arc 0, 0, r, (a-@arcWidth).deg2rad(), (a+@arcWidth).deg2rad()
    ctx.stroke()
  
  renderZoom: (ctx) ->
    ctx.lineWidth = @size
    ctx.lineCap = 'round'
    
    [r, a] = rect2polar @pos...
    ctx.beginPath()
    ctx.moveTo @pos...
    ctx.lineTo polar2rect(r + @arcWidth * r.normalize(@style.zoomLengthScalar), a)...
    ctx.stroke()
   
  update: (ctx) ->
    @dragVel = polar2rect @drag, @angle
  
    for i in [0..1]
      @vel[i] -= @dragVel[i] * stage.beat.frameTime()
      @pos[i] += @vel[i]     * stage.beat.frameTime()