#Cameras have a default look at to the origin.  

abstract Camera <: Compose3DNode

export camera

immutable PerspectiveCamera <: Camera
    position::Point{3} 
    fov::Float64 #Field of View
    aspect::Float64 #Aspect Ratio
    near::Float64 #Camera frustum near plane
    far::Float64 #Camera frustum far plane
end

PerspectiveCamera(x::Length, y::Length, z::Length, fov::Float64, aspect::Float64,
    near::Float64, far::Float64)= 
        PerspectiveCamera(Point(x,y,z),fov,aspect,near,far)

camera(x::Length, y::Length, z::Length; fov::Float64=45.0, aspect::Float64=16/9,
    near::Float64=0.1, far::Float64=10000.0) = 
        PerspectiveCamera(x,y,z,fov,aspect,near,far)
