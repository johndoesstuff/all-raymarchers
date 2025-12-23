using LinearAlgebra

screen_width = 50
screen_height = 20
steps = 40

repeat = 5.0
radius = 1.5

camera = [ 1.0, 2.0, -4.0 ]

wrap(v, r) = mod.(v .+ r/2, r) .- r/2

sdf(v) = hypot(wrap(v, repeat)...) - radius

for y = 0:screen_height-1
	for x = 0:screen_width-1
		pos = copy(camera)
		dir = [ x/screen_width - 0.5, y/screen_height - 0.5, 1.0 ]
		dir = normalize(dir)
		traveled = 0.0

		for i = 1:steps
			safe = sdf(pos)
			traveled += safe
			pos += safe * dir
		end

		if traveled < 20.0
			print("#|:."[1 + floor(Int, traveled / 5)])
		else
			print(' ')
		end
	end
	println()
end
