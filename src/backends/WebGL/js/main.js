var scene=null;
var camera = null;
var renderer = null;
var controls = null;
var shapes = [];

var initialize = function(mount){
	scene = new THREE.Scene();
	camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 1, 1000 );
	renderer = new THREE.WebGLRenderer();
	renderer.setSize( window.innerWidth, window.innerHeight );
	renderer.setClearColor( 0xffffff, 1);

	mount.appendChild( renderer.domElement );
	camera.position.z = 20;
	camera.position.y = 5;
	camera.lookAt(new THREE.Vector3(0,0,0));

	controls =  new THREE.TrackballControls(camera, renderer.domElement);
	controls.rotateSpeed = 1.0;
	controls.zoomSpeed = 1.2;
	controls.panSpeed = 0.2;

	controls.noZoom = false;
	controls.noPan = false;
	controls.staticMoving = false;
	controls.dynamicDampingFactor = 0.3;
	controls.minDistance = 1.1;
	controls.maxDistance = 300;
	controls.keys = [16,17,18];
}

var render = function () {
	requestAnimationFrame(render);
	controls.update();
	//iterate through the list of objects
	shapes.forEach(function(shape){
		if(shape.rotate){
			shape.rotation.x += shape.rotation_x;
			shape.rotation.y += shape.rotation_y;
		}
		if(shape.revolve){
			shape.position.set(shape.revolve_b*Math.sin(shape.revolve_theta),0,shape.revolve_a*Math.cos(shape.revolve_theta));
			shape.revolve_theta+=0.1;
		}
	});
	
	renderer.render(scene, camera);
};

var windowResize	= function(){
	var callback	= function(){
		renderer.setSize( window.innerWidth, window.innerHeight );
		camera.aspect	= window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
	}
	window.addEventListener('resize', callback, false);
	return {
		stop	: function(){
			window.removeEventListener('resize', callback);
		}
	};
}

var drawScene = function(mountID,drawAxes){
	
	initialize(document.getElementById(mountID));
	
//	var axisHelper = new THREE.AxisHelper( 5 );
//	scene.add( axisHelper );

	if(drawAxes == true)	{
		axes = getAxes();			
		scene.add(axes[0]);
		scene.add(axes[1]);
	}
	
	shapes.forEach(function(shape){
		scene.add(shape);
	});
	
	
	render();
	windowResize();
}

	
	



