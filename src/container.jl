abstract Container <: Compose3DNode

type Context <: Container
	box::BoundingBox #Parent box.
	geometry_children::List{Geometry}
	material_children::List{Material}
	container_children::List{Container}
	light_children::List{Light}
	camera::Union{Camera, Void}
end

Context(x0::Length,y0::Length,z0::Length,width::Length,height::Length,depth::Length) =
    Context(
			BoundingBox(x0,y0,z0,width,height,depth),
			ListNull{Geometry}(),
			ListNull{Material}(),
			ListNull{Container}(),
			ListNull{Light}(),
			nothing
		)

Context(ctx::Context) = Context(
		ctx.box,
		ctx.geometry_children,
		ctx.material_children,
		ctx.container_children,
		ctx.light_children,
		ctx.camera
)

function copy(ctx::Context)
    return Context(ctx)
end

#Compositions.

function compose!(a::Context, b::Container)
    a.container_children = cons(b, a.container_children)
    return a
end


function compose!(a::Context, b::Geometry)
    a.geometry_children = cons(b, a.geometry_children)
    return a
end


function compose!(a::Context, b::Material)
    a.material_children = cons(b, a.material_children)
    return a
end

function compose!(a::Context, b::Light)
    a.light_children = cons(b, a.light_children)
    return a
end

function compose!(a::Context, b::Camera)
    a.camera = b
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

function draw(backend::Backend, root_container::Context)
    drawpart(backend, root_container, root_box(backend))
    finish(backend)
end


# Draw without finishing the backend
#
# Drawing is basically a depth-first traversal of the tree, pushing and popping
# properties, expanding context promises, etc. as needed.
#
function drawpart(backend::Backend, container::Container,
                  parent_box::Absolute3DBox)

    # used to collect property children
    properties = Array(Material, 0)
    ctx = container
    box = resolve(parent_box, ctx.box)

    child = ctx.material_children

    while !isa(child, ListNull)
        push!(properties, resolve(parent_box, child.head))
        child = child.tail
    end

    if !isempty(properties)
        push_property_frame(backend, properties)
    end

    child = ctx.geometry_children
    while !isa(child, ListNull)
        draw(backend, box, child.head)
        child = child.tail
    end

		child = ctx.light_children
    while !isa(child, ListNull)
        draw(backend, box, child.head)
        child = child.tail
    end

		if ctx.camera!=nothing
				draw(backend, box, ctx.camera)
		end

    child = ctx.container_children
    while !isa(child, ListNull)
        drawpart(backend, child.head, box)
        child = child.tail
    end

    if !isempty(properties)
        pop_property_frame(backend)
    end
end
