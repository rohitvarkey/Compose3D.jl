module Compose3D

using Compat
using Measures

# Defining compose node type
abstract Compose3DNode

abstract Backend

import Base: length, start, next, done, isempty, getindex, setindex!,
             display, writemime, convert, zero, isless, max, fill, size, copy,
             min, max, +, -, *, /

import Measures: resolve, w, h, d

#exporting types and functions to be used by the user on importing the module
export Context, mm, cm, inch, pt, w, h, d, cube, box, compose, draw, sphere,
       pyramid, mesh_color, wireframe, cylinder, torus, parametric

import Patchwork: Elem

#Including files.


include("list.jl")
include("container.jl")
include("geometry.jl")
include("material.jl")
include("lights.jl")
include("camera.jl")
include("patchable.jl")

#Setting up three js files required to display stuff.
#Link to the static files copied to the julia profile if in an IJulia session.
if isdefined(Main, :IJulia)
    display(
        MIME"text/html"(),
        "<link rel=import href=/static/components/compose3d/bower_components/three-js/three-js.html>"
    )
end
#TODO: Make Escher take care of the other cases.

function writemime(io::IO,mime::MIME{symbol("text/html")},ctx::Context)
	backend= Elem(:div, style=@compat Dict(:width=>"100%", :height=>"600px")) <<
        draw(Patchable3D(100,100),ctx)
	display(backend)
end

end # module
