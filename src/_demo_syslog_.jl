"""
    demo_syslog(P, name="Test flight"; duration=10)

Create a demo flight log  with given name [String] and duration [s] as StructArray. P is the number of tether
particles.
"""
function demo_syslog(P, name="Test flight"; duration=10)
    max_height = 6.03
    steps   = Int(duration * se().sample_freq) + 1

end
