using Color

abstract MaterialPrimitive

immutable Material{P<:MaterialPrimitive}
    primitives::Vector{P}
end

immutable MeshColor{T<:ColorValue} <: MaterialPrimitive
    color::T
end

immutable WireFrameMesh <: MaterialPrimitive
    wireframe::Bool
end

function mesh_color(color::ColorValue)
    Material([MeshColor(color)])
end
