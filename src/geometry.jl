abstract GeometryPrimitive

#Geometry type.
immutable Geometry{P <: GeometryPrimitive} <: Compose3DNode
	primitives::Vector{P}
end

#Cube

immutable CubePrimitive <: GeometryPrimitive
	corner::Point{3}
	side::Length
end

typealias Cube Geometry{CubePrimitive}

CubePrimitive(x::Length,y::Length,z::Length,side::Length) = CubePrimitive(Point(x,y,z),side)

function cube(x::Length,y::Length,z::Length,side::Length)
	return Cube([CubePrimitive(x::Length,y::Length,z::Length,side::Length)])
end

function resolve(box::Absolute3DBox, cube::CubePrimitive)
	absCorner = Point(resolve(box,cube.corner))
	absSide = resolve(box, cube.side)mm
	return CubePrimitive(absCorner,absSide)
end