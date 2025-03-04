using Luxor, Test

function polycliptest()
    Drawing(200, 150, :svg)
    origin()
    pgon1 = ngon(O, 100, 5, vertices = true)
    pgon2 = ngon(O, 150, 7, vertices = true)

    pc = polyclip(pgon1, pgon2)
    @test polyarea(pc) > 0
    @test !isnothing(pc)

    pgon1 = ngon(O, 50, 5, vertices = true)
    pgon2 = ngon(O + (0, 100), 50, 7, vertices = true)
    pc = polyclip(pgon1, pgon2)
    @test isnothing(pc)

    boxleft = box(O, 50, 50, vertices = true)
    boxright = box(O + (50, 0), 50, 50, vertices = true)

    # boxes share edge
    setline(0.5)
    @test boxleft[3].x == boxright[1].x
    @test boxleft[4].x == boxright[2].x
    
    poly(boxleft, :stroke, close=true)
    poly(boxright, :stroke, close=true)
    
    # no clipping!
    pc = polyclip(boxleft, boxright)
    @test isnothing(pc)
    
    # but shift right poly left so it slightly overlaps
    polymove!(boxright, O, Point(-0.001, 0))
    poly(boxleft, :stroke, close=true)
    poly(boxright, :stroke, close=true)
    pc = polyclip(boxleft, boxright)

    # clipping
    @test !isnothing(pc)
    @layer begin
        sethue("gold")
        poly(pc, :stroke, close=true)    
    end

    @test finish() == true
end

polycliptest()

println("...finished polyclip test")
