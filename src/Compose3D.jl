module Compose3D

# Defining compose node type
abstract Compose3DNode

abstract Backend

import Base: length, start, next, done, isempty, getindex, setindex!,
             display, writemime, convert, zero, isless, max, fill, size, copy,
             min, max, +, -, *, /

#Including files.
include("measure.jl")
include("list.jl")
include("container.jl")
include("geometry.jl")
include("material.jl")
include("webgl.jl")

#Setting up three js files required to display stuff.
#TODO: Do this only if the MIME is "text/html"
threejsFile = open("/home/rohitvarkey/.julia/v0.3/Compose3D/src/backends/WebGL/js/three.min.js")
mainjsFile = open("/home/rohitvarkey/.julia/v0.3/Compose3D/src/backends/WebGL/js/main.js")
geometryjsFile = open("/home/rohitvarkey/.julia/v0.3/Compose3D/src/backends/WebGL/js/geometry.js")
threejs = readall(threejsFile);
mainjs = readall(mainjsFile);
geometryjs = readall(geometryjsFile);
display(MIME"text/html"(),"<script>$threejs</script>")
display(MIME"text/html"(),"<script>$mainjs</script>")
display(MIME"text/html"(),"<script>$geometryjs</script>")


function writemime(io::IO,mime::MIME{symbol("text/html")},ctx::Context)
	backend = draw(webgl(),ctx)
	display(backend)
end

#exporting types and functions to be used by the user on importing the module
export Point, Length, BoundingBox, AbsoluteBox, Context, mm, cm, inch, pt, w, h, d, CubePrimitive, Cube, cube, compose, draw, WebGL, webgl,
	   Sphere, sphere

end # module