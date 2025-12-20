import math

screen_width = 50
screen_height = 20
steps = 40

repeat = 5
radius = 1.5

camera = ( 1.0, 2.0, -4.0 )

def wrap(p):
    return tuple( (p[i] + repeat/2) % repeat - repeat/2 for i in range(3) )

def sdf(p):
    w = wrap(p);
    return math.hypot(w[0], w[1], w[2]) - radius

def add_tuple(a, b):
    return ( a[0] + b[0], a[1] + b[1], a[2] + b[2] )

def scale_tuple(a, c):
    return ( a[0] * c, a[1] * c, a[2] * c )

for y in range(screen_height):
    o_str = ""
    for x in range(screen_width):
        pos = camera
        c_dir = ( x / screen_width - 0.5, y / screen_height - 0.5, 1.0 )
        traveled = 0.0;
        for i in range(steps):
            safe = sdf(pos)
            traveled += safe
            pos = add_tuple(pos, scale_tuple(c_dir, safe));

        if traveled < 5: o_str += '#'
        elif traveled < 10: o_str += '|'
        elif traveled < 15: o_str += ':'
        elif traveled < 20: o_str += '.'
        else: o_str += ' '
    print(o_str)

