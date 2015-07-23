abstract GeometryPrimitive

#Geometry type.
immutable Geometry{P <: GeometryPrimitive} <: Compose3DNode
	primitives::Vector{P}
end

#Cube

immutable BoxPrimitive <: GeometryPrimitive
	center::Point{3}
	width::Length
	height::Length
	depth::Length
end

typealias Box Geometry{BoxPrimitive}

BoxPrimitive(x::Length,y::Length,z::Length,w::Length,h::Length,d::Length) = BoxPrimitive(Point(x,y,z),w,h,d)
BoxPrimitive(x::Length,y::Length,z::Length,side::Length) = BoxPrimitive(Point(x,y,z),side,side,side)

cube(x::Length,y::Length,z::Length,side::Length) = Box([BoxPrimitive(x,y,z,side)])

cube(side::Length) = Box([BoxPrimitive(0mm,0mm,0mm,side)])

box(x::Length,y::Length,z::Length,w::Length,h::Length,d::Length) = Box([BoxPrimitive(x,y,z,w,h,d)])

box(w::Length,h::Length,d::Length) = Box([BoxPrimitive(0mm,0mm,0mm,w,h,d)])

function resolve(box::Absolute3DBox, cube::BoxPrimitive)
	rescenter = Point(resolve(box,cube.center))
	width = resolve(box, cube.width)mm
	height = resolve(box, cube.height)mm
	depth = resolve(box, cube.depth)mm
	return BoxPrimitive(rescenter,width,height,depth)
end

#Sphere

immutable SpherePrimitive <: GeometryPrimitive
	center::Point{3}
	radius::Length
end

typealias Sphere Geometry{SpherePrimitive}

SpherePrimitive(x::Length,y::Length,z::Length,radius::Length) = SpherePrimitive(Point(x,y,z),radius)

sphere(x::Length,y::Length,z::Length,radius::Length) = Sphere([SpherePrimitive(x,y,z,radius)])

sphere(radius::Length) = Sphere([SpherePrimitive(0mm,0mm,0mm,radius)])

function resolve(box::Absolute3DBox, sphere::SpherePrimitive)
	abscenter = Point(resolve(box,sphere.center))
	absradius = resolve(box, sphere.radius)mm
	return SpherePrimitive(abscenter,absradius)
end

#Pyramid

immutable PyramidPrimitive <: GeometryPrimitive
	corner::Point{3}
	base::Length
	height::Length
end

typealias Pyramid Geometry{PyramidPrimitive}

PyramidPrimitive(x::Length,y::Length,z::Length,base::Length,height::Length) = PyramidPrimitive(Point(x,y,z),base,height)

pyramid(x::Length,y::Length,z::Length,base::Length,height::Length) = Pyramid([PyramidPrimitive(Point(x,y,z),base,height)])
pyramid(base::Length, height::Length) = Pyramid([PyramidPrimitive(0mm,0mm,0mm,base,height)])

function resolve(box::Absolute3DBox, pyramid::PyramidPrimitive)
	abscorner = Point(resolve(box,pyramid.corner))
	absbase = resolve(box, pyramid.base)mm
	absheight = resolve(box, pyramid.height)mm
	return PyramidPrimitive(abscorner,absbase,absheight)
end

#Cylinder 

immutable CylinderPrimitive <: GeometryPrimitive
    center::Point{3}
    topradius::Length
    bottomradius::Length
    height::Length
end

typealias Cylinder Geometry{CylinderPrimitive}

CylinderPrimitive(x::Length, y::Length, z::Length, top::Length, bottom::Length, height::Length) = 
    CylinderPrimitive(Point(x,y,z),top,bottom,height)

cylinder(x::Length,y::Length,z::Length,top::Length,bottom::Length,height::Length) = 
    Cylinder([CylinderPrimitive(x,y,z,top,bottom,height)])
cylinder(top::Length,bottom::Length,height::Length) = 
    Cylinder([CylinderPrimitive(0mm,0mm,0mm,top,bottom,height)])

function resolve(box::Absolute3DBox, cylinder::CylinderPrimitive)
    abscenter = Point(resolve(box, cylinder.center))
    abstop = resolve(box, cylinder.topradius)mm
    absbottom = resolve(box, cylinder.bottomradius)mm
    absheight = resolve(box, cylinder.height)mm
    CylinderPrimitive(abscenter, abstop, absbottom, absheight)
end

immutable TorusPrimitive <: GeometryPrimitive
    center::Point{3}
    radius::Length
    tubediameter::Length
end

typealias Torus Geometry{TorusPrimitive}

TorusPrimitive(x::Length,y::Length,z::Length,r::Length,tube::Length) = 
    TorusPrimitive(Point(x,y,z),r,tube)

torus(x::Length,y::Length,z::Length,r::Length,tube::Length) = 
    Torus([TorusPrimitive(x,y,z,r,tube)])
torus(r::Length,tube::Length) = Torus([TorusPrimitive(0mm,0mm,0mm,r,tube)])

function resolve(box::Absolute3DBox, torus::TorusPrimitive)
    abscenter = Point(resolve(box, torus.center))
    absradius = resolve(box, torus.radius)mm
    abstube = resolve(box, torus.tubediameter)mm
    TorusPrimitive(abscenter, absradius, abstube)
end
