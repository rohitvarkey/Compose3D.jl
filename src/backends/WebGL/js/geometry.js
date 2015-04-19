var getCube = function(x,y,z,side,col){
	var geometry = new THREE.BoxGeometry(side,side,side);
	var material = new THREE.MeshBasicMaterial({color:col});
	var cube = new THREE.Mesh(geometry,material);
	cube.position.set(x,y,z);
	cube.rotation_x = 0;
	cube.rotation_y = 0;
	return cube;
}

var getAxes = function(){
	var material = new THREE.LineBasicMaterial({color:0xffff});
	var geometry = new THREE.Geometry();
	geometry.vertices.push(
		new THREE.Vector3(-window.innerWidth,0,0),
		new THREE.Vector3(window.innerWidth,0,0)
	);
	var x_axis = new THREE.Line(geometry,material);
	
	material = new THREE.LineBasicMaterial({color:0xffff});
	geometry = new THREE.Geometry();
	geometry.vertices.push(
		new THREE.Vector3(0,-window.innerHeight,0),
		new THREE.Vector3(0,window.innerHeight,0)
	);
	var y_axis = new THREE.Line(geometry,material);
	
	return [x_axis,y_axis];
}

var getSphere = function(x,y,z,radius,col,texturemap){
	var geometry = new THREE.SphereGeometry(radius,32,32);
	var material = new THREE.MeshBasicMaterial({});
	if(texturemap)
		material.map    = THREE.ImageUtils.loadTexture(texturemap);
		
	var sphere = new THREE.Mesh(geometry,material);
	
	sphere.rotate = false;
	sphere.rotation_x = 0;
	sphere.rotation_y = 0;
	
	sphere.revolve = false;
	sphere.revolve_x = 0;
	sphere.revolve_y = 0;
	sphere.revolve_z = 0;
	
	sphere.revolve_a = 0;
	sphere.revolve_b = 0;
	
	sphere.revolve_theta=0;
	
	sphere.position.set(x,y,z);
	
	return sphere;
}
	
