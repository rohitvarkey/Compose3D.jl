var scene=null;
var camera = null;
var renderer = null;
var shapes = [];

var initialize = function(mount){
	scene = new THREE.Scene();
	camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 1, 1000 );
	renderer = new THREE.WebGLRenderer();
	renderer.setSize( window.innerWidth, window.innerHeight );
	mount.appendChild( renderer.domElement );
	camera.position.z = 20;
	camera.position.y = 5;
	camera.lookAt(new THREE.Vector3(0,0,0));
}

var render = function () {
	requestAnimationFrame(render);
	
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

	
	



