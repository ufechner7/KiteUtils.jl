using KiteUtils

if basename(pwd()) == "examples" 
    set_data_path("../data")
else
    set_data_path("data")
end
filename="transition"

log = import_log(filename)
println("Imported arrow log file: ", filename * ".arrow")
save_log(log)
println("Saved log file as: ", filename * ".csv")