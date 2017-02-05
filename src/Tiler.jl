"""
    tiles = Tiler(areawidth, areaheight, nrows, ncols, margin=20)

A Tiler is an iterator that, for each iteration, returns a tuple of:

- the `x`/`y` point of the center of each tile in a set of tiles that divide up a
  rectangular space such as a page into rows and columns (relative to current 0/0)

- the number of the tile

`areawidth` and `areaheight` are the dimensions of the area to be tiled, `nrows`/`ncols`
are the number of rows and columns required, and `margin` is applied to all four
edges of the area before the function calculates the tile sizes required.

    tiles = Tiler(1000, 800, 4, 5, margin=20)
    for (pos, n) in tiles
    # the point pos is the center of the tile
    end

You can access the calculated tile width and height like this:

    tiles = Tiler(1000, 800, 4, 5, margin=20)
    for (pos, n) in tiles
      ellipse(pos.x, pos.y, tiles.tilewidth, tiles.tileheight, :fill)
    end
"""
type Tiler
    areawidth::Real
    areaheight::Real
    tilewidth::Real
    tileheight::Real
    nrows::Int
    ncols::Int
    margin::Real
    function Tiler(areawidth, areaheight, nrows::Int, ncols::Int; margin=10)
        tilewidth  = (areawidth - 2margin)/ncols
        tileheight = (areaheight - 2margin)/nrows
        new(areawidth, areaheight, tilewidth, tileheight, nrows, ncols, margin)
    end
end

function Base.start(pt::Tiler)
    # return the initial state
    x = -(pt.areawidth/2)  + pt.margin + (pt.tilewidth/2)
    y = -(pt.areaheight/2) + pt.margin + (pt.tileheight/2)
    return (Point(x, y), 1)
end

function Base.next(pt::Tiler, state)
    # Returns the item and the next state
    # state[1] is the Point
    x = state[1].x
    y = state[1].y
    # state[2] is the tilenumber
    tilenumber = state[2]
    x1 = x + pt.tilewidth
    y1 = y
    if x1 > (pt.areawidth/2) - pt.margin
        y1 += pt.tileheight
        x1 = -(pt.areawidth/2) + pt.margin + (pt.tilewidth/2)
    end
    return ((Point(x, y), tilenumber), (Point(x1, y1), tilenumber + 1))
end

function Base.done(pt::Tiler, state)
    # Tests if there are any items remaining
    state[2] > (pt.nrows * pt.ncols)
end

function Base.length(pt::Tiler)
    pt.nrows * pt.ncols
end

function Base.getindex(pt::Tiler, i::Int)
    1 <= i <= pt.ncols *  pt.nrows || throw(BoundsError(pt, i))
    xcoord = -pt.areawidth/2  + pt.margin + mod1(i, pt.ncols) * pt.tilewidth  - pt.tilewidth/2
    ycoord = -pt.areaheight/2 + pt.margin + (div(i - 1,  pt.ncols) * pt.tileheight) + pt.tileheight/2
    return (Point(xcoord, ycoord), i)
end

"""
    g = Grid(startpoint, xspacing=100.0, yspacing=100.0, width=600.0, height=600.0)
    
Define a grid.

    grid = Grid(O, 100, 0)   # 100 wide rows until width reached, then wrap
    grid = Grid(O, 0, 100)   # 100 high columns until height reached, then wrap
    grid = Grid(O, 100, 100) # 100 high rows and 100 high columns until width/height reached then wrap

Get points from the grid with `gp(g::Grid)`.
"""
type Grid
    startpoint::Point
    currentpoint::Point
    xspacing::Real
    yspacing::Real
    width::Real
    height::Real
    rownumber::Int
    colnumber::Int
    function Grid(startpoint, xspacing=100.0, yspacing=100.0, width=600.0, height=600.0)
        rownumber = 1
        colnumber = 1
        # find the "previous" point, so that the first call gets the first point
        currentpoint = Point(startpoint.x - xspacing, 0)
        new(startpoint, currentpoint, xspacing, yspacing, width, height, rownumber, colnumber)
    end
end

"""
    gp(g::Grid)

Returns the next available grid point of a grid created with `Grid()`.
"""
function gp(g::Grid)
    tempx = g.currentpoint.x + g.xspacing
    tempy = g.currentpoint.y 
    if g.xspacing == 0
        g.rownumber += 1
        g.colnumber = 1
        g.currentpoint = Point(g.startpoint.x, tempy + g.yspacing)
    else
        g.colnumber += 1
        g.currentpoint = Point(tempx, tempy)
    end    
    if g.currentpoint.x >= g.width
        g.rownumber += 1
        g.colnumber = 1
        g.currentpoint = Point(g.startpoint.x, tempy + g.yspacing)
    end
    if g.currentpoint.y >= g.height
        # what to do? Perhaps just start again...
        g.rownumber = 1
        g.colnumber = 1
        g.currentpoint = Point(0, 0)
    end
    return g.currentpoint
end
