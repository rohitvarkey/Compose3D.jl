# Compose3D

Compose3D is a Julia package written to try and extend [Compose](http://composejl.org/) to 3-D. Currently, only WebGL backends using Three.JS are supported which allows you to draw 3D in a Jupyter notebook. The long term goal would be to integrate this package with the Compose package.

Please check the exp folder for some example IJulia notebooks.

# Documentation

### Contexts

Contexts are the things that you are able to draw. Contexts are created by specifying an origin point and the width, height and depth of the required context. 

You can use the *Context* constructor to create a Context. 

* **Context(x0,y0,z0,width,height,depth)** - *This will return a Context created which has it's coordinate system relative to (x0,y0,z0) and a width of 'width', height of 'height', and depth of 'depth'.* 

### Geometries (Forms)

Geometries look to provide the user with primitives for creation of 3-D shapes.

Current primitives implemented are :

   * Cubes
   * Spheres
   * Pyramids

Functions available for users to use to create such geometries are:
	
* **cube(x0,y0,z0,side)** - *Returns a cube with a corner at (x0,y0,z0) and the diagonal corner as (x0+side,y0+side,z0+side).*
* **sphere(x0,y0,z0,radius)** - *Returns a sphere centered at (x0,y0,z0) with the specified radius.*
* **pyramid(x0,y0,z0,baseLength, h)** - *Returns a square base pyramid of base length 'baseLength' with a corner at (x0,y0,z0) and the specified height 'h'.*

### Materials (Properties)

Materials are to add properties to the 3D objects like color and texture maps. These have not been implemented as of now. 

### Compositions

**Drawing things** is done by composing a root Context with other Contexts or Geometries.   

Compositions work exactly like in Compose except for :

* Measures of the parent Context is resolved by adding 'w','h' and 'd' rather than just providing numbers in Compose. 
* There is no support for using the width, height and the depth of the root box as of now like 'w','h' and 'd' do in Compose.
* The root Context has to have absolute values rather than relative values.

The function to be used by the user is the *compose* function. 

* **compose(Context, Geometry)** - *Returns a new context after adding the geometry object to the context. The geometry's relative measures are converted to absolute measures based on the parent context.*
* **compose(Context, Context)** - *Returns a new context after adding the context object to the parent context. The contexts relative measures are converted to absolute measures based on the parent context.*

Compose can also take inputs in S-tree formats to build a tree. This saves the user from having to call compose again and again.

### Measures

Compose3D makes use of a similar measure system to Compose. The basic unit is of *'mm'*.

Absolute measure units can be used like :

* cm - 10mm
* inch - 25.4mm
* pt - inch/72

Relative measures can also be used where the units will be :

* w - width
* h - height
* d - depth

Absolute and relative measures can be combined.
  
### Examples

```julia
cube1 = cube(0mm,0mm,0mm,1mm) # a cube of size 1 unit at the origin.
sphere1 = sphere(-5mm,0mm,0mm,0.1w) # a sphere with radius 1/10th of the width of the parent context and centered at (-5,0,0).
pyramid1 = pyramid(0mm,0mm,0.4d,2mm,1mm) # a pyramid with a corner at (0,0, 0.4*depth of parent context) of base 2mm and height 1mm.
context1 = Context(0mm,0mm,0mm,10mm,10mm,10mm) # context with origin at (0,0,0) and all dimensions of 10 units 
context2 = compose(context1,cube1) # Returns context with the cube.
context3 = compose(context2, sphere1, pyramid1) # Returns a context with all the geometries. Notice how we added 2 children in one line.
```

The drawing of a Sierpenski Pyramid can be done with the following code:
```julia
function sierpinski(n)
    if n == 0
        compose(Context(0w,0h,0d,1w,1h,1d),pyramid(0w,0h,0d,1w,1h))
    else
        t = sierpinski(n - 1)
        compose(Context(0w,0h,0d,1w,1h,1d),
        (Context(0w,0h,0d,(1/2)w,(1/2)h,(1/2)d), t),
        (Context(0.5w,0h,0d,(1/2)w,(1/2)h,(1/2)d), t),
        (Context(0.5w,0.5h,0d,(1/2)w,(1/2)h,(1/2)d), t),
        (Context(0w,0.5h,0d,(1/2)w,(1/2)h,(1/2)d), t),
        (Context(0.25w,0.25h,0.5d,(1/2)w,(1/2)h,(1/2)d), t))
    end
end

compose(Context(-5mm,-5mm,-5mm,10mm,10mm,10mm),sierpinski(0))
```
