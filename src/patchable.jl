# The Patchable backend

import Patchwork
import Patchwork.Elem

export Patchable3D

type Patchable3D <: Backend
    width::Float64
    height::Float64
    material_tag::Elem{:xhtml,symbol("three-js-material")} #Current materials in effect
    vector_properties::Vector
    lights::Bool

    function Patchable3D(width, height)
        new(width,
            height,
            Elem(:"three-js-material"),
            Any[],
            false)
    end
end

vector_properties(backend::Patchable3D) = if !isempty(backend.vector_properties)
    backend.vector_properties[end]
end

function properties_at_index(img, prop_vecs, i)
    props = Dict()
    for (proptype, property) in prop_vecs
        if i > length(property.primitives)
            error("Vector of properties and vector of forms have different length")
        end
        draw!(img, property.primitives[i], props)
    end
    props
end
# Add to functions
# ----------------

typealias ThreeJSPart Elem{:xhtml,symbol("three-js-mesh")}
#typealias ThreeJSPart Union(
#    Elem{:xhtml,symbol("three-js-mesh")},
#    Elem{:xhtml,symbol("three-js-camera")},
#    Elem{:xhtml,symbol("three-js-light")}
#    )

addto(::Patchable3D, acc::Nothing, child::Nothing) = acc
addto(::Patchable3D, acc::Nothing, child::Vector{Elem}) = child
addto(::Patchable3D, acc::Vector{Elem}, child::Nothing) = acc
addto(::Patchable3D, acc::Vector{Elem}, child::Vector{Elem}) = [ acc; child ]
addto(::Patchable3D, acc::Vector{Elem}, child::Elem) = [ acc; child ]
addto(::Patchable3D, acc::Nothing, child::Elem) =  Elem[child]
addto(::Patchable3D, 
    elem::Elem{:xhtml,symbol("three-js-mesh")},
    child::Elem{:xhtml,symbol("three-js-material")}) = 
    elem << child
function addto(backend::Patchable3D, acc::Nothing, child::Dict)
    backend.material_tag = backend.material_tag & child
    acc
end

# Material addition and removal
# -----------------------------

function push_material_frame(
        backend::Patchable3D, 
        vector_properties::Dict{Type,Material}
    )
    push!(backend.vector_properties, vector_properties)
end

function pop_material_frame(backend::Patchable3D)
    pop!(backend.vector_properties)
end

# Draw functions
# --------------

function draw(backend::Patchable3D, root::Context)
    
    camera = nothing
    for child in root.children
        if isa(child, Camera)
            camera = child
        end
    end

    root = Elem(:"three-js",
        [
            draw_recursive(backend, root);
        ]
        )
    #TODO: Make this better by figuring out max and min x,y and z.
        if camera == nothing
        root = root << Elem(:"three-js-camera",x=-20,y=0,z=25);
    else
        root = root << draw(backend,camera)
    end
    if !(backend.lights)
       root = root << Elem(:"three-js-light",kind="spot",x=0,y=-30,z=0) 
       root = root << Elem(:"three-js-light",kind="spot",x=-0,y=20,z=0)
    end
    root
end

# Form drawing
# ------------

function draw(backend::Patchable3D, parent_box::AbsoluteBox, geometry::Geometry)
    acc = Array(Elem, length(geometry.primitives))
    properties = vector_properties(backend)
    for primitive in geometry.primitives
        for i in 1:length(geometry.primitives)
            elem = draw(backend, resolve(parent_box,geometry.primitives[i]))
            if properties !== nothing && !isempty(properties)
                props = properties_at_index(backend, properties, i)
            else
                props = Dict()
            end
            tag = backend.material_tag & props
            elem = addto(backend, elem, tag)
            acc[i] = elem
        end
    end
    acc
end

function draw(backend::Patchable3D, cube::BoxPrimitive)
    width= cube.width.value
    height = cube.height.value
    depth = cube.depth.value
    x = cube.center[1].value
    y = cube.center[2].value
    z = cube.center[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-box",w=width,h=height,d=depth),
    ])
    elem
end

function draw(backend::Patchable3D, sphere::SpherePrimitive)
    radius = sphere.radius.value
    x = sphere.center[1].value
    y = sphere.center[2].value
    z = sphere.center[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-sphere",r=radius),
    ])
    elem
end

function draw(backend::Patchable3D, pyramid::PyramidPrimitive)
    height = pyramid.height.value
    base = pyramid.base.value
    x = pyramid.corner[1].value
    y = pyramid.corner[2].value
    z = pyramid.corner[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-pyramid",base=base, height=height),
    ])
    elem
end

function draw(backend::Patchable3D, cylinder::CylinderPrimitive)
    top = cylinder.topradius.value
    bottom = cylinder.bottomradius.value
    height = cylinder.height.value
    x = cylinder.center[1].value
    y = cylinder.center[2].value
    z = cylinder.center[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-cylinder",top=top, bottom=bottom, height=height),
    ])
    elem
end

function draw(backend::Patchable3D, torus::TorusPrimitive)
    radius = torus.radius.value
    tube = torus.tubediameter.value
    x = torus.center[1].value
    y = torus.center[2].value
    z = torus.center[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-torus",r=radius, tube=tube),
    ])
    elem
end

function draw(backend::Patchable3D, p::ParametricPrimitive)
    x = p.origin[1].value
    y = p.origin[2].value
    z = p.origin[3].value

    mesh = Elem(:"three-js-mesh",x=x,y=y,z=z,)

    if p.mesh
        geom = Elem(:"three-js-meshlines",slices=p.slices,stacks=p.stacks)
    else
        geom = Elem(:"three-js-parametric",slices=p.slices,stacks=p.stacks)
    end

    xrange = linspace(p.xrange.start,p.xrange.stop,p.slices+1)
    yrange = linspace(p.yrange.start,p.yrange.stop,p.stacks+1)
    vertices=[Elem(:"three-js-vertex",x=x,z=y,y=p.f(x,y)) for x=xrange,y=yrange]

    geom = geom << vertices
    mesh << geom
end

# Material primitives
# -------------------

function draw(img::Patchable3D, prop::Material)
    dict = Dict()
    for prim in prop.primitives
        draw!(img, prim, dict)
    end
    dict
end

function draw!(img::Patchable3D, prim::MaterialPrimitive, dict)
    item = draw(img, prim)
    if !is(item, nothing)
        k, v = item
        dict[k] = v
    end
end

function draw(img::Patchable3D, prim::MeshColor)
    color = string("#" * hex(prim.color))
    :color, color
end

function draw(img::Patchable3D, wireframe::WireFrameMesh)
    :wireframe, wireframe.wireframe
end

function draw(img::Patchable3D, kind::MaterialKind)
    :kind, kind.kind
end

function draw(img::Patchable3D, visibility::Visiblity)
    :visible, visibility.visible
end

function draw(img::Patchable3D, edges::Edges)
    :edges, "true" #Make this return edgeColor also.
end
# Lights
# ------

function draw(img::Patchable3D, parent_box::AbsoluteBox, light::Light)
    draw(img, resolve(parent_box, light))
end

function draw(img::Patchable3D, light::AmbientLight)
    color = string("#" * hex(light.color))
    elem = Elem(:"three-js-light", kind="ambient", color=color)
    elem
end

function draw(img::Patchable3D, light::PointLight)
    color = string("#" * hex(light.color))
    elem = Elem(
        :"three-js-light", 
        kind="point", 
        color=color, 
        intensity=light.intensity,
        distance=light.distance.value,
        x=light.position[1].value,
        y=light.position[2].value,
        z=light.position[3].value,
    )
    elem
end

function draw(img::Patchable3D, light::SpotLight)
    color = string("#" * hex(light.color))
    elem = Elem(
        :"three-js-light", 
        kind="spot", 
        color=color, 
        intensity=light.intensity,
        distance=light.distance.value,
        angle=light.angle,
        exponent=light.exponent,
        shadow=light.shadow,
        x=light.position[1].value,
        y=light.position[2].value,
        z=light.position[3].value,
    )
    elem
end

# Cameras
# -------

function draw(img::Patchable3D, camera::PerspectiveCamera)
    elem = Elem(
        :"three-js-camera",
        x=camera.position[1].value,
        y=camera.position[2].value,
        z=camera.position[3].value,
        fov=camera.fov,
        aspect=camera.fov,
        near=camera.near,
        far=camera.far,
        kind="perspective"
    )
    elem
end

#writemime for signals.
if isinstalled("Reactive")

    import Base: writemime
    import Reactive: Signal, lift

    if isdefined(Main, :IJulia)
        import IJulia: metadata
        metadata{T <: Compose3DNode}(::Signal{T}) = Dict()
    end

    function writemime{T <: Compose3DNode}(io::IO, m::MIME"text/html", ctx::Signal{T})
        writemime(io, m, lift(c ->
        Elem(:div, style=@compat Dict(:width=>"100%", :height=>"600px")) <<
            draw(
                Patchable3D(
                    100,
                    100,
                ), c), ctx)
        )
    end
end
