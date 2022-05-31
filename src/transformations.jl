#= MIT License

Copyright (c) 2020, 2021 Uwe Fechner

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
    rot(pos_kite, pos_before, v_app)

Calculate the rotation matrix of the kite based on the position of the
last two tether particles and the apparent wind speed vector.
"""
function rot(pos_kite, pos_before, v_app)
    delta = pos_kite - pos_before
    @assert norm(delta) > 0.0 "Error in function rot() ! pos_kite must be not equal to pos_before. "
    c = -delta
    z = normalize(c)
    y = normalize(cross(-v_app, c))
    x = normalize(cross(y, c))
    rot = rot3d(SVector(0,-1.0,0), SVector(1.0,0,0), SVector(0,0,-1.0), z, y, x)
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
    acos2(arg)

Calculate the acos of arg, but allow values slightly above one and below
minus one to avoid exceptions in case of rounding errors. Returns an
angle in radian.
"""
@inline function acos2(arg)
   arg2 = min(max(arg, -one(arg)), one(arg))
   acos(arg2)
end
