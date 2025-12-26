⍝ Simple APL Raymarcher built for gnuapl

⍝ Output consts
w ← 50
h ← 20

⍝ Raymarching consts
steps ← 40
radius ← 1.5
repeat ← 5
camera ← 1 2 ¯4

⍝ Scaled x, y
sy ← ¯0.5 + ((⍳h) - 1) ÷ h
sx ← ¯0.5 + ((⍳w) - 1) ÷ w

⍝ Dir stored as w h array
dirX ← sx∘.+ 0 × sy
dirY ← (0 × sx) ∘.+ sy
dirZ ← w h⍴1

⍝ Normalize dir
mag ← ((dirX*2) + (dirY*2) + (dirZ*2))*0.5
dirX ← dirX ÷ mag
dirY ← dirY ÷ mag
dirZ ← dirZ ÷ mag

⍝ Init camera arrays
posX ← w h⍴camera[1]
posY ← w h⍴camera[2]
posZ ← w h⍴camera[3]

⍝ Scene
hypot ← { ((⍵[1;;]*2) + (⍵[2;;]*2) + (⍵[3;;]*2))*0.5 }
wrap ← { (repeat|(⍵ + (repeat ÷ 2))) - (repeat ÷ 2) }
sdf ← { (hypot (wrap ⍵)) - radius }

⍝ Keep track of distances with array t
t←0×dirX

⍝ March all rays
∇ march
	pos ← 3 w h ⍴ (,posX), (,posY), ,posZ
	dir ← 3 w h ⍴ (,dirX), (,dirY), ,dirZ
	safe ← sdf pos
	t ← t + safe
	pos ← pos + dir × (3 w h⍴safe)
	posX ← pos[1;;]
	posY ← pos[2;;]
	posZ ← pos[3;;]
∇

⍝ Iterate march (gnuapl specific I believe)
∇ run n
	i ← 0
	loop: march
	i ← i + 1
	→ (i < n) / loop
∇

⍝ Display result
run steps
chars ← '#|:. '
thresholds ← 0 5 10 15 20
indices ← +/ t ∘.> thresholds
⍉chars[indices]

)OFF
