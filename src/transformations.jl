#= MIT License

Copyright (c) 2020, 2021, 2024 Uwe Fechner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. =#

# data structures for the flight state and the flight log
# functions for creating a demo flight state, demo flight log, loading and saving flight logs
# function se() for reading the settings
# the parameter P is the number of points of the tether, equal to segments+1
# in addition helper functions for working with rotations

"""
    rot3d(ax, ay, az, bx, by, bz)

Calculate the rotation matrix that needs to be applied on the reference frame (ax, ay, az) to match 
the reference frame (bx, by, bz).
All parameters must be 3-element vectors. Both refrence frames must be orthogonal,
all vectors must already be normalized.

Source: [TRIAD_Algorithm](http://en.wikipedia.org/wiki/User:Snietfeld/TRIAD_Algorithm)
"""
function rot3d(ax, ay, az, bx, by, bz)
    R_ai = hcat(ax, az, ay)
    R_bi = hcat(bx, bz, by)
    return R_bi * R_ai'
end

"""
    quat2euler(q)

Convert a quaternion to roll, pitch, and yaw angles in radian.
The quaternion can be a 4-element vector or a QuatRotation object.
"""
quat2euler(q::AbstractVector) = quat2euler(QuatRotation(q))
function quat2euler(q::QuatRotation)
    # Convert quaternion to RotXYZ
    rot = RotXYZ(q)
    
    # Extract roll, pitch, and yaw from RotXYZ
    roll = rot.theta1
    pitch = rot.theta2
    yaw = rot.theta3

    return roll, pitch, yaw
end

"""
    rot(pos_kite, pos_before, v_app)

Calculate the rotation matrix of the kite based on the position of the
last two tether particles and the apparent wind speed vector. Assumption: 
The kite aligns with the apparent wind direction. If used for the model
`KPS4`, pass the vector `-x` of the kite reference frame instead of v_app. 
"""
function rot(pos_kite, pos_before, v_app)
    delta = pos_kite - pos_before
    @assert norm(delta) > zero(eltype(delta)) "Error in function rot() ! pos_kite must be not equal to pos_before. "
    c = -delta
    z = normalize(c)
    y = normalize(cross(-v_app, c))
    x = normalize(cross(y, c))
    one_ = one(eltype(delta))
    rot = rot3d(SVector(0,-one_,0), SVector(one_,0,0), SVector(0,0,-one_), z, y, x)
end

function calc_orient_rot(x, y, z; viewer=false)
    if viewer
        pos_kite_ = @SVector ones(3)
        pos_before = pos_kite_ .+ z
        rotation = rot(pos_kite_, pos_before, -x)
    else
        # reference frame for the orientation: NED (north, east, down)
        ax = @SVector [0, 1, 0] # in ENU reference frame this is pointing to the south
        ay = @SVector [1, 0, 0] # in ENU reference frame this is pointing to the west
        az = @SVector [0, 0, -1] # in ENU reference frame this is pointing down
        rotation = rot3d(ax, ay, az, x, y, z)
    end
    return rotation
end

"""
    ground_dist(vec)

Calculate the ground distance of the kite from the groundstation based on the kite position (x,y,z, z up).
"""
function ground_dist(vec)
    sqrt(vec[begin]^2 + vec[begin+1]^2)
end 

"""
    calc_elevation(vec)

Calculate the elevation angle in radian from the kite position. 
"""
function calc_elevation(vec)
    atan(vec[begin+2] / ground_dist(vec))
end

"""
    azimuth_east(vec)

Calculate the azimuth angle in radian from the kite position in ENU reference frame.
Zero east. Positive direction clockwise seen from above.
Valid range: -π .. π.
"""
function azimuth_east(vec)
    return -atan(vec[begin+1], vec[begin])
end

"""
    asin2(arg)

Calculate the asin of arg, but allow values slightly above one and below
minus one to avoid exceptions in case of rounding errors. Returns an
angle in radian.
"""
@inline function asin2(arg)
   arg2 = min(max(arg, -one(arg)), one(arg))
   asin(arg2)
end

"""
    acos2(arg)

Calculate the acos of arg, but allow values slightly above one and below
minus one to avoid exceptions in case of rounding errors. Returns an
angle in radian.
"""
@inline function acos2(arg)
   arg2 = min(max(arg, -one(arg)), one(arg))
   acos(arg2)
end

"""
    wrap2pi(angle)

Limit the angle to the range -π .. π .
"""
wrap2pi(::typeof(pi)) = π
function wrap2pi(angle)
    y = rem(angle, 2π)
    abs(y) > π && (y -= 2π * sign(y))
    return y
end
