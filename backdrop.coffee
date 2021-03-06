class @Backdrop extends Layer
  constructor: ->
    super
    @hueShift = Random.int(0, 90,  curve: Curve.low) * [1, -1].random()
    @innerSat = [
      Random.int 0, 100, curve: Curve.low
      Random.int 0, 100, curve: Curve.low
    ]
    @outerSat = [
      Random.int 0, 100, curve: Curve.high
      Random.int 0, 100, curve: Curve.high
    ]
    @innerLum = [
      Random.int 0, 100
      Random.int 0, 100
    ]
    @outerLum = [
      Random.int 0, 100
      Random.int 0, 100
    ]
    @coefCurve = [Curve.low, Curve.high].random()
  
  expire: ->
    super
    @kill()
  
  render: (ctx) ->
    @kill() if @expired
    ctx.render =>
      ctx.globalAlpha = 1.0
      ctx.fillStyle = @createGradient ctx
      ctx.fillRect -stage.canvas.width/2, -stage.canvas.height/2, stage.canvas.width, stage.canvas.height
  
  createGradient: (ctx) ->
    coef = if stage.beat.beat() == 0
      @coefCurve 1 - stage.beat.beatProgress()
    else
      min = 1 / stage.beat.perMeasure
      @coefCurve stage.beat.measureProgress().normalize(1 / stage.beat.perMeasure, 1)
  
    innerColor = new HSL(
      stage.mainHue + @hueShift*coef
      blend(@innerSat[0], @innerSat[1], coef)
      blend(@innerLum[0], @innerLum[1], coef)
    )
  
    outerColor = new HSL(
      stage.mainHue + @hueShift*coef
      blend(@outerSat[0], @outerSat[1], coef)
      blend(@outerLum[0], @outerLum[1], coef)
    )
  
    grad = ctx.createRadialGradient 0, 0, 0, 0, 0, 150
    grad.addColorStop 0, innerColor.toString()
    grad.addColorStop 1, outerColor.toString()
    
    return grad