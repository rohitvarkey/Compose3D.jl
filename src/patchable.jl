# The Patchable backend

using ThreeJS
import Patchwork
import Patchwork.Elem

export Patchable3D

immutable Patchable3DPropertyFrame
    prev_materials::Dict{Type, Material}
    vector_properties::Dict{Type, Material}

    function Patchable3DPropertyFrame(
      materials=Dict{Type,Material}(),
      vector_props=Dict{Type, Material}()
    )
        new(
            materials,
            vector_props
        )
    end
end

type Patchable3D <: Backend
    width::Float64
    height::Float64
    current_materials::Dict{Type, Material} #Current materials in effect
    vector_properties::Dict{Type, Material}
    property_stack::Vector{Patchable3DPropertyFrame}
    root::Elem
    lights::Bool
    camera::Bool

    function Patchable3D(width, height)
        new(
            width,
            height,
            Dict{Type, Material}(),
            Dict{Type, Material}(),
            Patchable3DPropertyFrame[],
            ThreeJS.initscene(),
            false
        )
    end
end

root_box(img::Patchable3D) =
    BoundingBox(0.0mm, 0.0mm, 0.0mm, 100mm, 100mm, 100mm) #FIXME: Think of something better here

vector_properties(backend::Patchable3D) = backend.vector_properties

function properties_at_index(img, prop_vecs, i)
    props = Dict()
    for (proptype, property) in prop_vecs
        if i > length(property.primitives)
            error("Vector of properties and vector of forms have different length")
        end
        draw!(img, property.primitives[i], props)
    end
    props
end

# Material addition and removal
# -----------------------------

function push_property_frame(
        backend::Patchable3D,
        properties::Vector{Material}
    )
    frame = Patchable3DPropertyFrame(backend.current_materials)
    for property in properties
        if isscalar(property)
            backend.current_materials[typeof(property.primitives[1])] = property
        else
            frame.vector_properties[typeof(property.primitives[1])] = property
            backend.vector_properties[typeof(property.primitives[1])] = property
        end
    end
    push!(backend.property_stack, frame)
end

function pop_property_frame(img::Patchable3D)
  frame = pop!(img.property_stack)
  for (propertytype, property) in frame.vector_properties
      delete!(img.vector_properties, propertytype) #Clear the mapping
      for i in length(img.property_stack):-1:1
          if haskey(img.property_stack[i].vector_properties, propertytype)
              img.vector_properties[propertytype] =
                  img.property_stack[i].vector_properties[propertytype]
          end
      end
  end
  img.current_materials = frame.prev_materials
end

# Draw functions
# --------------

function finish(img::Patchable3D)

    if !(img.camera)
      img.root <<= ThreeJS.camera(30.0, 30.0, 30.0)
    end

    if !(img.lights)
       img.root <<= ThreeJS.spotlight(0.0, -30.0, 0.0)
       img.root <<= ThreeJS.spotlight(0.0, 20.0, 0.0)
    end
    img.root
end

# Material primitives
# -------------------

function mesh_materials(img::Patchable3D)
    dict = Dict()
    #Specify scalar mesh properties
    for propertytype in (MeshColor, WireFrameMesh, MaterialKind, Visiblity)
        if haskey(img.current_materials, propertytype)
            prim = img.current_materials[propertytype].primitives[1]
            draw!(img, prim, dict)
        end
    end
    ThreeJS.material(dict)
end

function draw(img::Patchable3D, prop::Material)
    dict = Dict()
    for prim in prop.primitives
        draw!(img, prim, dict)
    end
    dict
end

function draw!(img::Patchable3D, prim::MaterialPrimitive, dict)
    item = draw(img, prim)
    if !is(item, nothing)
        k, v = item
        dict[k] = v
    end
end

function draw(img::Patchable3D, prim::MeshColor)
    color = string("#" * hex(prim.color))
    :color, color
end

function draw(img::Patchable3D, wireframe::WireFrameMesh)
    :wireframe, wireframe.wireframe
end

function draw(img::Patchable3D, kind::MaterialKind)
    :kind, kind.kind
end

function draw(img::Patchable3D, visibility::Visiblity)
    :visible, visibility.visible
end

function draw(img::Patchable3D, edges::Edges)
    :edges, "true" #Make this return edgeColor also.
end

# Form drawing
# ------------

function draw(backend::Patchable3D, parent_box::AbsoluteBox, geometry::Geometry)
    acc = Array(Elem, length(geometry.primitives))
    properties = vector_properties(backend)
    for primitive in geometry.primitives
        for i in 1:length(geometry.primitives)
            elem = draw(backend, resolve(parent_box,geometry.primitives[i]))
            if properties !== nothing && !isempty(properties)
                props = properties_at_index(backend, properties, i)
            else
                props = Dict()
            end
            material = mesh_materials(backend) & props
            elem <<= material
            acc[i] = elem
        end
    end
    backend.root <<= acc
end

function draw(backend::Patchable3D, cube::BoxPrimitive)
    width= cube.width.value
    height = cube.height.value
    depth = cube.depth.value
    x = cube.center[1].value
    y = cube.center[2].value
    z = cube.center[3].value

    elem = ThreeJS.mesh(x, y, z) <<
        ThreeJS.box(width, height, depth)
    elem
end

function draw(backend::Patchable3D, sphere::SpherePrimitive)
    radius = sphere.radius.value
    x = sphere.center[1].value
    y = sphere.center[2].value
    z = sphere.center[3].value

    elem = ThreeJS.mesh(x, y, z) <<
        ThreeJS.sphere(radius)
    elem
end

function draw(backend::Patchable3D, pyramid::PyramidPrimitive)
    height = pyramid.height.value
    base = pyramid.base.value
    x = pyramid.corner[1].value
    y = pyramid.corner[2].value
    z = pyramid.corner[3].value

    elem = ThreeJS.mesh(x, y, z) <<
        ThreeJS.pyramid(base, height)
    elem
end

function draw(backend::Patchable3D, cylinder::CylinderPrimitive)
    top = cylinder.topradius.value
    bottom = cylinder.bottomradius.value
    height = cylinder.height.value
    x = cylinder.center[1].value
    y = cylinder.center[2].value
    z = cylinder.center[3].value

    elem = ThreeJS.mesh(x, y, z) <<
        ThreeJS.cylinder(top, bottom, height)
    elem
end

function draw(backend::Patchable3D, torus::TorusPrimitive)
    radius = torus.radius.value
    tube = torus.tubediameter.value
    x = torus.center[1].value
    y = torus.center[2].value
    z = torus.center[3].value

    elem = ThreeJS.mesh(x, y, z) <<
        ThreeJS.torus(radius, tube)
    elem
end

function draw(backend::Patchable3D, p::ParametricPrimitive)
    x = p.origin[1].value
    y = p.origin[2].value
    z = p.origin[3].value

    mesh = ThreeJS.mesh(x, y, z)

    if p.mesh
        geom = ThreeJS.meshlines(p.slices,p.stacks,p.xrange,p.yrange,p.f)
    else
        geom = ThreeJS.parametric(p.slices,p.stacks,p.xrange,p.yrange,p.f)
    end

    mesh << geom
end


# Lights
# ------

function draw(img::Patchable3D, parent_box::AbsoluteBox, light::Light)
    img.lights = true
    img.root <<= draw(img, resolve(parent_box, light))
end

function draw(img::Patchable3D, light::AmbientLight)
    ThreeJS.ambientlight(light.color)
end

function draw(img::Patchable3D, light::PointLight)
    ThreeJS.pointlight(
        light.position[1].value,
        light.position[2].value,
        light.position[3].value,
        color=light.color,
        intensity=light.intensity,
        distance=light.distance.value,
    )
end

function draw(img::Patchable3D, light::SpotLight)
    ThreeJS.spotlight(
        light.position[1].value,
        light.position[2].value,
        light.position[3].value,
        color=light.color,
        intensity=light.intensity,
        distance=light.distance.value,
        angle=light.angle,
        exponent=light.exponent,
        shadow=light.shadow,
    )
end

# Cameras
# -------
function draw(img::Patchable3D, parent_box::AbsoluteBox, camera::Camera)
    if (img.camera)
      warn("Only first camera encountered is used")
    else
      img.camera = true
      img.root <<= draw(img, resolve(parent_box, camera))
    end
end

function draw(img::Patchable3D, camera::PerspectiveCamera)
    ThreeJS.camera(
        camera.position[1].value,
        camera.position[2].value,
        camera.position[3].value,
        fov=camera.fov,
        aspect=camera.fov,
        near=camera.near,
        far=camera.far,
    )
end

#writemime for signals.
if isinstalled("Reactive")

    import Base: writemime
    import Reactive: Signal, lift

    if isdefined(Main, :IJulia)
        import IJulia: metadata
        metadata{T <: Compose3DNode}(::Signal{T}) = Dict()
    end

    function writemime{T <: Compose3DNode}(io::IO, m::MIME"text/html", ctx::Signal{T})
        writemime(io, m, lift(c ->
        outerdiv() <<
            draw(
                Patchable3D(
                    100,
                    100,
                ), c), ctx)
        )
    end
end
