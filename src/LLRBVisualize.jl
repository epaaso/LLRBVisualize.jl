module LLRBVisualize

using LLRBTrees
import Base: replace, display

export buildstring, draw

include("GraphViz.jl")

function buildstring{K,V}(tree::LLRBTree{K,V})

    treestring = """
    digraph tree {

        }
        """
    linenow = 16

    if(isdefined(tree, :root))
        root=tree.root
        if(!isleaf(root))

            if(!isleftleaf(root))
                treestring, linenow = buildstringR(treestring, root.left, root, linenow)
            else
                treestring, linenow = leafstring(treestring, root, linenow)
            end

            if(!isrightleaf(root))
                treestring, linenow = buildstringR(treestring, root.right, root, linenow)
            else
                treestring, linenow = leafstring(treestring, root, linenow)
            end

        end

    end

    return treestring
end

function leafstring{K,V}(treestring::ASCIIString, parent::TreeNode{K,V}, linenow::Int)

    linkstring = """null$(linenow) [shape=point];
    $(parent.value.value) -> null$(linenow);
    """
    treestring = replace(treestring, linenow, linenow+1, linkstring)
    linenow += length(linkstring)

    return treestring, linenow
end


function buildstringR{K,V}(treestring::ASCIIString, node::TreeNode{K,V}, parent::TreeNode{K,V}, linenow::Int)

    nodestring = string(node.value.value)*";\n"
    linkstring = string(parent.value.value)*" -> "*nodestring
    if(node.isRed)
        len=length(linkstring)
        linkstring = replace(linkstring, len-2, len-1, " [color=red]")
    end
    treestring = replace(treestring, linenow, linenow+1, linkstring)
    linenow += length(linkstring)

    if(!isleftleaf(node))
        treestring, linenow = buildstringR(treestring, node.left, node, linenow)
    else
        treestring, linenow = leafstring(treestring, node, linenow)
    end

    if(!isrightleaf(node))
        treestring, linenow = buildstringR(treestring, node.right, node, linenow)
    else
        treestring, linenow = leafstring(treestring, node, linenow)
    end

    return treestring, linenow
end

function display{K,V}(tree::LLRBTree{K,V})
    GraphViz.Graph(buildstring(tree))
end


#LLRBVisualize end
end
