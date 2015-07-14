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

function push_material_frame(backend::Patchable3D, vector_properties::Dict{Type,Material})
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
            Elem(:"three-js-camera",x=20,y=20,z=20);
            Elem(:"three-js-light",kind="spot",x=30,y=30,z=30);
            Elem(:"three-js-light",kind="spot",x=-20,y=-20,z=-40);
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

function draw(backend::Patchable3D, cube::CubePrimitive)
    side = cube.side.value
    x = cube.corner.x[1].value
    y = cube.corner.x[2].value
    z = cube.corner.x[3].value
    
    elem = Elem(:"three-js-mesh",x=x,y=y,z=z,
    [
        Elem(:"three-js-geometry",w=side,h=side,d=side),
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
