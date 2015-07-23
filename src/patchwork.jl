# The Patchable backend

import Patchwork
import Patchwork.Elem

export Patchable3D

type Patchable3D <: Backend
    width::Float64 #shouldn't these be mm?
    height::Float64 
    material_tag::Elem{:xhtml,symbol("three-js-material")} #Current materials in effect
    vector_properties::Vector

    function Patchable3D(width, height)
        new(width,
            height,
            Elem(:"three-js-material"),
            Any[])
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
    
    root = Elem(:"three-js",
        [
            draw_recursive(backend, root);
            #TODO : Check for cameras and lights specified before assigning defaults
            Elem(:"three-js-camera",x=-20,y=0,z=25);
            Elem(:"three-js-light",kind="spot",x=0,y=-30,z=0);
            Elem(:"three-js-light",kind="spot",x=-0,y=20,z=0);
        ]
        )
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
    x = cube.center.x[1].value
    y = cube.center.x[2].value
    z = cube.center.x[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-box",w=width,h=height,d=depth),
    ])
    elem
end

function draw(backend::Patchable3D, sphere::SpherePrimitive)
    radius = sphere.radius.value
    x = sphere.center.x[1].value
    y = sphere.center.x[2].value
    z = sphere.center.x[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-sphere",r=radius),
    ])
    elem
end

function draw(backend::Patchable3D, pyramid::PyramidPrimitive)
    height = pyramid.height.value
    base = pyramid.base.value
    x = pyramid.corner.x[1].value
    y = pyramid.corner.x[2].value
    z = pyramid.corner.x[3].value
    
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
    x = cylinder.center.x[1].value
    y = cylinder.center.x[2].value
    z = cylinder.center.x[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-cylinder",top=top, bottom=bottom, height=height),
    ])
    elem
end

function draw(backend::Patchable3D, torus::TorusPrimitive)
    radius = torus.radius.value
    tube = torus.tubediameter.value
    x = torus.center.x[1].value
    y = torus.center.x[2].value
    z = torus.center.x[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-torus",r=radius, tube=tube),
    ])
    elem
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
