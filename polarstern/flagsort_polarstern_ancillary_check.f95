      program flagsort
      IMPLICIT NONE

      integer(kind=8) :: ii,jj          !do loops 

! cont collocated dship data with port times
      integer(kind=8) :: date,time
      integer(kind=8) :: mmday                                    ! minutes of day
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


      open(10,file='joint_PSDISDRO_PS76-PS83_PS85-PS90_PS92-PS97_colloc_cont_ww_nc.txt') ! ww_nc
      open(11,file='joint_PSDISDRO_PS76-PS83_PS85-PS90_PS92-PS97_colloc_cont_ww_nc_ancillary_checked.txt') ! ww_nc_corr

!C####################################################################
!C###### Formate #####################################################
1000  format(i8.8,1x,i8.8,1x,i4.4,1x,i4.4,1x,f14.6,1x,i12,1x,f8.4,1x,&
           & f9.4,1x,4(f5.1,1x),i3,1x,f6.1,1x,2(f4.1,1x,i3,1x),f6.1, &
           & 1x,i5,1x,i6,1x,f5.1,1x,f6.2,1x,f6.2,1x,3(i3.2,1x),      &
           & 6(f9.2,1x),i5,1x,i5,1x,i3.2,1x,i5.4,1x,f9.2,1x,f20.2,   &
           & 2(1x,f12.2),2(1x,f9.2))

!C####################################################################
!C###### Daten einlesen und neue Daten rausschreiben #################

		do ii = 1,2886331
		read(10,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                  & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                  & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                  & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                  & dbr,dbz,wind,uref

		if(UTC.gt.1288925400.AND.UTC.lt.1288950780) then
         write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,-99.99,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref 									!correction of salinity
		else if(UTC.eq.1305470280.OR.UTC.eq.1305470280.OR.UTC.eq.1309708740 &
		.OR.UTC.eq.1313891160.OR.UTC.eq.1317516000.OR.UTC.eq.1329067500 &
		.OR.UTC.eq.1345106220.OR.UTC.eq.1347430320.OR.UTC.eq.1348893240 &
		.OR.UTC.eq.1404088140.OR.UTC.eq.1405748340.OR.UTC.eq.1414715460 &
		.OR.UTC.eq.1416282900.OR.UTC.eq.1417584240.OR.UTC.eq.1417855380 &
		.OR.UTC.eq.1421770620.OR.UTC.eq.1421889120.OR.UTC.eq.1421931900 &
		.OR.UTC.eq.1422530520.OR.UTC.eq.1423775940.OR.UTC.eq.1423777080 &
		.OR.UTC.eq.1423986840.OR.UTC.eq.1425969120.OR.UTC.eq.1439952360 &
		.OR.UTC.eq.1442474280.OR.UTC.eq.1446461280.OR.UTC.eq.1447176420 &
		.OR.UTC.eq.1447919040.OR.UTC.eq.1448343720.OR.UTC.eq.1451192340) then
         write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,-99.9,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref 									!correction of temperature
		else if(UTC.eq.1368701220) then
		 write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,-99.99,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref										!correction of salinity
		else if(UTC.eq.1412085120) then
		 write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,-99,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref
		else
		write(11,1000)c,date,time,mmday,kc,UTC,lat,lon,head,temp,dewt, &
                    & wtemp,rh,pres,relFF,relDD,trueFF,trueDD,rad1,vis,&
                    & ceil,maxFF,sal,gauge,ww,w1,w2,perc99,train,tsnow,&
                    & rpar,spar,mpar,flag,flag2,bins,nums,precip,refl, &
                    & dbr,dbz,wind,uref                                 ! good data	


		endif
	enddo
end




