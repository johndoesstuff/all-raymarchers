	REM Tiny Basic Raymarcher
	REM
	REM One of the biggest challenges with this raymarcher will be the lack of
	REM floating point, to account for that all numbers that would ordinarily be
	REM floating point will be represented as int * Z where Z is a very big
	REM number, for example 10000. So 1.5 -> 15000 and 1.4142 -> 14142
	REM
	REM Note also that in Tiny Basic PRINT will print with a newline,
	REM output for this program must have all '\n' characters replaced with
	REM '' and all "\\n" sequences with '\n' for correct format
	
	REM Variables: (* = float)
	REM
	REM A = Screen Width
	REM B = Screen Height
	REM C = Steps
	REM *D = Repeat
	REM *E = Radius
	REM
	REM *F = Camera X
	REM *G = Camera Y
	REM *H = Camera Z
	REM
	REM *I = Pos X
	REM *J = Pos Y
	REM *K = Pos Z
	REM
	REM *L = Dir X
	REM *M = Dir Y
	REM *N = Dir Z
	REM 
	REM *O = Traveled
	REM
	REM P = Pixel X
	REM Q = Pixel Y
	REM R = Current Step
	REM
	REM *S = Temp for normalization
	REM *T = Temp for sqrt
	REM *U = Temp for sdf
	REM
	REM Z = FLOATING POINT ACCURACY
	
	REM CONSTS
	
	LET Z = 10000000
	LET A = 50
	LET B = 20
	LET C = 40

	LET D = 5 * Z
	LET E = 1 * Z + 5 * Z / 10

	LET F = 1 * Z
	LET G = 2 * Z
	LET H = 0-4 * Z

	
	REM MAIN
	LET Q = 0
	REM ROW LOOP
20	LET P = 0
	REM COL LOOP
	REM GET DIRECTION
40	GOSUB 60
	REM POS = CAMERA
	LET I = F
	LET J = G
	LET K = H
	REM TRAVELED = 0 STEP = 0
	LET O = 0
	LET R = 0
	REM STEP LOOP
	REM GET U = SDF
50	GOSUB 100
	REM POS = POS + DIR * SDF
	LET I = I + ((L * U) / Z)
	LET J = J + ((M * U) / Z)
	LET K = K + ((N * U) / Z)
	REM WRAP POS
	GOSUB 140
	REM ACCUMULATE TRAVELED
	LET O = O + U
	LET R = R + 1
	IF R < C THEN GOTO 50
	IF O < 5 * Z THEN GOTO 160
	IF O < 10 * Z THEN GOTO 161
	IF O < 15 * Z THEN GOTO 162
	IF O < 20 * Z THEN GOTO 163
	GOTO 164
55	LET P = P + 1
	IF P < A THEN GOTO 40
	LET Q = Q + 1
	PRINT "\n"
	IF Q < B THEN GOTO 20
	END

	REM CONSTRUCT DIRECTION FROM PIXEL XY
	REM (FLOAT)DIR X = (INT)PIXEL X -> N * 10000 / WIDTH
60	LET L = P * Z
	LET L = L / A - (5 * Z / 10)
	REM (FLOAT)DIR Y = (INT)PIXEL Y -> N * 10000 / HEIGHT
	LET M = Q * Z
	LET M = M / B - (5 * Z / 10)
	REM DIR Z = 1.0
	LET N = Z
	GOSUB 80
	RETURN

	REM NORMALIZE DIRECTION L M N
80	LET S = ((L * L) / Z) + ((M * M) / Z) + ((N * N) / Z)
	REM FIND SQRT OF S USING NEWTONS METHOD
	GOSUB 120
	REM DIVIDE BY SQRT
	LET L = (Z * L) / T
	LET M = (Z * M) / T
	LET N = (Z * N) / T
	RETURN

	REM SDF I J K -> U
100	LET S = ((I * I) / Z) + ((J * J) / Z) + ((K * K) / Z)
	REM FIND SQRT OF S USING NEWTONS METHOD
	GOSUB 120
	REM RETURN SQRT - RADIUS
	LET U = T - E
	RETURN
	
	REM FIND SQRT OF S USING NEWTONS METHOD
120	LET T = S
	LET T = (T + (Z * S) / T) / 2
	LET T = (T + (Z * S) / T) / 2
	LET T = (T + (Z * S) / T) / 2
	LET T = (T + (Z * S) / T) / 2
	LET T = (T + (Z * S) / T) / 2
	LET T = (T + (Z * S) / T) / 2
	RETURN

	REM WRAP I J K POSITION
	REM JUST TRUST ME THAT THE MATH FOR THIS CHECKS OUT
140	LET I = I + D / 2
	LET I = I - (I / D) * D
	IF I < 0 THEN LET I = I + D
	LET I = I - D / 2
	LET J = J + D / 2
	LET J = J - (J / D) * D
	IF J < 0 THEN LET J = J + D
	LET J = J - D / 2
	LET K = K + D / 2
	LET K = K - (K / D) * D
	IF K < 0 THEN LET K = K + D
	LET K = K - D / 2
	RETURN

	REM SINCE I DIDNT IMPLEMENT ELSE OR BOOLEAN LOGIC NESTED IFS BECOME SUBROUTINES
160	PRINT "#"
	GOTO 55
161	PRINT "|"
	GOTO 55
162	PRINT ":"
	GOTO 55
163	PRINT "."
	GOTO 55
164	PRINT " "
	GOTO 55
