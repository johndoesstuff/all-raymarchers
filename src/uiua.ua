Width  ← 50
Height ← 20
Radius ← 1.5
Camera ← 2_1_¯4
Steps  ← 40
Repeat ← 5

Dist      ← ≡≡(√/+˙×)
Wrap      ← (-÷2Repeat◿Repeat+÷2Repeat)
SDF       ← (-Radius Dist Wrap)
Normalize ← (÷⊸Dist)

Dirs  ← Normalize ⊞(-0.5⊂⊂)÷⊸⧻⇡Height÷⊸⧻⇡Width 1.5
Pos   ← ↯△Dirs Camera
March ← +⟜(≡≡°□×≡≡□Dirs SDF)
Final ← ⍥(March)Steps Pos
&p ♭≡(˜⊂@\n)≡≡(˜⬚@ ⊡"#|:. ")⌊÷5Dist-Final Pos
