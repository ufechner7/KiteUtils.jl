using KiteUtils
if false include("../src/logger.jl") end

set_data_path("data")
filename="transition"

log = import_log(filename)
save_log(log)