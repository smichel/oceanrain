      program flagsort
      IMPLICIT NONE

      integer :: ii,jj          !do loops 

! cont collocated dship data with port times
      integer :: date,time
      integer :: mmday                                    ! minutes of day
      real(kind=8) :: kc                                  ! cont count
      integer(kind=8) :: UTC                              ! dship data
      integer :: rh, relDD, trueDD                        ! dship data
      real :: lat, head, temp, dewt, wtemp, pres, relFF, trueFF ! dship data
      real(kind=8) :: lon                                 ! dship data
      real :: rad1, maxFF, sal, gauge                     ! dship data
      integer :: vis, ceil, ww, w1, w2                    ! dship data
      integer :: flag, flag2, c
      real :: perc99, train,tsnow,rpar,spar,mpar,precip,wind,uref
      integer :: bins, nums
      real :: refl,dbr,dbz


!C####################################################################
!C###### Ein- und Ausgabe-files oeffnen ##############################
!C####################################################################


      open(10,file='joint_investigator_disdro_2016T01-2016V04_colloc_cont_ww_nc.txt') ! ww_nc
      open(11,file='joint_investigator_disdro_2016T01-2016V04_colloc_cont_ww_nc_ancillary_checked.txt') ! ww_nc_corr

!C####################################################################
!C###### Formate #####################################################
1000  format(i8.8,1x,i8.8,1x,i4.4,1x,i4.4,1x,f14.6,1x,i12,1x,f8.4,1x,&
           & f9.4,1x,4(f5.1,1x),i3,1x,f6.1,1x,2(f4.1,1x,i3,1x),f6.1, &
           & 1x,i5,1x,i6,1x,f5.1,1x,f6.2,1x,f6.2,1x,3(i3.2,1x),      &
           & 6(f9.2,1x),i5,1x,i5,1x,i3.2,1x,i5.4,1x,f9.2,1x,f20.2,   &
           & 2(1x,f12.2),2(1x,f9.2))

!C####################################################################
!C###### Daten einlesen und neue Daten rausschreiben #################

      do ii = 1,232158
       read(10,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                  & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                  & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                  & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                  & dbr,dbz,wind,uref


        if(sal.lt.20) then !unrealistical low values for salinity are removed
        write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,-99.99,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref
		else
		write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref
		endif
	enddo
end


