using KiteUtils, LinearAlgebra

set_data_path("data")
set = deepcopy(se())

function create_bridle(se)
    # create the bridle
    bridle = KiteUtils.get_particles(se.height_k, se.h_bridle, se.width, se.m_k)
    return bridle
end
function bridle_length(se)
    # calculate the bridle length
    bridle = create_bridle(se)[2:end]
    len = norm(bridle[1] - bridle[2])
    len += norm(bridle[1] - bridle[4])
    len += norm(bridle[1] - bridle[5])
    len += norm(bridle[3] - bridle[2])
    len += norm(bridle[3] - bridle[4])
    len += norm(bridle[3] - bridle[5])
end

bridle_length(set)