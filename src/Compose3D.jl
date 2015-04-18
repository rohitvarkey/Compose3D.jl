module Compose3D

# Defining compose node type
abstract Compose3DNode

abstract Backend

#Including files.
include("measure.jl")
include("list.jl")
include("container.jl")
include("geometry.jl")
include("material.jl")
include("webgl.jl")

#Setting up three js files required to display stuff.
#TODO: Do this only if the MIME is "text/html"
threejsFile = open("WebGL/js/three.min.js")
mainjsFile = open("WebGL/js/main.js")
geometryjsFile = open("WebGL/js/geometry.js")
threejs = readall(threejsFile);
mainjs = readall(mainjsFile);
geometryjs = readall(geometryjsFile);
display(MIME"text/html"(),"<script>$threejs</script>")
display(MIME"text/html"(),"<script>$mainjs</script>")
display(MIME"text/html"(),"<script>$geometryjs</script>")

#exporting types and functions to be used by the user on importing the module
export Point, Length, BoundingBox, AbsoluteBox, Context, mm, cm, inch, pt, w, h, d, CubePrimitive

end # module