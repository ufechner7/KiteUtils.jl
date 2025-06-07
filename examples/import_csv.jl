using KiteUtils

set_data_path("data")
filename="transition"

log = import_log(filename)
println("Imported arrow log file: ", filename * ".arrow")
save_log(log)
println("Saved log file as: ", filename * ".csv")