
type Context <: Compose3DNode
	box :: BoundingBox #Parent box.
	children :: List{Compose3DNode}
end

Context(x0::Length,y0::Length,z0::Length,width::Length,height::Length,depth::Length) = Context(BoundingBox(x0,y0,z0,width,height,depth),ListNull{Compose3DNode}())

Context(ctx::Context) = Context(ctx.box,ctx.children)

function draw(backend::Backend, root_canvas::Context)
    # Does a DFS traversal of the compose tree.
    # Checks for contexts, and geometries and resolves and draws them as needed.
    children = root_canvas.children
    parent_box = root_canvas.box
    material_frame = copy(backend.material_stack[end].materials)
    pushed_frame = false
    @assert isa(parent_box, AbsoluteBox)

    for child in children
        if isa(child,Material)
            material_frame[typeof(child)] = child
        end
    end
    
    if material_frame != backend.material_stack[end].materials
        backend = push_material_frame(backend,material_frame)
        pushed_frame = true
    end

    for child in children
    	if isa(child,Geometry)
    		for primitive in child.primitives
    			backend = draw(backend,parent_box,primitive)
    		end
    	end
    	if isa(child, Context)
    		child = Context(resolve(parent_box,child.box),child.children)
    		backend = draw(backend,child)
    	end
    end
    
    if pushed_frame
        backend = pop_material_frame(backend)
    end
    
    return backend
end

function draw_recursive(backend::Backend, root_canvas::Context)
    # Does a DFS traversal of the compose tree.
    # Checks for contexts, and geometries and resolves and draws them as needed.
    children = root_canvas.children
    parent_box = root_canvas.box
    vector_properties = Dict{Type, Material}()
    acc = nothing

    @assert isa(parent_box, AbsoluteBox)

    for child in children
        if isa(child,Material)
            if isscalar(child)
               acc = addto(backend,acc,draw(backend,child))
            else
                vector_properties[typeof(child)] = child
            end
        end
    end
 
    pop_frame = false
    if !isempty(vector_properties)
        push_material_frame(backend,vector_properties)
        pop_frame = true
    end

    for child in children
    	if isa(child,Geometry)
            acc = addto(backend, acc, draw(backend, parent_box, child))
        
        elseif isa(child, Context)
    		child = Context(resolve(parent_box,child.box),child.children)
    		acc = addto(backend, acc, draw_recursive(backend,child)) #Add order sorting before this.
    	end
    end
    
    if pop_frame
        backend = pop_material_frame(backend)
    end

    acc
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
