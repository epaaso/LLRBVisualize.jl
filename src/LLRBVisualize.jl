module LLRBVisualize

using LLRBTrees
import Base: replace, display

export buildstring, draw

include("GraphViz.jl")

function buildstring{K,V}(tree::LLRBTree{K,V})
    if(isdefined(tree, :root))
        root=tree.root
        if(!isleaf(root))
            treestring = """
            digraph tree {

                }
                """
            linenow = 16

            nodestring = string(tree.root.value.value)*";\n"
            treestring = replace(treestring, linenow, linenow+1, nodestring)
            linenow += length(nodestring)

            if(!isleftleaf(root))
                treestring, linenow = buildstringR(treestring, root.left, root, linenow)
            end

            if(!isrightleaf(root))
                treestring, linenow = buildstringR(treestring, root.right, root, linenow)
            end

        end
    else
        Base.error("root is null")
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
