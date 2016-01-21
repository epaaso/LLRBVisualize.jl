module LLRBVisualize
    using LLRBTrees
    using Compose
    using Colors

    export iterate_undernode, drawASCII, drawtree

    #Columns in which the nodes are to be drawn
    abstract Column

    #For the left and rightmost columns
    type ColumnEmpty <: Column
    end

    #The idea is that one can insert a column between two columns making space for any new node
    #That is why we need a link to both sides
    type ColumnFull <: Column
        left :: Column
        right :: Column
        parent :: Column
        node ::  TreePart
        height :: Int64

        ColumnFull(node ::  TreePart) = new(ColumnEmpty(), ColumnEmpty(), ColumnEmpty(), node, 1)
        ColumnFull(cleft:: Column, cright::Column, cparent::Column, node:: TreePart, height :: Int64) = new(cleft, cright, cparent, node, height)
    end
    #Get the place from left to right of the given column
    function columnindex(col::ColumnFull)
        i :: Int =0
        while !isa(col, ColumnEmpty)
            i+=1
            col=col.left
        end
        i
    end

    function buildcolumns(col::ColumnFull)

        leftnode = col.node.left
        rightnode = col.node.right

        #First create the columns recursively to the left until there are no more nodes
        if isa(leftnode,  TreeNode)
            #Creation of the new column
            colleft = ColumnFull(col.left, col, col, leftnode, col.height+1)

            #Correcting links
            col.left = ColumnEmpty()
            if isa(colleft.left, ColumnFull)
                colleft.left.right = colleft
            end
            col.left = colleft

            buildcolumns(colleft)
        end

        if isa(rightnode,  TreeNode)
            #Creation of the new column
            colright = ColumnFull(col, col.right, col, rightnode, col.height+1)

            #Correcting links
            col.right = ColumnEmpty()
            if isa(colright.right, ColumnFull)
                colright.right.left = colright
            end
            col.right = colright

            buildcolumns(colright)
        end
        return col
    end
    buildcolumns(tree::LLRBTree) = buildcolumns( ColumnFull(tree.root) )

    function spacesstring(length::Int64, space="    " )
       string=""
        for i in 1:length
            string = "$string$space"
        end
        string
    end

    #The column given must be the one that contains the root node
    function drawASCII(col::ColumnFull)

        #For calculating indent
        maxheight=getmaxdepth(col.node)

        #Get the leftmost column
        while !isa(col.left, ColumnEmpty)
           col = col.left
        end

        #Print from left to right
        while true
            length = maxheight - col.height
            println(spacesstring(length), col.node.key)
            col = col.right
            isa(col, ColumnEmpty) && break
        end
    end
    drawASCII(tree:: LLRBTree) =( col = buildcolumns(tree); drawASCII(col) )

    #Returns an array that has the coordinates in which the nodes are to be drawn,
    #the index of the parents for drawing the connections and the value to be printed inside
    #The column given must be the one that contains the root node
    function getcoords(col::ColumnFull)

        #Get the y dimension
        maxheight=getmaxdepth(col.node)

        #We'll start writing from the left
        while !isa(col.left, ColumnEmpty)
           col = col.left
        end

        #Get the x dimension
        length=1
        col2=col
        while !isa(col2.right, ColumnEmpty)
           col2 = col2.right
           length += 1
        end

        #Define the cell dimensions in relative coordinates
        width=1/length
        height=1/maxheight
        coords = []

        #Write to the array from left to right
        x = -width
        while true
            y = -3*height/4 + col.height*height
            x += width
            parentid :: Int = isa(col.parent, ColumnFull) ? columnindex(col.parent): 0
            push!( coords, Any[x, y, parentid, col.node.value, col.node.isRed ] )

            col = col.right
            isa(col, ColumnEmpty) && break
        end

        coords
    end

    #Vector graphic representation with Compose.jl
    function drawtree(coords)
        circles = []
        lines = []
        width = length(coords)
        #Make a list of all the circles to be drawn
        for i in 1:width
            x = coords[i][1]
            y = coords[i][2]

            pnt :: Int = coords[i][3]
            #Build the line from children to pnt if present
            if ( pnt != Int(0) )
                xp= coords[ pnt][1]
                yp= coords[ pnt][2]

                ad = 0.25/width

                treeline = compose(context(), line([(x+ad, y+ad), (xp+ad, yp+ad)]), stroke(colorant"black") )
                push!(lines, treeline)
            end

            #Build the circle
            coloring = coords[i][5] ? colorant"red" : colorant"black"
            value = coords[i][4]
            circle_ = treecircle(x, y, 1/(2*width), string(value), coloring )
            push!(circles, circle_)
        end

        compose(context(), circles..., lines..., fontsize(30/(width)))
    end
    drawtree(col::ColumnFull) = drawtree(getcoords(col))

    drawtree(tree::LLRBTree) = drawtree(buildcolumns(tree))

    function treecircle(x::Float64, y::Float64, side::Float64, value::AbstractString, coloring )
        compose(context(x, y, side, side), circle(), fill(coloring), (context(0,0), text(0.2,0.65,value), fill(colorant"white")))
    end

    #Stange triangle visualization
    function iterate_undernode(node:: TreePart, isLeft::Bool=true)
        if isa(node, TreeLeaf)
            compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
            #=if isLeft
                                    compose(context(), polygon([(1,0.5), (0,0)]))
                                else
                                    compose(context(), polygon([(1,0.5), (0,1)]))
                                end=#
        else
            left=iterate_undernode(node.left, true)
            right=iterate_undernode(node.right, false)
            compose(context(),
                    #polygon([(1,1), (0,1), (1/2, 0)]),
                    #rectangle(),
                    (context(1/2,   0, 1/2, 1/2), left),
                    (context(  0, 0, 1/2, 1/2), right))
        end
    end
#LLRBVisualize end
end
