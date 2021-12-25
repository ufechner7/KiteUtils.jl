using Coverage, Pkg, Glob
rm.(glob("src/*.cov"))
Pkg.test(;coverage=true)
coverage = process_folder()
covered_lines, total_lines = get_summary(coverage)
println("Coverage: ", round(100.0*covered_lines/total_lines), " %")
