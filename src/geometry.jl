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

#Sphere

immutable SpherePrimitive <: GeometryPrimitive
	center::Point{3}
	radius::Length
end

typealias Sphere Geometry{SpherePrimitive}

SpherePrimitive(x::Length,y::Length,z::Length,radius::Length) = SpherePrimitive(Point(x,y,z),radius)

function sphere(x::Length,y::Length,z::Length,radius::Length)
	return Sphere([SpherePrimitive(x::Length,y::Length,z::Length,radius::Length)])
end

function resolve(box::Absolute3DBox, sphere::SpherePrimitive)
	absCenter = Point(resolve(box,sphere.center))
	absRadius = resolve(box, sphere.radius)mm
	return SpherePrimitive(absCenter,absRadius)
end