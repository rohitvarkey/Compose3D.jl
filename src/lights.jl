abstract Light <: Compose3DNode

using Colors

export pointlight, spotlight, ambientlight
#Ambient Light is applied globally to all objects.
immutable AmbientLight <: Light
    color::Color
end

ambientlight(color::String) = ambientlight(parse(Colorant, color))
ambientlight(color::Color=colorant"white") = AmbientLight(color)

resolve(box::Absolute3DBox, light::AmbientLight) = light

#Like a light bulb. Light shines in all directions.
immutable PointLight <: Light
    position::Vec3
    color::Color
    intensity::Float64
    distance::Length
end

PointLight(x::Length, y::Length, z::Length, color::Color, intensity::Float64,
           distance::Length) =
    PointLight((x, y, z), color, intensity, distance)

pointlight(x::Length, y::Length, z::Length, color::Color=colorant"white";
    intensity::Float64=1.0, distance=0mm) =
    PointLight(x, y, z, color, intensity, distance)

pointlight(x::Length, y::Length, z::Length, color::String; intensity::Float64=1.0,
    distance=0mm) =
    PointLight(x, y, z, parse(Colorant, color),intensity,distance)

function resolve(box::Absolute3DBox, light::PointLight)
    absposition = resolve(box, light.position)
    absdistance = resolve(box, light.distance)
    PointLight(absposition, light.color, light.intensity, absdistance)
end

#PointLight casting shadow in one direction.
immutable SpotLight <: Light
    position::Vec3
    color::Color
    intensity::Float64
    distance::Length
    angle::Float64 #Degrees
    exponent::Float64
    shadow::Bool
end

SpotLight(x::Length, y::Length, z::Length, color::Color, intensity::Float64,
          distance::Length, angle::Float64, exponent::Float64, shadow::Bool) =
    SpotLight((x, y, z), color, intensity, distance, angle, exponent, shadow)

spotlight(x::Length,y::Length,z::Length,color::Color=colorant"white";
          intensity::Float64=1.0, distance=0mm, angle::Float64=60.0,
          exponent::Float64=8.0, shadow::Bool=false) =
    SpotLight(x, y, z, color, intensity, distance, angle, exponent, shadow)

spotlight(x::Length,y::Length,z::Length,color::String;intensity::Float64=1.0,
          distance=0mm,angle::Float64=60.0,exponent::Float64=8.0,shadow::Bool=false) =
    SpotLight(x,y,z,parse(Colorant, color),intensity,distance,angle,exponent,shadow)

function resolve(box::Absolute3DBox, light::SpotLight)
    absposition = resolve(box, light.position)
    absdistance = resolve(box, light.distance)
    SpotLight(
        absposition,
        light.color,
        light.intensity,
        absdistance,
        light.angle,
        light.exponent,
        light.shadow
    )
end
