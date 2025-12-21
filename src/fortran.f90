program raymarcher
        implicit none

        integer, parameter :: s_width = 50
        integer, parameter :: s_height = 20

        real (kind=kind(1.0d0)), dimension(3) :: camera = [ 1.0, 2.0, -4.0 ]

        integer, parameter :: steps = 40

        real (kind=kind(1.0d0)), parameter :: radius = 1.5
        real (kind=kind(1.0d0)), parameter :: s_repeat = 5.0


        ! used for inner loop
        integer :: x, y, s

        real (kind=kind(1.0d0)), dimension(3) :: direction, position
        real (kind=kind(1.0d0)) :: safe, traveled

        do y = 0, s_height - 1
                do x = 0, s_width - 1
                        position = camera
                        direction = [ real(x, kind=kind(1.0d0)) / s_width - 0.5d0, real(y, kind=kind(1.0d0)) / s_height - 0.5d0, 1.0d0 ]
                        direction = NORMALIZE(direction)
                        traveled = 0.0d0
                        do s = 1, steps
                                position = WRAP(position, s_repeat)
                                safe = SDF(position)
                                position = position + direction * safe
                                traveled = traveled + safe
                        end do
                        if (traveled < 5.0d0) then
                                write(*, fmt='(a)', advance='no') '#'
                        else if (traveled < 10.0d0) then
                                write(*, fmt='(a)', advance='no') '|'
                        else if (traveled < 15.0d0) then
                                write(*, fmt='(a)', advance='no') ':'
                        else if (traveled < 20.0d0) then
                                write(*, fmt='(a)', advance='no') '.'
                        else
                                write(*, fmt='(a)', advance='no') ' '
                        end if
                end do
                print *
        end do
contains
        real (kind=kind(1.0d0)) function SDF(point)
                real (kind=kind(1.0d0)), intent(in), dimension(3) :: point
                SDF = sqrt(sum(point**2)) - radius
        end function SDF

        pure function NORMALIZE(point) result(out)
                real (kind=kind(1.0d0)), intent(in), dimension(3) :: point
                real (kind=kind(1.0d0)), dimension(3) :: out
                out = point / sqrt(sum(point**2))
        end function NORMALIZE

        pure function WRAP(point, s_repeat) result(out)
                real (kind=kind(1.0d0)), intent(in), dimension(3) :: point
                real (kind=kind(1.0d0)), intent(in) :: s_repeat
                real (kind=kind(1.0d0)), dimension(3) :: out
                out = modulo(point + 0.5d0*s_repeat, s_repeat) - 0.5d0*s_repeat
        end function WRAP

end program raymarcher
