
type Context <: Compose3DNode
	box :: BoundingBox #Parent box.
	children :: List{Compose3DNode}
end

Context(x0::Length,y0::Length,z0::Length,width::Length,height::Length,depth::Length) = Context(BoundingBox(x0,y0,z0,width,height,depth),ListNull{Compose3DNode}())

Context(ctx::Context) = Context(ctx.box,ctx.children)

function draw(backend::Backend, root_canvas::Context)
    # TODO: Traverse the tree in DFS manner. And generate JS code to render stuff. \
    # Also use the resolve method to convert relative measures to absolute ones.
    # Hack try for now.
    children = root_canvas.children
    box = root_canvas.box
    # Resolve the parent box here.
    for child in children
    	if isa(child,Geometry)
    		for primitive in child.primitives
    			backend = draw(backend,box,primitive)
    		end
    	end
    end
    return backend
end

function copy(ctx::Context)
    return Context(ctx)
end

#Compositions.

function compose!(a::Context, b::Compose3DNode)
    a.children = cons(b, a.children)
    return a
end


function compose(a::Context, b::Compose3DNode)
    a = copy(a)
    compose!(a, b)
    return a
end


# higher-order compositions
function compose!(a::Context, b, c, ds...)
    return compose!(compose!(a, b), c, ds...)
end


function compose!(a::Context, bs::AbstractArray)
    compose!(a, compose!(bs...))
end


function compose!(a::Context, bs::Tuple)
    compose!(a, compose!(bs...))
end


function compose!(a::Context)
    return a
end


function compose(a::Context, b, c, ds...)
    return compose(compose(a, b), c, ds...)
end


function compose(a::Context, bs::AbstractArray)
    compose(a, compose(bs...))
end


function compose(a::Context, bs::Tuple)
    compose(a, compose(bs...))
end


function compose(a::Context)
    return a
end