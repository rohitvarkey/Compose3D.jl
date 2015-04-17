abstract Measure

immutable Length{unit} <: Measure
    value::Float64
end

abstract MeasureOp{n} <: Measure
abstract UnaryOp{A} <: MeasureOp{1}
abstract ScalarOp{A} <: MeasureOp{2}
abstract BinaryOp{A, B} <: MeasureOp{2}

immutable Neg{A <: Measure} <: UnaryOp{A}
    a::A
end

immutable Add{A <: Measure, B <: Measure} <: BinaryOp{A, B}
    a::A
    b::B
end

immutable Min{A <: Measure, B <: Measure} <: BinaryOp{A, B}
    a::A
    b::B
end

immutable Max{A <: Measure, B <: Measure} <: BinaryOp{A, B}
    a::A
    b::B
end

immutable Div{A <: Measure} <: ScalarOp{A}
    a::A
    b::Number
end

immutable Mul{A <: Measure} <: ScalarOp{A}
    a::A
    b::Number
end

# Easy simplifications
# TODO: Add more simplifications
Add{P <: Length}(x::P, y::P) = P(x.value + y.value)
Neg{T <: Length}(x::T) = T(-x.value)
Neg(x::Neg) = x.a
Div{T <: Length}(a::T, b::Number) = T(a.value / b)
Mul{T <: Length}(a::T, b::Number) = T(a.value * b)
Max{T <: Length}(a::T, b::T) = T(max(a.value, b.value))
Min{T <: Length}(a::T, b::T) = T(min(a.value, b.value))

iszero(x::Length) = x.value == 0.0
iszero(x::Measure) = false

+(a::Measure, b::Measure) = iszero(a) ? b : iszero(b) ? a : Add(a, b)
-(a::Measure) = Neg(a)
-(a::Neg) = a.value
-(a::Measure, b::Measure) = Add(a, -b)
-{T <: Length}(a::T, b::T) = T(a.value - b.value)
/(a::Measure, b::Number) = Div(a, b)
*(a::Measure, b::Number) = Mul(a, b)
*(a::Number, b::Measure) = Mul(b, a)
min(a::Measure, b::Measure) = Min(a, b)
max(a::Measure, b::Measure) = Max(a, b)

const mm   = Length{:mm}(1.0)
const cm   = Length{:mm}(10.0)
const inch = Length{:mm}(25.4)
const pt   = inch/72.0

const w    = Length{:w}(1.0)
const h    = Length{:h}(1.0)
const d    = Length{:d}(1.0)

# Higher-order measures
immutable Point{N, T}
    x::NTuple{N, T}
end

Point{T <: Length}(x::T, y::T, z::T) = Point{3, T}((x, y, z))
Point{T <: Length}(x::T, y::T) = Point{3, T}((x, y, 0mm))
Point(x::Measure, y::Measure, z::Measure) = Point{3, Measure}((x, y, z))
Point(x::Measure, y::Measure) = Point{3, Measure}((x, y, 0mm))
Point() = Point(0mm, 0mm, 0mm)

Base.zero(::Type{Point}) = Point()
isabsolute{N}(::Point{N, Length{:mm}}) = true
isabsolute(::Point) = false

+(a::Point, b::Point)  = map(+, a.x, b.x)
-(a::Point, b::Point)  = map(-, a.x, b.x)
/(a::Point, b::Number) = map(x -> x/b, a.x)
*(a::Point, b::Number) = map(x -> x*b, a.x)
*(a::Number, b::Point) = b*a

immutable BoundingBox{N, X, A}
    x0::Point{N, X}
    a::NTuple{N, A}
end

BoundingBox{X, T <: Length}(x0::Point{3, X}, width::T, height::T, depth::T) =
    BoundingBox{3, X, T}(x0, (width, height, depth))

BoundingBox{X, T <: Length}(x0::Point{3, X}, width::T, height::T) =
    BoundingBox{3, X, T}(x0, (width, height, 0mm))

BoundingBox{X}(x0::Point{3, X}, width::Measure, height::Measure, depth::Measure) =
    BoundingBox{3, X, Measure}(x0, (width, height, depth))

BoundingBox{X}(x0::Point{3, X}, width::Measure, height::Measure) =
    BoundingBox{3, X, Measure}(x0, (width, height, 0mm))

BoundingBox(x0::Measure, y0::Measure, z0::Measure, width::Measure, height::Measure, depth::Measure) =
    BoundingBox(Point(x0, y0, z0), width, height, depth)

BoundingBox(x0::Measure, y0::Measure, width::Measure, height::Measure) =
    BoundingBox(Point(x0, y0), width, height)

BoundingBox() = BoundingBox(0mm, 0mm, 0mm, 1w, 1h, 1d)
BoundingBox(width, height) = BoundingBox(0mm, 0mm, 0mm, width, height, 0mm)
BoundingBox(width, height, depth) = BoundingBox(0mm, 0mm, 0mm, width, height, depth)

isabsolute{N}(::BoundingBox{N, Length{:mm}, Length{:mm}}) = true
isabsolute(::BoundingBox) = false

typealias AbsoluteBox{N}   BoundingBox{N, Length{:mm}, Length{:mm}}
typealias Absolute3DBox    AbsoluteBox{3}

width(x::BoundingBox)  = x.a[1]
height(x::BoundingBox) = x.a[2]
depth(x::BoundingBox)  = x.a[3]

# resolve resolves measures in mm relative to a bounding box
resolve(box::AbsoluteBox, x::Length{:mm}) = x.value
resolve(box::AbsoluteBox, x::Length{:w})  = width(box).value * x.value
resolve(box::AbsoluteBox, x::Length{:h})  = height(box).value * x.value
resolve(box::AbsoluteBox, x::Length{:d}) = depth(box).value * x.value

resolve(box::AbsoluteBox, x::Neg) = -resolve(box, x.a)
resolve(box::AbsoluteBox, x::Add) = resolve(box, x.a) + resolve(box, x.b)
resolve(box::AbsoluteBox, x::Mul) = resolve(box, x.a) * x.b
resolve(box::AbsoluteBox, x::Div) = resolve(box, x.a) / x.b
resolve(box::AbsoluteBox, x::Min) = min(resolve(box, x.a), resolve(box, x.b))
resolve(box::AbsoluteBox, x::Max) = max(resolve(box, x.a), resolve(box, x.b))
resolve(box::AbsoluteBox, p::Point) =
    Point(map(x -> resolve(box, x)*mm, p.x)) + box.x0
resolve(outer::AbsoluteBox, box::BoundingBox) =
    BoundingBox(Point(resolve(outer, box.x0)), map(x -> resolve(outer, x)*mm, box.a))

# E.g.
println(resolve(BoundingBox(10cm, 6cm), .4w+.5h-20mm))
println(resolve(BoundingBox(10cm, 6cm), Point(.5w, .5h)))
println(resolve(BoundingBox(10cm, 6cm), BoundingBox(.25w, .25h, .5w, .5h)))

#3D E.g
println(resolve(BoundingBox(10cm, 6cm, 4cm), .4w+.5h-20mm-.4d))
println(resolve(BoundingBox(10cm, 6cm, 4cm), Point(.5w, .5h, .5d)))
println(resolve(BoundingBox(10cm, 6cm, 4cm), BoundingBox(.25w, .25d, .25h, .5w, .5d, .5h)))
