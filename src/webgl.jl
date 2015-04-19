#TODO: Add WebGL specific properties here.

type WebGL <: Backend
	divId::Integer
	html::String
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
    return WebGL(divId,html)
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
    cubeId= rand(1000:10000000)
    new_html = 
    """
 	$(backend.html)
    var cube$(cubeId) = getCube($x,$y,$z,$side)
    shapes.push(cube$(cubeId))
    """
    return WebGL(backend.divId, new_html)
end

function draw(backend::WebGL, sphere::SpherePrimitive)
	radius = sphere.radius.value
    x = sphere.center.x[1].value
    y = sphere.center.x[2].value
    z = sphere.center.x[3].value
    sphereId= rand(1000:10000000)
    new_html = 
    """
 	$(backend.html)
    var sphere$(sphereId) = getSphere($x,$y,$z,$radius)
    shapes.push(sphere$(sphereId))
    """
    return WebGL(backend.divId, new_html)
end

function writemime(io::IO,mime::MIME{symbol("text/html")},webglInst::WebGL)
	html = 
	"""
	$(webglInst.html)
	drawScene("$(webglInst.divId)")
	</script>
	"""
	print(io,html)
end