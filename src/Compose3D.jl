module Compose3D

# package code goes here

include("measure.jl")
include("geometry.jl")
include("material.jl")

#TODO: Add check if MIME is "text/html"
threejsFile = open("WebGL/js/three.min.js")
mainjsFile = open("WebGL/js/main.js")
geometryjsFile = open("WebGL/js/geometry.js")
threejs = readall(threejsFile);
mainjs = readall(mainjsFile);
geometryjs = readall(geometryjsFile);

display(MIME"text/html"(),"<script>$threejs</script>")
display(MIME"text/html"(),"<script>$mainjs</script>")
display(MIME"text/html"(),"<script>$geometryjs</script>")

end # module