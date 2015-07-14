module Compose3D

# Defining compose node type
abstract Compose3DNode

abstract Backend

import Base: length, start, next, done, isempty, getindex, setindex!,
             display, writemime, convert, zero, isless, max, fill, size, copy,
             min, max, +, -, *, /

import Patchwork: Elem

#Including files.
include("measure.jl")
include("list.jl")
include("container.jl")
include("geometry.jl")
include("material.jl")
include("webgl.jl")
include("patchwork.jl")

#Setting up three js files required to display stuff.
#TODO: Do this only if the MIME is "text/html"

asset(url) = readall(Pkg.dir("Compose3D", "src", "backends", "WebGL", "js", url))

threejs = asset("three.min.js")
mainjs = asset("main.js")
geometryjs = asset("geometry.js")
trackballjs = asset("trackball.js")

#display(MIME"text/html"(),"<script>$threejs</script>")
#display(MIME"text/html"(),"<script>$mainjs</script>")
#display(MIME"text/html"(),"<script>$geometryjs</script>")
#display(MIME"text/html"(),"<script>$trackballjs</script>")
display(MIME"text/html"(),"<link rel=import href=/static/components/compose3d/bower_components/three-js/three-js.html>")

function writemime(io::IO,mime::MIME{symbol("text/html")},ctx::Context)
	backend = Elem(:div, style=Dict(:width=>"100%", :height=>"600px")) << draw(Patchable3D(100,100),ctx)
	display(backend)
end

#exporting types and functions to be used by the user on importing the module
export Point, Length, BoundingBox, AbsoluteBox, Context, mm, cm, inch, pt, w, h, d, CubePrimitive, Cube, cube, compose, draw, WebGL, webgl,
	   Sphere, sphere, Pyramid, pyramid, mesh_color, wireframe

end # module
