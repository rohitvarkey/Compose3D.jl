abstract GeometryPrimitive

#Geometry type.
immutable Geometry{P <: GeometryPrimitive} <: Compose3DNode
	primitives::Vector{P}
end

#Cube

immutable CubePrimitive <: GeometryPrimitive
	corner::Point{3}
	side::Length{:mm}
end

typealias Cube Geometry{CubePrimitive}

CubePrimitive(x::Length,y::Length,z::Length,side::Length) = CubePrimitive(Point(x,y,z),side)

function cube(x::Length,y::Length,z::Length,side::Length)
	return Cube([CubePrimitive(x::Length,y::Length,z::Length,side::Length)])
end