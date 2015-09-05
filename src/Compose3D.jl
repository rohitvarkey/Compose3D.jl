module Compose3D

using Compat
using Measures
using ThreeJS

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

function isinstalled(pkg, ge=v"0.0.0")
    try
        # Pkg.installed might throw an error,
        # we need to account for it to be able to precompile
        ver = Pkg.installed(pkg)
        if ver != nothing && ver >= ge
            return true
        else
            return false
        end
    catch
        return false
    end
end

#Including files.
include("list.jl")
include("container.jl")
include("geometry.jl")
include("material.jl")
include("lights.jl")
include("camera.jl")
include("patchable.jl")

function writemime(io::IO, mime::MIME{symbol("text/html")}, ctx::Context)
	backend = ThreeJS.outerdiv() <<
        draw(Patchable3D(100, 100), ctx)
	display(backend)
end

end # module
