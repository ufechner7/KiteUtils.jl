"""
Functions to transform between coordinate systems.
"""

ENU2EG = @SMatrix [ 0  1  0;
                   -1  0  0;
                    0  0  1]

"""
    calc_azimuth(azimuth_north, up_wind_direction = -π/2)

Calculate the azimuth in the wind reference frame.
The up_wind_direction is the direction the wind is coming from
Zero is at north; clockwise positive. Default: Wind from west.

Returns:
- Angle in radians. Zero straight downwind. Positive direction clockwise seen
  from above.
- Valid range: -pi .. pi. 
"""
function calc_azimuth(azimuth_north, up_wind_direction = -π/2)
    result = azimuth_north - up_wind_direction + π
    if result > π
        result -= 2π
    elseif result < -π
        result += 2π
    end
    result
end

""" 
    fromENU2EG(pointENU)

Transform the position of the kite in the East North Up reference frame to the Earth Groundstation
(North West Up) reference frame.
"""
function fromENU2EG(pointENU)
    ENU2EG * pointENU
end

 """
     fromW2SE(vector, elevation, azimuth)

 Transform a (velocity-) vector (x,y,z) from Wind to Small Earth reference frame .
 """
function fromW2SE(vector, elevation, azimuth)
    rotate_first_step = @SMatrix[0  0  1;
                                 0  1  0;
                                -1  0  0]
    rotate_elevation = @SMatrix[cos(elevation) 0 sin(elevation);
                                0              1         0;
                             -sin(elevation)   0   cos(elevation)]
    rotate_azimuth = @SMatrix[1         0       0;
                              0  cos(azimuth)   -sin(azimuth);
                              0  sin(azimuth)    cos(azimuth)]
    rotate_elevation * rotate_azimuth * rotate_first_step * vector
end

""" 
    fromKS2EX(vector, orientation)

Transform a vector (x,y,z) from KiteSensor to Earth Xsens reference frame.

- orientation in Euler angles (roll, pitch, yaw)
"""
function fromKS2EX(vector, orientation)
    roll, pitch, yaw  = orientation[1], orientation[2], orientation[3]
    rotateYAW = @SMatrix[cos(yaw) -sin(yaw) 0;
                         sin(yaw)  cos(yaw) 0;
                             0         0    1]
    rotatePITCH = @SMatrix[cos(pitch)   0  sin(pitch);
                             0          1        0;
                       -sin(pitch)      0  cos(pitch)]
    rotateROLL = @SMatrix[ 1        0         0;
                           0   cos(roll) -sin(roll);
                           0   sin(roll)  cos(roll)]
    rotateYAW * rotatePITCH * rotateROLL * vector
end

"""
    fromEX2EG(vector)

Transform a vector (x,y,z) from EarthXsens to Earth Groundstation reference frame
"""
function fromEX2EG(vector)
    rotateEX2EG = @SMatrix[1  0  0;
                           0 -1  0;
                           0  0 -1]
    rotateEX2EG * vector
end

"""
    fromEG2W(vector, down_wind_direction = pi/2.0)
Transform a vector (x,y,z) from Earth Groundstation to Wind reference frame.
"""
function fromEG2W(vector, down_wind_direction = pi/2.0)
    rotateEG2W =    @SMatrix[cos(down_wind_direction) -sin(down_wind_direction)  0;
                             sin(down_wind_direction)  cos(down_wind_direction)  0;
                             0                        0                      1]
    rotateEG2W * vector
end

"""
    calc_heading_w(orientation, down_wind_direction = pi/2.0)
"""
function calc_heading_w(orientation, down_wind_direction = pi/2.0)
    # create a unit heading vector in the xsense reference frame
    heading_sensor =  SVector(1, 0, 0)
    # rotate headingSensor to the Earth Xsens reference frame
    headingEX = fromKS2EX(heading_sensor, orientation)
    # rotate headingEX to earth groundstation reference frame
    headingEG = fromEX2EG(headingEX)
    # rotate headingEG to headingW and convert to 2d HeadingW vector
    fromEG2W(headingEG, down_wind_direction)
end

# def fromEAK2ENU(vector):
#     """ vector: elevation, azimuth_north, kite_distance
#         Returns the kite position in the east-north-up reference frame. """
#     elevation     = vector[0]
#     azimuth_north = vector[1]
#     kite_distance = vector[2]
#     return vec3(sin(azimuth_north), cos(azimuth_north), sin(elevation)) * kite_distance

# def fromSE2W(vector, elevation, azimuth):
#     """
#     transform a vector (x,y,z) from Small Earth to Wind reference frame
#     {rleuthold corrected according to:
#     if N = ABC V (A = rE, B = rA, C = rFS), then A⁻¹ N = A⁻¹ABC V ... A⁻¹B⁻¹C⁻¹ N = V}
#     """
#     #TODO: Add unit test
#     rotateFirstStep = mat3( 0,  0, -1,
#                             0,  1,  0,
#                             1,  0,  0)
#     rotateElevation = mat3(cos(elevation), 0, -sin(elevation),
#                            0,              1,         0,
#                            sin(elevation), 0,  cos(elevation))
#     rotateAzimuth = mat3(1,        0,      0,
#                          0, cos(azimuth),    sin(azimuth),
#                          0, -sin(azimuth),   cos(azimuth))

#     return rotateFirstStep * rotateAzimuth * rotateElevation * vector

# def calc_heading_d(orientation, elevation, azimuth):
#     """
#     Calculate the 2D heading vector for the FrontView display in the wind reference
#     frame after normalizing it in the small-earth reference frame.
#     """
#     headingSE = fromW2SE(calc_heading_w(orientation), elevation, azimuth)
#     # print '--> headingSE.y, headingSE.x',headingSE.y, headingSE.x
#     headingSE[2] = 0
#     # print 'headingSE', headingSE
#     if headingSE.normalize() < 0.001:
#         headingSE = vec3(0.0)
#     else:
#         headingSE.normalize()
#     headingW = fromSE2W(headingSE, elevation, azimuth)
#     # print 'headingW', headingW
#     result = np.zeros(2)
#     result[0], result[1] = headingW[1], headingW[2]
#     return result

# def calc_heading(orientation, elevation, azimuth):
#     headingSE = fromW2SE(calc_heading_w(orientation), elevation, azimuth)
#     # print 'headingSE.y, headingSE.x',headingSE.y, headingSE.x
#     angle = atan2(headingSE.y, headingSE.x) -pi
#     if angle < 0:
#         angle += 2 * pi
#     if angle < 0:
#         angle += 2 * pi
#     return angle

# def calc_course_d(velocityENU, elevation, azimuth, down_wind_direction = pi/2.0):
#     """ down_wind_direction: The direction the wind is going to; zero at north;
#     clockwise positive from above; default: goint to east. """
#     velocityEG = fromENU2EG(velocityENU)
#     velocityW = fromEG2W(velocityEG, down_wind_direction)
#     velocitySE = fromW2SE(velocityW, elevation, azimuth)
#     velocitySE[2] = 0;
#     if velocitySE.length() < 0.001:
#         velocitySE = vec3(0.0)
#     else:
#         velocitySE.normalize()
#     courseD = fromSE2W(velocitySE, elevation, azimuth)
#     result = np.zeros(2)
#     result[0], result[1] = -courseD[1], -courseD[2]
#     return result

# def calc_course(velocityENU, elevation, azimuth, down_wind_direction = pi/2.0):
#     """ down_wind_direction: The direction the wind is going to; zero at north;
#     clockwise positive from above; default: goint to east. """
#     velocityEG = fromENU2EG(velocityENU)
#     velocityW = fromEG2W(velocityEG, down_wind_direction)
#     velocitySE = fromW2SE(velocityW, elevation, azimuth)
#     angle = atan2(velocitySE.y, velocitySE.x)
#     if angle < 0:
#         angle += 2 * pi
#     return angle

# def calc_height(elevation, kite_distance):
#     return kite_distance * sin(elevation)


# if __name__ == '__main__':
# #    vec1 = np.array((1.0, 2.0, 3.0))
# #    vec2 = np.array((2.0, 3.0, 4.0))
# #    # orient = np.array((0, pi, pi / 2.0))
# #    orient = np.array((0, pi/10, pi / 2.0))
# #    elevation = 71.5 / 180 * pi
# #    azimuth   = 0.0 # 45.0 / 180 * pi
# #    print fromKS2EX(vec1, orient)
# #    print calc_heading_w(orient)
# #    print calc_heading_d(orient, elevation, azimuth)
# #    print calc_heading(orient, elevation, azimuth)
#     # roll, pitch, yaw: (164.605, -12.0978, 157.931)
#     # azimuth: 21.79
#     # elevation: 66.47
#     # wrong: headingSE.y, headingSE.x 0.00482372330774 0.980817341582
#     # wrong: heading 359.7 degree
#     # expected: between 330 and 350
# #    orient = np.array((164.605, -12.0978, 157.931)) / 180.0 * pi
# #    azimuth = 21.79 /180.0 * pi
# #    elevation = 66.47 /180.0 * pi
# #    print calc_heading_d(orient, elevation, azimuth)
# #    print calc_heading(orient, elevation, azimuth) * 180.0 / pi

#     orient = np.array((0.0, 0.0, 90.0 )) / 180.0 * pi
#     azimuth = 0.0 /180.0 * pi
#     elevation = 70.0 /180.0 * pi
#     print calc_heading_d(orient, elevation, azimuth)
#     print calc_heading(orient, elevation, azimuth) * 180.0 / pi
