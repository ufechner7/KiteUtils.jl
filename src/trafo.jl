"""
Functions to transform between coordinate systems.
"""

# ENU2EG = mat3( 0, 1, 0,
#               -1, 0, 0,
#                0, 0, 1)

# def calcAzimuth(azimuth_north, upWindDirection = -pi/2.0):
#     """ Calculate the azimuth in the wind reference frame.
#         The upWindDirection is the direction the wind is coming from
#         Zero is at north; clockwise positive. Default: Wind from west.
#         Returns:
#         Angle in radians. Zero straight downwind. Positive direction clockwise seen
#         from above.
#         Valid range: -pi .. pi. """
#     result = azimuth_north - upWindDirection + pi
#     if result > pi:
#         result -= 2.0 * pi
#     if result < -pi:
#         result += 2.0 * pi
#     return result


# def fromEAK2ENU(vector):
#     """ vector: elevation, azimuth_north, kite_distance
#         Returns the kite position in the east-north-up reference frame. """
#     elevation     = vector[0]
#     azimuth_north = vector[1]
#     kite_distance = vector[2]
#     return vec3(sin(azimuth_north), cos(azimuth_north), sin(elevation)) * kite_distance

# def fromENU2EG(pointENU):
#     """ Transform the position of the kite in the East North Up reference frame to the Earth Groundstation
#         (North West Up) reference frame.
#     """
#     return ENU2EG * vec3(pointENU)

# def fromKS2EX(vector, orientation):
#     """ transform a vector (x,y,z) from KiteSensor to Earth Xsens reference frame """
#     #TODO: Add unit test
#     roll, pitch, yaw  = orientation[0], orientation[1], orientation[2]
#     rotateYAW = mat3(cos(yaw), -sin(yaw), 0,
#                      sin(yaw),  cos(yaw), 0,
#                             0,         0, 1)
#     rotatePITCH = mat3(cos(pitch),  0, sin(pitch),
#                            0,       1,         0,
#                       -sin(pitch),  0,   cos(pitch))
#     rotateROLL = mat3( 1,       0,        0,
#                        0,   cos(roll), -sin(roll),
#                        0,   sin(roll),  cos(roll))
#     return rotateYAW * rotatePITCH * rotateROLL * vec3(vector)

# def fromEX2EG(vector):
#     """ transform a vector (x,y,z) from EarthXsens to Earth Groundstation reference frame """
#     rotateEX2EG = mat3(1,  0,  0,
#                        0, -1,  0,
#                        0,  0, -1)
#     return rotateEX2EG * vec3(vector)

# def fromEG2W(vector, downWindDirection = pi/2.0):
#     """ transform a vector (x,y,z) from Earth Groundstation to Wind reference frame """
#     #TODO: Add unit test
#     rotateEG2W =    mat3(cos(downWindDirection), -sin(downWindDirection), 0,
#                          sin(downWindDirection),  cos(downWindDirection), 0,
#                            0,                       0,                    1)
#     return rotateEG2W * vec3(vector)

# def calc_heading_w(orientation, downWindDirection = pi/2.0):
#     """
#         // create a unit heading vector in the xsense reference frame
#         Vector3d headingSensor(1, 0, 0);
#         // rotate headingSensor to the Earth Xsens reference frame
#         Vector3d headingEX = fromKS2EX(headingSensor);
#         // rotate headingEX to earth groundstation reference frame
#         Vector3d headingEG = fromEX2EG(headingEX);
#         // rotate headingEG to headingW and convert to HeadingW object
#         m_headingW = new HeadingW(fromEG2W(headingEG));

#     """
#     # print 'orientation', orientation
#     # create a unit heading vector in the xsense reference frame
#     headingSensor =  np.zeros(3)
#     headingSensor[0] = 1
#     # rotate headingSensor to the Earth Xsens reference frame
#     headingEX = fromKS2EX(headingSensor, orientation)
#     # print 'headingEX', headingEX
#     # rotate headingEX to earth groundstation reference frame
#     headingEG = fromEX2EG(headingEX)
#     # print 'headingEG', headingEG
#     # rotate headingEG to headingW and convert to 2d HeadingW vector
#     result = fromEG2W(headingEG, downWindDirection)
#     # print 'headingW1', result
#     return result

# def fromW2SE(vector, elevation, azimuth):
#     """ transform a (velocity-) vector (x,y,z) from Wind to Small Earth reference frame """
#     #TODO: Add unit test
#     rotateFirstStep = mat3( 0,  0,  1,
#                             0,  1,  0,
#                            -1,  0,  0)
#     rotateElevation = mat3(cos(elevation), 0, sin(elevation),
#                               0,              1,         0,
#                              -sin(elevation), 0,  cos(elevation))
#     rotateAzimuth = mat3(1,        0,      0,
#                          0, cos(azimuth),  -sin(azimuth),
#                          0, sin(azimuth),   cos(azimuth))
#     return rotateElevation * rotateAzimuth * rotateFirstStep * vector

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

# def calc_course_d(velocityENU, elevation, azimuth, downWindDirection = pi/2.0):
#     """ downWindDirection: The direction the wind is going to; zero at north;
#     clockwise positive from above; default: goint to east. """
#     velocityEG = fromENU2EG(velocityENU)
#     velocityW = fromEG2W(velocityEG, downWindDirection)
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

# def calc_course(velocityENU, elevation, azimuth, downWindDirection = pi/2.0):
#     """ downWindDirection: The direction the wind is going to; zero at north;
#     clockwise positive from above; default: goint to east. """
#     velocityEG = fromENU2EG(velocityENU)
#     velocityW = fromEG2W(velocityEG, downWindDirection)
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
