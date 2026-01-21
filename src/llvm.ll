@stdout = external global ptr
%struct.point = type { float, float, float }

declare i32 @putc(i32 noundef, ptr noundef)
declare float @sqrtf(float noundef)

; Mod for negative floats
define float @mod(float %mod.n, float %mod.d) {
  %ndd = fdiv float %mod.n, %mod.d
  %flr = call float @llvm.floor.f32(float %ndd)
  %dflr = fmul float %mod.d, %flr
  %mod.ret = fsub float %mod.n, %dflr
  ret float %mod.ret
}

; Wrap float by repeat
define float @wrap(float %mod.x, float %mod.r) {
  %hr = fmul float 0.5, %mod.r
  %xhr = fadd float %mod.x, %hr
  %wmod = call float @mod(float %xhr, float %mod.r)
  %wrap.ret = fsub float %wmod, %hr
  ret float %wrap.ret
}

; Wrap point by repeat
define ptr @wrap.point(ptr %wrap.point, float %wrap.repeat, ptr %wrap.npoint) {
  %wrap.point.x = getelementptr inbounds %struct.point, ptr %wrap.point, i32 0, i32 0
  %wrap.point.y = getelementptr inbounds %struct.point, ptr %wrap.point, i32 0, i32 1
  %wrap.point.z = getelementptr inbounds %struct.point, ptr %wrap.point, i32 0, i32 2
  %wrap.point.x.val = load float, ptr %wrap.point.x
  %wrap.point.y.val = load float, ptr %wrap.point.y
  %wrap.point.z.val = load float, ptr %wrap.point.z
  %wrap.point.x.wrap = call float @wrap(float %wrap.point.x.val, float %wrap.repeat)
  %wrap.point.y.wrap = call float @wrap(float %wrap.point.y.val, float %wrap.repeat)
  %wrap.point.z.wrap = call float @wrap(float %wrap.point.z.val, float %wrap.repeat)
  %wrap.npoint.x = getelementptr inbounds %struct.point, ptr %wrap.npoint, i32 0, i32 0
  %wrap.npoint.y = getelementptr inbounds %struct.point, ptr %wrap.npoint, i32 0, i32 1
  %wrap.npoint.z = getelementptr inbounds %struct.point, ptr %wrap.npoint, i32 0, i32 2
  store float %wrap.point.x.wrap, ptr %wrap.npoint.x
  store float %wrap.point.y.wrap, ptr %wrap.npoint.y
  store float %wrap.point.z.wrap, ptr %wrap.npoint.z
  ret ptr %wrap.npoint
}

; Hypot from point struct
define float @hypot(ptr %hypot.point) {
  %hypot.point.x = getelementptr inbounds %struct.point, ptr %hypot.point, i32 0, i32 0
  %hypot.point.y = getelementptr inbounds %struct.point, ptr %hypot.point, i32 0, i32 1
  %hypot.point.z = getelementptr inbounds %struct.point, ptr %hypot.point, i32 0, i32 2
  %hypot.point.x.val = load float, ptr %hypot.point.x
  %hypot.point.y.val = load float, ptr %hypot.point.y
  %hypot.point.z.val = load float, ptr %hypot.point.z
  %hypot.point.x.sq = fmul float %hypot.point.x.val, %hypot.point.x.val
  %hypot.point.y.sq = fmul float %hypot.point.y.val, %hypot.point.y.val
  %hypot.point.z.sq = fmul float %hypot.point.z.val, %hypot.point.z.val
  %hypot.point.sum.a = fadd float %hypot.point.x.sq, %hypot.point.y.sq
  %hypot.point.sum = fadd float %hypot.point.sum.a, %hypot.point.z.sq
  %hypot.d = call float @sqrtf(float %hypot.point.sum)
  ret float %hypot.d
}

; SDF
define float @sdf(ptr %sdf.point, float %sdf.radius, float %sdf.repeat) {
  %sdf.npoint = alloca %struct.point ; Allocate new point to be output of @wrap.point
  %sdf.point.wrapped = call ptr @wrap.point(ptr %sdf.point, float %sdf.repeat, ptr %sdf.npoint)
  %sdf.d = call float @hypot(ptr %sdf.point.wrapped)
  %sdf.return = fsub float %sdf.d, %sdf.radius
  ret float %sdf.return
}

; Normalize point struct
define void @normalize(ptr %normalize.point) {
  %normalize.point.x = getelementptr inbounds %struct.point, ptr %normalize.point, i32 0, i32 0
  %normalize.point.y = getelementptr inbounds %struct.point, ptr %normalize.point, i32 0, i32 1
  %normalize.point.z = getelementptr inbounds %struct.point, ptr %normalize.point, i32 0, i32 2
  %normalize.point.x.val = load float, ptr %normalize.point.x
  %normalize.point.y.val = load float, ptr %normalize.point.y
  %normalize.point.z.val = load float, ptr %normalize.point.z
  %normalize.d = call float @hypot(ptr %normalize.point)
  %normalize.point.x.norm = fdiv float %normalize.point.x.val, %normalize.d
  %normalize.point.y.norm = fdiv float %normalize.point.y.val, %normalize.d
  %normalize.point.z.norm = fdiv float %normalize.point.z.val, %normalize.d
  store float %normalize.point.x.norm, ptr %normalize.point.x
  store float %normalize.point.y.norm, ptr %normalize.point.y
  store float %normalize.point.z.norm, ptr %normalize.point.z
  ret void
}

; Accumulate point value
define void @accumulate(ptr %accumulate.a, ptr %accumulate.b) {
  ; Get point a values
  %accumulate.a.x = getelementptr inbounds %struct.point, ptr %accumulate.a, i32 0, i32 0
  %accumulate.a.y = getelementptr inbounds %struct.point, ptr %accumulate.a, i32 0, i32 1
  %accumulate.a.z = getelementptr inbounds %struct.point, ptr %accumulate.a, i32 0, i32 2
  ; Get point b values
  %accumulate.b.x = getelementptr inbounds %struct.point, ptr %accumulate.b, i32 0, i32 0
  %accumulate.b.y = getelementptr inbounds %struct.point, ptr %accumulate.b, i32 0, i32 1
  %accumulate.b.z = getelementptr inbounds %struct.point, ptr %accumulate.b, i32 0, i32 2
  ; Dereference pointers
  %accumulate.a.x.val = load float, ptr %accumulate.a.x
  %accumulate.a.y.val = load float, ptr %accumulate.a.y
  %accumulate.a.z.val = load float, ptr %accumulate.a.z
  %accumulate.b.x.val = load float, ptr %accumulate.b.x
  %accumulate.b.y.val = load float, ptr %accumulate.b.y
  %accumulate.b.z.val = load float, ptr %accumulate.b.z
  ; Add pointers
  %accumulate.sum.x = fadd float %accumulate.a.x.val, %accumulate.b.x.val
  %accumulate.sum.y = fadd float %accumulate.a.y.val, %accumulate.b.y.val
  %accumulate.sum.z = fadd float %accumulate.a.z.val, %accumulate.b.z.val
  ; Store
  store float %accumulate.sum.x, ptr %accumulate.a.x
  store float %accumulate.sum.y, ptr %accumulate.a.y
  store float %accumulate.sum.z, ptr %accumulate.a.z
  ret void
}

; Multiply point by scalar
define void @multiply(ptr %multiply.point, float %multiply.scalar) {
  ; Get point values
  %multiply.point.x = getelementptr inbounds %struct.point, ptr %multiply.point, i32 0, i32 0
  %multiply.point.y = getelementptr inbounds %struct.point, ptr %multiply.point, i32 0, i32 1
  %multiply.point.z = getelementptr inbounds %struct.point, ptr %multiply.point, i32 0, i32 2
  ; Dereference pointers
  %multiply.point.x.val = load float, ptr %multiply.point.x
  %multiply.point.y.val = load float, ptr %multiply.point.y
  %multiply.point.z.val = load float, ptr %multiply.point.z
  ; Multiply pointers
  %multiply.prod.x = fmul float %multiply.point.x.val, %multiply.scalar
  %multiply.prod.y = fmul float %multiply.point.y.val, %multiply.scalar
  %multiply.prod.z = fmul float %multiply.point.z.val, %multiply.scalar
  ; Store
  store float %multiply.prod.x, ptr %multiply.point.x
  store float %multiply.prod.y, ptr %multiply.point.y
  store float %multiply.prod.z, ptr %multiply.point.z
  ret void
}

define i32 @main() {
  entry:
  %stdout = load ptr, ptr @stdout

  ; Screen Constants
  %screen.width.adr = alloca i32
  store i32 50, ptr %screen.width.adr
  %screen.width = load i32, ptr %screen.width.adr

  %screen.height.adr = alloca i32
  store i32 20, ptr %screen.height.adr
  %screen.height = load i32, ptr %screen.height.adr

  %screen.width.d = sub i32 %screen.width, 1
  %screen.height.d = sub i32 %screen.height, 1
  ; WAIT! Why do we need width and height constants that are 49 and 19 instead
  ; of 50 and 20? I am lazy and incrementing a for loop *after* the code has
  ; run takes an extra block compared to incrementing before. Since I did not
  ; consider this beforehand loops have range [-1 ... val - 1] which after
  ; accounting for pre-incrementing turns into [0 ... val]. Hope this helps!

  ; BTW this isn't the case for steps because the value of the steps
  ; incrementation variable doesn't matter, it is not directly used in
  ; calculation so as long as the length of it's range is identical nothing
  ; changes. If you feel like fixing this it would be an easy pull request!

  ; Scene Constants
  %camera = alloca %struct.point
  %camera.x.adr = getelementptr inbounds %struct.point, ptr %camera, i32 0, i32 0
  %camera.y.adr = getelementptr inbounds %struct.point, ptr %camera, i32 0, i32 1
  %camera.z.adr = getelementptr inbounds %struct.point, ptr %camera, i32 0, i32 2

  store float 1.0, ptr %camera.x.adr
  store float 2.0, ptr %camera.y.adr
  store float -4.0, ptr %camera.z.adr

  %camera.x = load float, ptr %camera.x.adr
  %camera.y = load float, ptr %camera.y.adr
  %camera.z = load float, ptr %camera.z.adr

  %scene.steps.adr = alloca i32
  store i32 40, ptr %scene.steps.adr
  %scene.steps = load i32, ptr %scene.steps.adr

  %scene.repeat.adr = alloca float
  store float 5.0, ptr %scene.repeat.adr
  %scene.repeat = load float, ptr %scene.repeat.adr

  %scene.radius.adr = alloca float
  store float 1.5, ptr %scene.radius.adr
  %scene.radius = load float, ptr %scene.radius.adr

  ; Variables
  %screen.x = alloca i32
  %screen.y = alloca i32
  %direction = alloca %struct.point
  %position = alloca %struct.point
  %traveled = alloca float
  %steps = alloca i32
  %direction.copy = alloca %struct.point

  ; Per pixel logic
  store i32 -1, ptr %screen.y
  br label %loop.screen.y

loop.screen.y:
  ; Check loop condition
  %screen.y.cur = load i32, ptr %screen.y
  %loop.screen.y.break = icmp slt i32 %screen.y.cur, %screen.height.d
  br i1 %loop.screen.y.break, label %loop.screen.y.body, label %loop.screen.y.end

loop.screen.y.body:
  ; Increment screen.y
  %screen.y.body.cur = load i32, ptr %screen.y
  %screen.y.body.cur.i = add i32 %screen.y.body.cur, 1
  store i32 %screen.y.body.cur.i, ptr %screen.y

  ; Screen.x loop init
  store i32 -1, ptr %screen.x
  br label %loop.screen.x

loop.screen.x:
  ; Check loop condition
  %screen.x.cur = load i32, ptr %screen.x
  %loop.screen.x.break = icmp slt i32 %screen.x.cur, %screen.width.d
  br i1 %loop.screen.x.break, label %loop.screen.x.body, label %loop.screen.x.end

loop.screen.x.body:
  ; Increment screen.x
  %screen.x.body.cur = load i32, ptr %screen.x
  %screen.x.body.cur.i = add i32 %screen.x.body.cur, 1
  store i32 %screen.x.body.cur.i, ptr %screen.x

  ; For each screen pixel:
  
  ; Get direction
  %screen.x.il.cur = load i32, ptr %screen.x
  %screen.y.il.cur = load i32, ptr %screen.y
  %screen.x.il.cur.fp = sitofp i32 %screen.x.il.cur to float
  %screen.y.il.cur.fp = sitofp i32 %screen.y.il.cur to float
  %screen.width.fp = sitofp i32 %screen.width to float
  %screen.height.fp = sitofp i32 %screen.height to float
  %clamped.x = fdiv float %screen.x.il.cur.fp, %screen.width.fp
  %clamped.y = fdiv float %screen.y.il.cur.fp, %screen.height.fp
  %centered.x = fsub float %clamped.x, 0.5
  %centered.y = fsub float %clamped.y, 0.5
  %direction.x = getelementptr inbounds %struct.point, ptr %direction, i32 0, i32 0
  %direction.y = getelementptr inbounds %struct.point, ptr %direction, i32 0, i32 1
  %direction.z = getelementptr inbounds %struct.point, ptr %direction, i32 0, i32 2
  store float %centered.x, ptr %direction.x
  store float %centered.y, ptr %direction.y
  store float 1.0, ptr %direction.z

  ; Normalize direction
  call void @normalize(ptr %direction)

  ; Init position
  %position.x = getelementptr inbounds %struct.point, ptr %position, i32 0, i32 0
  %position.y = getelementptr inbounds %struct.point, ptr %position, i32 0, i32 1
  %position.z = getelementptr inbounds %struct.point, ptr %position, i32 0, i32 2

  store float %camera.x, ptr %position.x
  store float %camera.y, ptr %position.y
  store float %camera.z, ptr %position.z

  ; Init traveled
  store float 0.0, ptr %traveled

  ; Setup step logic
  store i32 0, ptr %steps
  br label %loop.steps

loop.steps:
  ; Check loop condition
  %steps.cur = load i32, ptr %steps
  %loop.steps.break = icmp slt i32 %steps.cur, %scene.steps
  br i1 %loop.steps.break, label %loop.steps.body, label %loop.steps.end

loop.steps.body:
  ; March ray forward:
  %safe = call float @sdf(ptr %position, float %scene.radius, float %scene.repeat)

  ; Update traveled
  %traveled.cur = load float, ptr %traveled
  %traveled.psafe = fadd float %traveled.cur, %safe
  store float %traveled.psafe, ptr %traveled

  ; Save direction
  %direction.copy.x = getelementptr inbounds %struct.point, ptr %direction.copy, i32 0, i32 0
  %direction.copy.y = getelementptr inbounds %struct.point, ptr %direction.copy, i32 0, i32 1
  %direction.copy.z = getelementptr inbounds %struct.point, ptr %direction.copy, i32 0, i32 2
  %direction.x.cur = load float, ptr %direction.x
  %direction.y.cur = load float, ptr %direction.y
  %direction.z.cur = load float, ptr %direction.z
  store float %direction.x.cur, ptr %direction.copy.x
  store float %direction.y.cur, ptr %direction.copy.y
  store float %direction.z.cur, ptr %direction.copy.z

  ; Scale direction
  call void @multiply(ptr %direction.copy, float %safe)

  ; Update position
  call void @accumulate(ptr %position, ptr %direction.copy)

  ; Increment steps
  %steps.body.cur = load i32, ptr %steps
  %steps.body.cur.i = add i32 %steps.body.cur, 1
  store i32 %steps.body.cur.i, ptr %steps
  br label %loop.steps

loop.steps.end:
  %traveled.val = load float, ptr %traveled
  %traveled.5 = fcmp olt float %traveled.val, 5.0
  %traveled.10 = fcmp olt float %traveled.val, 10.0
  %traveled.15 = fcmp olt float %traveled.val, 15.0
  %traveled.20 = fcmp olt float %traveled.val, 20.0

  br i1 %traveled.5, label %cond.traveled.5.t, label %cond.traveled.5.f

cond.traveled.5.t:
  call i32 @putc(i32 noundef 35, ptr noundef %stdout) ; 35 = #
  br label %cond.traveled.end

cond.traveled.5.f:
  br i1 %traveled.10, label %cond.traveled.10.t, label %cond.traveled.10.f

cond.traveled.10.t:
  call i32 @putc(i32 noundef 124, ptr noundef %stdout) ; 124 = |
  br label %cond.traveled.end

cond.traveled.10.f:
  br i1 %traveled.15, label %cond.traveled.15.t, label %cond.traveled.15.f

cond.traveled.15.t:
  call i32 @putc(i32 noundef 58, ptr noundef %stdout) ; 58 = :
  br label %cond.traveled.end

cond.traveled.15.f:
  br i1 %traveled.20, label %cond.traveled.20.t, label %cond.traveled.20.f

cond.traveled.20.t:
  call i32 @putc(i32 noundef 46, ptr noundef %stdout) ; 46 = .
  br label %cond.traveled.end

cond.traveled.20.f:
  call i32 @putc(i32 noundef 32, ptr noundef %stdout) ; 32 =  
  br label %cond.traveled.end

cond.traveled.end:
  
  ; End for each screen pixel
  br label %loop.screen.x

loop.screen.x.end:
  call i32 @putc(i32 noundef 10, ptr noundef %stdout)
  br label %loop.screen.y

loop.screen.y.end:

  ret i32 0
}
