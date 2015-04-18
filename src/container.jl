
type Context <: Compose3DNode
	box :: BoundingBox #Parent box.
	children :: List{Compose3DNode}
end

Context(x0::Length,y0::Length,z0::Length,width::Length,height::Length,depth::Length) = Context(BoundingBox(x0,y0,z0,w,h,d), ListNull{Compose3DNode}())

function draw(backend::Backend, root_canvas::Context)
    # TODO: Traverse the tree in DFS manner. And generate JS code to render stuff. \
    # Also use the resolve method to convert relative measures to absolute ones.
end
