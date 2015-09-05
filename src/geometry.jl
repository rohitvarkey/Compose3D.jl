abstract GeometryPrimitive

#Geometry type.
immutable Geometry{P <: GeometryPrimitive} <: Compose3DNode
	primitives::Vector{P}
end

#Cube

immutable BoxPrimitive <: GeometryPrimitive
	center::Vec3
	width::Length
	height::Length
	depth::Length
end

typealias Box Geometry{BoxPrimitive}

BoxPrimitive(x::Length,y::Length,z::Length,w::Length,h::Length,d::Length) = 
    BoxPrimitive((x,y,z),w,h,d)
BoxPrimitive(x::Length,y::Length,z::Length,side::Length) = 
    BoxPrimitive((x,y,z),side,side,side)

cube(x::Length,y::Length,z::Length,side::Length) = Box([BoxPrimitive(x,y,z,side)])

cube(side::Length) = Box([BoxPrimitive(0mm,0mm,0mm,side)])

box(x::Length,y::Length,z::Length,w::Length,h::Length,d::Length) = 
    Box([BoxPrimitive(x,y,z,w,h,d)])

box(w::Length,h::Length,d::Length) = Box([BoxPrimitive(0mm,0mm,0mm,w,h,d)])

function resolve(box::Absolute3DBox, cube::BoxPrimitive)
	rescenter = resolve(box,cube.center)
	width = resolve(box, cube.width)
	height = resolve(box, cube.height)
	depth = resolve(box, cube.depth)
	BoxPrimitive(rescenter,width,height,depth)
end

#Sphere

immutable SpherePrimitive <: GeometryPrimitive
	center::Vec3
	radius::Length
end

typealias Sphere Geometry{SpherePrimitive}

SpherePrimitive(x::Length,y::Length,z::Length,radius::Length) = 
    SpherePrimitive((x,y,z),radius)

sphere(x::Length,y::Length,z::Length,radius::Length) = 
    Sphere([SpherePrimitive(x,y,z,radius)])

sphere(radius::Length) = Sphere([SpherePrimitive(0mm,0mm,0mm,radius)])

function resolve(box::Absolute3DBox, sphere::SpherePrimitive)
	abscenter = resolve(box,sphere.center)
	absradius = resolve(box, sphere.radius)
	SpherePrimitive(abscenter,absradius)
end

#Pyramid

immutable PyramidPrimitive <: GeometryPrimitive
	corner::Vec3
	base::Length
	height::Length
end

typealias Pyramid Geometry{PyramidPrimitive}

PyramidPrimitive(x::Length,y::Length,z::Length,base::Length,height::Length) = 
    PyramidPrimitive((x,y,z),base,height)

pyramid(x::Length,y::Length,z::Length,base::Length,height::Length) = 
    Pyramid([PyramidPrimitive((x,y,z),base,height)])
pyramid(base::Length, height::Length) = 
    Pyramid([PyramidPrimitive(0mm,0mm,0mm,base,height)])

function resolve(box::Absolute3DBox, pyramid::PyramidPrimitive)
	abscorner = resolve(box,pyramid.corner)
	absbase = resolve(box, pyramid.base)
	absheight = resolve(box, pyramid.height)
	PyramidPrimitive(abscorner,absbase,absheight)
end

#Cylinder 

immutable CylinderPrimitive <: GeometryPrimitive
    center::Vec3
    topradius::Length
    bottomradius::Length
    height::Length
end

typealias Cylinder Geometry{CylinderPrimitive}

CylinderPrimitive(x::Length, y::Length, z::Length, top::Length, bottom::Length, height::Length) = 
    CylinderPrimitive((x,y,z),top,bottom,height)

cylinder(x::Length,y::Length,z::Length,top::Length,bottom::Length,height::Length) = 
    Cylinder([CylinderPrimitive(x,y,z,top,bottom,height)])
cylinder(top::Length,bottom::Length,height::Length) = 
    Cylinder([CylinderPrimitive(0mm,0mm,0mm,top,bottom,height)])

function resolve(box::Absolute3DBox, cylinder::CylinderPrimitive)
    abscenter = resolve(box, cylinder.center)
    abstop = resolve(box, cylinder.topradius)
    absbottom = resolve(box, cylinder.bottomradius)
    absheight = resolve(box, cylinder.height)
    CylinderPrimitive(abscenter, abstop, absbottom, absheight)
end

immutable TorusPrimitive <: GeometryPrimitive
    center::Vec3
    radius::Length
    tubediameter::Length
end

typealias Torus Geometry{TorusPrimitive}

TorusPrimitive(x::Length,y::Length,z::Length,r::Length,tube::Length) = 
    TorusPrimitive((x,y,z),r,tube)

torus(x::Length,y::Length,z::Length,r::Length,tube::Length) = 
    Torus([TorusPrimitive(x,y,z,r,tube)])
torus(r::Length,tube::Length) = Torus([TorusPrimitive(0mm,0mm,0mm,r,tube)])

function resolve(box::Absolute3DBox, torus::TorusPrimitive)
    abscenter = resolve(box, torus.center)
    absradius = resolve(box, torus.radius)
    abstube = resolve(box, torus.tubediameter)
    TorusPrimitive(abscenter, absradius, abstube)
end

immutable ParametricPrimitive <: GeometryPrimitive
    origin::Vec3
    f::Function
    slices::Integer
    stacks::Integer
    xrange::Range
    yrange::Range
    mesh::Bool
end

typealias Parametric Geometry{ParametricPrimitive}

ParametricPrimitive(
    x::Length,y::Length,z::Length,f::Function,slices::Integer,stacks::Integer,
    xrange::Range, yrange::Range, mesh::Bool)=
    ParametricPrimitive((x,y,z),f,slices,stacks, xrange, yrange, mesh)

parametric(
    x::Length,y::Length,z::Length,f::Function,slices::Integer,stacks::Integer,
    xrange::Range, yrange::Range; mesh::Bool=false)=
        Parametric([ParametricPrimitive(x,y,z,f,slices,stacks,mesh)])

parametric(f::Function,slices::Integer,stacks::Integer,x::Range,y::Range; mesh::Bool=false)=
        Parametric([ParametricPrimitive(0mm,0mm,0mm,f,slices,stacks,x,y,mesh)])

function resolve(box::Absolute3DBox, parametricsurf::ParametricPrimitive)
    absorigin = resolve(box, parametricsurf.origin)
    ParametricPrimitive(
        absorigin,
        parametricsurf.f,
        parametricsurf.slices,
        parametricsurf.stacks,
        parametricsurf.xrange,
        parametricsurf.yrange,
        parametricsurf.mesh
    )
end
