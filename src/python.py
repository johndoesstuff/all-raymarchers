import math

screen_width = 50
screen_height = 20
steps = 40

repeat = 5.0
radius = 1.5

camera = ( 1.0, 2.0, -4.0 )

def wrap(p):
    return tuple( (p[i] + repeat/2) % repeat - repeat/2 for i in range(3) )

def sdf(p):
    w = wrap(p)
    return math.hypot(w[0], w[1], w[2]) - radius

def add_tuple(a, b):
    return ( a[0] + b[0], a[1] + b[1], a[2] + b[2] )

def scale_tuple(a, c):
    return ( a[0] * c, a[1] * c, a[2] * c )

def normalize_tuple(a):
    d = math.hypot(a[0], a[1], a[2])
    return ( a[0] / d, a[1] / d, a[2] / d )

for y in range(screen_height):
    o_str = ""
    for x in range(screen_width):
        pos = camera
        c_dir = ( x / screen_width - 0.5, y / screen_height - 0.5, 1.0 )
        c_dir = normalize_tuple(c_dir)
        traveled = 0.0
        for i in range(steps):
            safe = sdf(pos)
            traveled += safe
            pos = add_tuple(pos, scale_tuple(c_dir, safe))

        if traveled < 5.0: o_str += '#'
        elif traveled < 10.0: o_str += '|'
        elif traveled < 15.0: o_str += ':'
        elif traveled < 20.0: o_str += '.'
        else: o_str += ' '
    print(o_str)

