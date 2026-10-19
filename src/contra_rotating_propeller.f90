! Contra-rotating propeller induced-velocity calculation.
!
! Faithful free-form transcription of the Fortran program
! in Khan & Islam, "Energy Study: Contra-rotating Propeller System" (2017),
! Chapter 4, pages 26-32 (PDF pages 26-33).
!
! Numerical method: Biot-Savart evaluation of helical tip, hub, and bound
! vortex contributions for eight radial sections on each propeller.
!
! See docs/TRANSCRIPTION_NOTES.md for changes and numerical caveats.
program contra_rotating_propeller
  implicit none

  integer :: nbl, is, ij, i, ii, j, nb, k, l, m
  logical :: correct_bound_angle
  character(len=64) :: arg
  real :: betaw, cirm, zt, xt, tt, tpi, rds
  real :: thss(27), ths(28), ux(5), uy(5), uz(5)
  real :: xr(9), xrs(9), circ(8)
  real :: zf, tf, xf, f1, f2, e1, e2, e3, e4, phiz, dth, te1, te
  real :: a, b, ux1, uy1, uz1, uxf, uyf, uzf
  real :: xy, xyz, xyz1, cc, dd, cir, uxh, uyh, uzh
  real :: uxb, uyb, uzb, x1, y1, x2, y2, xx, yy
  real :: fx1, fy1, fx2, fy2, c, d, e, f, g, h, p, s, t
  real :: uxt, uyt, uzt, ua, ut, ur

  data thss /2*.0625, 3*.125, 6*.25, 16*.5/

  ! No argument: reproduce the program AS PRINTED in Chapter 4.
  ! Optional argument: apply the likely E1/E2 bound-vortex typo correction.
  correct_bound_angle = .false.
  e2 = 0.0  ! Defined defensively; tip-vortex loop assigns it before bound use.
  if (command_argument_count() > 0) then
    call get_command_argument(1, arg)
    if (trim(arg) /= '--corrected-bound-angle' .or. command_argument_count() /= 1) then
      write(*,'(a)') 'Usage: contra_rotating_propeller [--corrected-bound-angle]'
      stop 2
    end if
    correct_bound_angle = .true.
  end if

  ! The original program uses these three fixed filenames in its CWD.
  open(unit=11, file='FA8.DAT', status='old', action='read')
  open(unit=22, file='FA8.OUT', status='replace', action='write')
  open(unit=33, file='FA88.OUT', status='replace', action='write')

  do is = 1, 2
    read(11, 2) nbl, betaw, cirm, zt, xt, tt
2   format(5x, i1, 5f7.4)
    read(11, 3) (xr(i), i=1,9)
    read(11, 3) (xrs(i), i=1,9)
    read(11, 4) (circ(i), i=1,8)
3   format(5x, 9f6.4)
4   format(5x, 8f6.4)

    write(22, 5) nbl, betaw, cirm, zt, xt, tt
5   format(5x, i1, 5f7.4)
    write(22, 6) (xr(i), i=1,9)
    write(22, 6) (xrs(i), i=1,9)
    write(22, 7) (circ(i), i=1,8)
    write(22, 8) (thss(i), i=1,27)
6   format(5x, 9f6.4)
7   format(5x, 8f6.4)
8   format(3(5x, 9f6.4/))

    ! Calculation 1: tip vortex.
    tpi = 8.0 * atan(1.0)
    rds = 57.2958
    ths(1) = 0.0
    do i = 2, 28
      ths(i) = ths(i-1) + thss(i-1)
    end do
    ! As in the thesis listing: use max(CIRC) rather than read-in CIRM.
    cirm = 0.0
    do i = 1, 8
      cirm = amax1(cirm, circ(i))
    end do

    do ij = 1, 2
      if (is == 1 .and. ij == 1) then
        write(33, 30)
        write(33, 31)
      else if (is == 1 .and. ij == 2) then
        write(33, 32)
      else if (is == 2 .and. ij == 1) then
        write(33, 33)
      else
        write(33, 34)
      end if
30    format(//5x,'TABLE: PROPELLER PERFORMANCE CHARACTERISTICS'/ &
              5x,6('-')/13x,'(VARIATION OF AXIAL,TANGENTIAL AND RADIAL'/ &
              13x,'COMPONENT OF SELF AND MUTUAL INDUCED VELOCITIES)'/ &
              13x,48('-'))
31    format(/5x,'SELF INDUCED VELOCITY(FORE PROPELLER)'/ &
              5x,40('-')/5x,'XF',10x,'UA/VS',6x,'UT/VS',6x,'UR/VS')
32    format(/5x,'MUTUAL INDUCED VELOCITY(AFT PROPELLER)'/ &
              5x,40('-')/5x,'XF',10x,'UA/VS',6x,'UT/VS',6x,'UR/VS')
33    format(/5x,'SELF INDUCED VELOCITY(AFT PROPELLER)'/ &
              5x,40('-')/5x,'XF',10x,'UA/VS',6x,'UT/VS',6x,'UR/VS')
34    format(/5x,'MUTUAL INDUCED VELOCITY(FORE PROPELLER)'/ &
              5x,40('-')/5x,'XF',10x,'UA/VS',6x,'UT/VS',6x,'UR/VS')

      do ii = 1, 8
        zf = 0.0
        if (ij == 2) zf = zt
        tf = 0.0
        xf = (xr(ii) + xr(ii+1)) / 2.0
        if (is == 1 .and. ij == 2) xf = ((xrs(ii) + xrs(ii+1)) / 2.0) * 0.933
        if (is == 2 .and. ij == 2) xf = ((xrs(ii) + xrs(ii+1)) / 2.0) * (1.0/0.933)
        f1 = xf * sin(tf/rds)
        f2 = xf * cos(tf/rds)
        e3 = tan(betaw/rds)
        uxf = 0.0
        uyf = 0.0
        uzf = 0.0
        do nb = 1, nbl
          phiz = tpi * (nb-1) / nbl
          do j = 1, 27
            dth = (ths(j+1)-ths(j)) / 4.0
            k = 1
            if (nb > 1) k = 2
            l = 0
            do m = 1, 5, k
              l = l + 1
              te1 = ths(j) + dth*(m-1)
              te = phiz + te1
              e1 = sin(te)
              e2 = cos(te)
              e4 = zf - xt*te1*e3
              a = xf*xf + xt*xt - 2.0*xt*f1*e1 - 2.0*xt*f2*e2 + e4*e4
              a = a**1.5
              a = 1.0/(2.0*tpi*a)
              b = a*xt*e3*cirm
              ux1 = -e1*e4/e3 - f2 + xt*e2
              ux(l) = b*ux1
              uy1 = f1 - xt*e1 - (1.0/e3)*e2*e4
              uy(l) = b*uy1
              uz1 = (1.0/e3)*e2*(f2-xt*e2) + (f1-xt*e1)*e1/e3
              uz(l) = b*uz1
            end do
            if (nb == 1) then
              uxf = uxf+(dth/3.0)*(ux(1)+ux(5)+2.0*ux(3)+4.0*(ux(2)+ux(4)))
              uyf = uyf+(dth/3.0)*(uy(1)+uy(5)+2.0*uy(3)+4.0*(uy(2)+uy(4)))
              uzf = uzf+(dth/3.0)*(uz(1)+uz(5)+2.0*uz(3)+4.0*(uz(2)+uz(4)))
            else
              uxf = uxf+(dth*2.0/3.0)*(ux(1)+ux(3)+4.0*ux(2))
              uyf = uyf+(dth*2.0/3.0)*(uy(1)+uy(3)+4.0*uy(2))
              uzf = uzf+(dth*2.0/3.0)*(uz(1)+uz(3)+4.0*uz(2))
            end if
          end do
        end do
        write(22, 17) nbl, betaw, cirm, zf, xf, tf
17      format(/1x,'NBL=',i1,1x,'BETAW = ',f7.3, &
                 1x,'CIRM = ',f6.4,1x,'ZF=',f6.4,1x, &
                 'XF=',f6.4,1x,'TF= ',f6.4)
        write(22, 18) uxf, uyf, uzf
18      format(10x,'UXF = ',2x,e13.6,2x,'UYF=',2x,e13.6,2x,'UZF=',2x,e13.6)

        ! Calculation 2: hub vortex.
        xy = f1*f1 + f2*f2
        xyz = sqrt(xy+zf*zf)
        xyz1 = 1.0+zf/xyz
        cc = (f2/xy)*xyz1
        dd = (-f1/xy)*xyz1
        cir = cirm/(2.0*tpi)
        uxh = cc*cir*nbl
        uyh = dd*cir*nbl
        uzh = 0.0
        write(22, 19) uxh, uyh, uzh
19      format(10x,'UXH = ',2x,e13.6,2x,'UYH = ',2x,e13.6,2x,'UZH = ',2x,e13.6)

        ! Calculation 3: bound vortex.
        uxb = 0.0
        uyb = 0.0
        uzb = 0.0
        do nb = 1, nbl
          phiz = tpi*(nb-1)/nbl
          e1 = sin(phiz)
          if (correct_bound_angle) then
            e2 = cos(phiz)  ! Likely intended component; experimental option.
          else
            e1 = cos(phiz)  ! Exact listing: E2 carries over from tip loop.
          end if
          do i = 1, 8
            x1 = xr(i)*e1
            y1 = xr(i)*e2
            x2 = xr(i+1)*e1
            y2 = xr(i+1)*e2
            xx = x2-x1
            yy = y2-y1
            fx1 = f1-x1
            fy1 = f2-y1
            fx2 = f1-x2
            fy2 = f2-y2
            c = zf*yy
            d = zf*xx
            e = fx1*fy2-fx2*fy1
            f = xx*fx1+yy*fy1
            g = xx*fx2+yy*fy2
            h = sqrt(fx1*fx1+fy1*fy1+zf*zf)
            p = sqrt(fx2*fx2+fy2*fy2+zf*zf)
            s = f/h-g/p
            t = c*c+d*d+e*e
            if (.not. (t < 0.0 .or. t > 0.0)) cycle
            cir = circ(i)/(2.0*tpi)
            uxb = uxb+(c*s/t)*cir
            uyb = uyb-(d*s/t)*cir
            uzb = uzb+(e*s/t)*cir
          end do
        end do
        write(22, 23) nbl, betaw, circ(ii), zf, xf, tf
23      format(1x,'NBL = ',i1,1x,'BETAW = ',f7.3, &
                 1x,'CIRC = ',f6.4,1x,'ZF = ',f6.4, &
                 1x,'XF = ',f6.4,1x,'TF = ',f6.4)
        write(22, 24) uxb, uyb, uzb
24      format(10x,'UXB = ',2x,e13.6,2x,'UYB = ',2x,e13.6,2x,'UZB = ',2x,e13.6)
        uxt = uxf+uxh+uxb
        uyt = uyf+uyh+uyb
        uzt = uzf+uzh+uzb
        write(22, 25) xf, uxt, uyt, uzt
25      format(2x,'XF = ',f6.4,2x,'UXT = ',e13.6, &
                 2x,'UYT = ',e13.6,2x,'UZT = ',e13.6)
        ua = -uzt*tpi
        ut = -uxt*tpi
        ur = uyt*tpi
        if (is == 1 .and. ij == 2) xf = xf/0.933
        if (is == 2 .and. ij == 2) xf = xf*0.933
        write(33, 35) xf, ua, ut, ur
35      format(5x,f6.4,5x,f7.4,5x,f7.4,5x,f7.4)
      end do
    end do
  end do

  close(11)
  close(22)
  close(33)
end program contra_rotating_propeller
