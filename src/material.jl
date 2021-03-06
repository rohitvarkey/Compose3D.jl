using Colors

export normalcolors, lambert, basic, phong, visible, edges

abstract MaterialPrimitive

immutable Material{P<:MaterialPrimitive} <: Compose3DNode
    primitives::Vector{P}
end

isscalar(material::Material) = length(material.primitives) == 1

immutable MeshColor <: MaterialPrimitive
    color::Color
end

function mesh_color(color::Color)
    Material([MeshColor(color)])
end

function mesh_color(colorString::AbstractString)
    Material([MeshColor(parse(Colorant, colorString))])
end

immutable WireFrameMesh <: MaterialPrimitive
    wireframe::Bool
end

function wireframe(wireframe::Bool)
    Material([WireFrameMesh(wireframe)])
end

immutable MaterialKind <: MaterialPrimitive
    kind::AbstractString
end

function normalcolors()
    Material([MaterialKind("normal")])
end

function lambert()
    Material([MaterialKind("lambert")])
end

function basic()
    Material([MaterialKind("basic")])
end

function phong()
    Material([MaterialKind("phong")])
end


immutable Visiblity <: MaterialPrimitive
    visible::Bool
end

function visible(visible::Bool)
    Material([Visiblity(visible)])
end

immutable Edges <: MaterialPrimitive
    color::Color
end

function edges(color::Color)
    Material([Edges(color)])
end

function edges(colorString::AbstractString="black")
    Material([Edges(parse(Colorant, colorString))])
end

function resolve(box::Absolute3DBox, prop::Material)
    prop
end
