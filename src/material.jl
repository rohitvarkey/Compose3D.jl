using Color

abstract MaterialPrimitive

immutable Material{P<:MaterialPrimitive} <: Compose3DNode
    primitives::Vector{P}
end

immutable MeshColor <: MaterialPrimitive
    color::RGB{Float64}
end

immutable WireFrameMesh <: MaterialPrimitive
    wireframe::Bool
end

function mesh_color(color::RGB{Float64})
    Material([MeshColor(color)])
end

function mesh_color(color::ColorValue)
    Material([MeshColor(convert(RGB{Float64},color))])
end

function mesh_color(colorString::AbstractString)
    Material([MeshColor(color(colorString))])
end

function wireframe(wireframe::Bool)
    Material([WireFrameMesh(wireframe)])
end
