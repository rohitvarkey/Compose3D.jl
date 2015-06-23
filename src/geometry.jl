#abstract GeometryPrimitive
using GeometryTypes

#Geometry type.
immutable Geometry{P <: GeometryPrimitive} <: Compose3DNode
	primitives::Vector{P}
end

#conversion functions between GeometryTypes and Compose Point definitions.
import Base.convert
convert(::Type{Point},p::GeometryTypes.Point3) = Point(p.x,p.y,p.z)
convert(::Type{GeometryTypes.Point3},p::Point{3}) = GeometryTypes.Point3(p.x[1],p.x[2],p.x[3])

resolve(box::BoundingBox, p::GeometryTypes.Point3) = resolve(box,convert(Point, p))
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

typealias Sphere Geometry{GeometryTypes.Sphere}
typealias SpherePrimitive GeometryTypes.Sphere

function sphere(x::Length,y::Length,z::Length,radius::Length)
	return Sphere([SpherePrimitive(GeometryTypes.Point3(x,y,z),radius)])
end

function resolve(box::Absolute3DBox, sphere::SpherePrimitive)
	absCenterCoords = resolve(box,sphere.center)
	absCenter = GeometryTypes.Point3(absCenterCoords[1],absCenterCoords[2],absCenterCoords[3])
	absRadius = resolve(box, sphere.r)mm
	return SpherePrimitive(absCenter,absRadius)
end

#Pyramid

immutable PyramidPrimitive <: GeometryPrimitive
	corner::Point{3}
	base::Length
	height::Length
end

typealias Pyramid Geometry{PyramidPrimitive}

PyramidPrimitive(x::Length,y::Length,z::Length,base::Length,height::Length) = PyramidPrimitive(Point(x,y,z),base,height)

function pyramid(x::Length,y::Length,z::Length,base::Length, height::Length)
	return Pyramid([PyramidPrimitive(x::Length,y::Length,z::Length,base::Length,height::Length)])
end

function resolve(box::Absolute3DBox, pyramid::PyramidPrimitive)
	absCorner = Point(resolve(box,pyramid.corner))
	absBase = resolve(box, pyramid.base)mm
	absHeight = resolve(box, pyramid.height)mm
	return PyramidPrimitive(absCorner,absBase,absHeight)
end
