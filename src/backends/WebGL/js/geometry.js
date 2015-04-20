var getCube = function(x,y,z,side,col){
	col = col || 0x0000000;
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
	col = col || 0x0000000;
	var geometry = new THREE.SphereGeometry(radius,32,32);
	var material = new THREE.MeshBasicMaterial({color:col});
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
	
var getPyramid = function(x,y,z,base,height,fillColor,outlineColor){
  
  fillColor = fillColor || 0x000000;
  outlineColor = outlineColor || 0x00ff00;
  var geometry = new THREE.Geometry();

  geometry.vertices.push(new THREE.Vector3(x,y,z));
  geometry.vertices.push(new THREE.Vector3(x+base,y,z));
  geometry.vertices.push(new THREE.Vector3(x+base,y+base,z));
  geometry.vertices.push(new THREE.Vector3(x,y+base,z));
  geometry.vertices.push(new THREE.Vector3(x+base/2,y+base/2,z+height));

  geometry.faces.push(new THREE.Face3(0, 1, 4));
  geometry.faces.push(new THREE.Face3(1, 2, 4));
  geometry.faces.push(new THREE.Face3(3, 4, 2));
  geometry.faces.push(new THREE.Face3(3, 0, 4));
  geometry.faces.push(new THREE.Face3(3, 0, 4));
  geometry.faces.push(new THREE.Face3(0,2,1));
  geometry.faces.push(new THREE.Face3(0,3,2));

  var filling = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({color: fillColor}));
  var wireframe = new THREE.WireframeHelper( filling, outlineColor);

  pyramid = new THREE.Group();
  pyramid.add(filling,wireframe);
  pyramid.move= function(){};
  
  return pyramid;
}