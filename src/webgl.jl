#TODO: Add WebGL specific properties here.
type WebGLMaterialFrame
	materials :: Dict{Type,Material}
end

type WebGL <: Backend
	divId::Integer #id of the div which we are drawing in.
	html::String #The html to be output.
	material_stack::Vector{WebGLMaterialFrame} #Stack of properties to be applied
end

function webgl()
	#Initialize WebGL backend
	divId = rand(1000:10000000)
	html =
	"""
	<div id="$divId">
    </div>
    <script>
    """
    #Set up default materials
    material_stack = [
                      WebGLMaterialFrame(
                        Dict{Type, Material}(
                           Material{MeshColor}=>mesh_color(color("black")),
                           Material{WireFrameMesh}=>wireframe(false),
                           )
                        )
                      ]
    return WebGL(divId,html,material_stack)
end

function push_material_frame(backend::WebGL, new_material_stack::Dict{Type,Material})
    push!(backend.material_stack,WebGLMaterialFrame(new_material_stack))
    return backend
end

function pop_material_frame(backend::WebGL)
    pop!(backend.material_stack)
    return backend
end

function draw(backend::WebGL,parent_box::Absolute3DBox,primitive::GeometryPrimitive)
	resPrimitive = resolve(parent_box, primitive)
	return draw(backend,resPrimitive)
end

function draw(backend::WebGL, cube::CubePrimitive)
	side = cube.side.value
    x = cube.corner.x[1].value
    y = cube.corner.x[2].value
    z = cube.corner.x[3].value
    material_stack = backend.material_stack[end]
    color = "0x$(hex(material_stack.materials[Material{MeshColor}].primitives[1].color))"
    cubeId= rand(1000:10000000)
    new_html =
    """
 	$(backend.html)
    var cube$(cubeId) = getCube($x,$y,$z,$side,$color)
    shapes.push(cube$(cubeId))
    """
    return WebGL(backend.divId, new_html, backend.material_stack)
end

function draw(backend::WebGL, sphere::SpherePrimitive)
	radius = sphere.radius.value
    x = sphere.center.x[1].value
    y = sphere.center.x[2].value
    z = sphere.center.x[3].value
    sphereId= rand(1000:10000000)
    material_stack = backend.material_stack[end]
    color = "0x$(hex(material_stack.materials[Material{MeshColor}].primitives[1].color))"
    new_html =
    """
 	$(backend.html)
    var sphere$(sphereId) = getSphere($x,$y,$z,$radius, $color)
    shapes.push(sphere$(sphereId))
    """
    return WebGL(backend.divId, new_html, backend.material_stack)
end

function draw(backend::WebGL, pyramid::PyramidPrimitive)
	height = pyramid.height.value
	base = pyramid.base.value
    x = pyramid.corner.x[1].value
    y = pyramid.corner.x[2].value
    z = pyramid.corner.x[3].value
    pyramidId= rand(1000:10000000)
    material_stack = backend.material_stack[end]
    color = "0x$(hex(material_stack.materials[Material{MeshColor}].primitives[1].color))"
    new_html =
    """
 	$(backend.html)
    var pyramid$(pyramidId) = getPyramid($x,$y,$z,$base,$height, $color)
    shapes.push(pyramid$(pyramidId))
    """
    return WebGL(backend.divId, new_html, backend.material_stack)
end

function writemime(io::IO,mime::MIME{symbol("text/html")},webglInst::WebGL)
	html =
	"""
	$(webglInst.html)
	drawScene("$(webglInst.divId)")
	</script>
	<script>
	var controls =  new THREE.TrackballControls(camera, renderer.domElement);
	</script>
	"""
	print(io,html)
end
