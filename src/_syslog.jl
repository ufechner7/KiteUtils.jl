function syslog(logger::Logger)
    l = logger
    StructArray{SysState{l.points}}((l.time_vec, l.t_sim_vec, l.sys_state_vec, l.e_mech_vec, l.orient_vec, 
                                     l.elevation_vec, l.azimuth_vec, l.l_tether_vec, l.v_reelout_vec, l.force_vec, 
                                     l.depower_vec, l.steering_vec, l.heading_vec, l.course_vec, l.v_app_vec, 
                                     l.v_wind_gnd_vec, l.v_wind_200m_vec, l.v_wind_kite_vec, l.vel_kite_vec, l.X_vec, 
                                     l.Y_vec, l.Z_vec, l.var_01_vec, l.var_02_vec, l.var_03_vec, 
                                     l.var_04_vec, l.var_05_vec, l.var_06_vec, l.var_07_vec, l.var_08_vec, 
                                     l.var_09_vec, l.var_10_vec, l.var_11_vec, l.var_12_vec, l.var_13_vec, 
                                     l.var_14_vec, l.var_15_vec, l.var_16_vec))
end