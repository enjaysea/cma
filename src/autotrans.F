MODULE autotrans_module

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!            INSTRUCTIONS TO ADD AUTOTRANS (Kalman filter storm centering module)
!                                 INTO ANY VERSION OF CM1
!                  note: this only works with netcdf file output and restart
!
!                                 CREATED BY ALEX SCHUETH
!                                   LAST UPDATED 12/7/21
! FEEL FREE TO CONTACT alex.schueth@ttu.edu OR OPEN AN ISSUE ON GITHUB WITH ANY PROBLEMS OR QUESTIONS
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
!  First, copy this file, "autotrans.F" into the CM1 source directory
!
!---------------------------------    solve.f      -------------------------------------------
!  add "restarted_autotrans,X_kal, P_kal, umdt, vmdt" in the solve() subroutine arguments
!  add "use autotrans_module" in the use statements at the top of the solve subroutine
!  change the declaration of u0 and v0 to be inout
!  at the end of the variable initializations passed into solve, approximately line 294, add the following:
!
!         logical, intent(inout) :: restarted_autotrans
!         real, intent(inout), dimension(4,1) :: X_kal
!         real, intent(inout), dimension(4,4) :: P_kal
!         real, intent(inout) :: umdt,vmdt
!
!  Farther down in the vicinity of line 4220, right before the triple do loop containing "ua(i,j,k)=u3d(i,j,k)" add the autotrans call:
!
!        IF(imove.eq.1 .and. automove.eq.1 ) THEN ! do every time step
!        call autotrans(uf,vf,zh,zf, &
!                      ug,vg,u0,ua,u3d,v0,va,v3d,wa, &
!                      dum2,dum5,dum6,zs,rgzu,rgzv,rds,sigma, &
!                      rdsf,sigmaf,dat1,dat2,dat3,reqt, &
!                      xfref,yfref,dt,mtime,nstep,restarted_autotrans,X_kal,P_kal,umdt,vmdt)
!        ENDIF
!
!--------------------------------    input.F     --------------------------------------------
!
!  add the variable "automove" right after "imove" in the large integer block starting with nx
!                                                                     approximately line 90
!  add "automove" in namelist param2 right after imove, approximately line 217
!
!--------------------------------      param.F    -------------------------------------------
!
!  add the following after the MPI_BCAST(imove...), approximately line 271:
!
!      call MPI_BCAST(automove ,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
!
!  add the following after if(dowr) write(outfile,*) 'imove....', approximately line 2353:
!
!      if(dowr) write(outfile,*) 'automove   =',automove
!
!-------------------------------       restart.F     ----------------------------------------
!
!  add "X_kal, P_kal, umdt, vmdt" in the write_restart() subroutine arguments
!  add the variables X-kal, P-kal, umdt, and vmdt in write_restart() subroutine, approximately line 116:
!
!      real, intent(in   ) , dimension(4,1) :: X_kal
!      real, intent(in   ) , dimension(4,4) :: P_kal
!      real, intent(in   ) :: umdt, vmdt
!
!  add variables in restart_prelim call, approximately line 266:
!
!    if( myid.eq.0 )then
!      call     restart_prelim(nrst,ncid,mtime,xfref,yfref,zh,zf,sigma,sigmaf,  &
!                              qname,num_soil_layers,nrad2d,dat2(1,1),dat2(1,2),dum1(ib,jb,kb),time_index, X_kal,P_kal,umdt,vmdt)
!
!
!  add the following lines after "call disp_err( nf90_inq_varid(ncid,"ycenter",varid) , .true. )" (line 414ish)
!
!           call disp_err( nf90_put_var(ncid,varid,X_kal(1,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,X_kal(2,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,X_kal(3,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,X_kal(4,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(1,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(1,2),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(1,3),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(1,4),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(2,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(2,2),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(2,3),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(2,4),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(3,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(3,2),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(3,3),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(3,4),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(4,1),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(4,2),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(4,3),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,P_kal(4,4),(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,umdt,(/time_index/)) , .true. )
!           call disp_err( nf90_put_var(ncid,varid,vmdt,(/time_index/)) , .true. )
!
!  add "X_kal, P_kal, umdt, vmdt" in the read_restart() subroutine arguments, approximately line 1666
!  add the following in the read_restart() subroutine variable initializations, approximately line 1750
!
!            real, intent(inout) , dimension(4,1) :: X_kal
!            real, intent(inout) , dimension(4,4) :: P_kal
!            real, intent(inout) :: umdt, vmdt
!            real :: X_kal11, X_kal21, X_kal31, X_kal41
!            real :: P_kal11, P_kal21, P_kal31, P_kal41, P_kal12, P_kal22, P_kal32, P_kal42, P_kal13, P_kal23, P_kal33, P_kal43, P_kal14, P_kal24, P_kal34, P_kal44
!
!  add the following lines after "call disp_err( nf90_inq_varid(ncid,"ycenter",varid) , .true. )" (line 2068 ish)
!
!            call disp_err( nf90_inq_varid(ncid,"X_kal11",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,X_kal11,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"X_kal21",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,X_kal21,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"X_kal31",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,X_kal31,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"X_kal41",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,X_kal41,(/time_index/)) , .true. )
!
!            X_kal(1,1)=X_kal11
!            X_kal(2,1)=X_kal21
!            X_kal(3,1)=X_kal31
!            X_kal(4,1)=X_kal41
!            if( myid.eq.0 ) print *,'X_kal ',X_kal
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal11",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal11,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal12",varid) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal13",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal13,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal14",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal14,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal21",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal21,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal22",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal22,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal23",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal23,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal24",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal24,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal31",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal31,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal32",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal32,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal33",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal33,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal34",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal34,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal41",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal41,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal42",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal42,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal43",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal43,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"P_kal44",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,P_kal44,(/time_index/)) , .true. )
!
!            P_kal(1,1)=P_kal11
!            P_kal(1,2)=P_kal12
!            P_kal(1,3)=P_kal13
!            P_kal(1,4)=P_kal14
!            P_kal(2,1)=P_kal21
!            P_kal(2,2)=P_kal22
!            P_kal(2,3)=P_kal23
!            P_kal(2,4)=P_kal24
!            P_kal(3,1)=P_kal31
!            P_kal(3,2)=P_kal32
!            P_kal(3,3)=P_kal33
!            P_kal(3,4)=P_kal34
!            P_kal(4,1)=P_kal41
!            P_kal(4,2)=P_kal42
!            P_kal(4,3)=P_kal43
!            P_kal(4,4)=P_kal44
!            if( myid.eq.0 ) print *,'P_kal ',P_kal
!
!            call disp_err( nf90_inq_varid(ncid,"umdt",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,umdt,(/time_index/)) , .true. )
!
!            call disp_err( nf90_inq_varid(ncid,"vmdt",varid) , .true. )
!            call disp_err( nf90_get_var(ncid,varid,vmdt,(/time_index/)) , .true. )
!
!
!  add the following lines after "call MPI_BCAST(ycenter,1,MPI_REAL            ,0,MPI_COMM_WORLD,ierr)" (line 2234ish)
!
!            call MPI_BCAST(X_kal,4,MPI_REAL            ,0,MPI_COMM_WORLD,ierr)
!            call MPI_BCAST(P_kal,16,MPI_REAL            ,0,MPI_COMM_WORLD,ierr)
!            call MPI_BCAST(umdt,1,MPI_REAL            ,0,MPI_COMM_WORLD,ierr)
!            call MPI_BCAST(vmdt,1,MPI_REAL            ,0,MPI_COMM_WORLD,ierr)
!
!-----------------------------       writeout.F     -------------------------------------
!
!  add "X_kal, P_kal, umdt, vmdt" in the writeout() subroutine arguments (line 2226 ish)
!  add the following in the writeout() subroutine variable initializations, approximately line 2366
!
!            real, intent(in) , dimension(4,1) :: X_kal
!            real, intent(in) , dimension(4,4) :: P_kal
!            real, intent(in) :: umdt, vmdt
!
!   add the arguments "X_kal, P_kal, umdt, vmdt" in the netcdf_prelim() call near line 2667ish
!
!------------------------------     writeout_nc.F     ------------------------------------
!
!  add "X_kal, P_kal, umdt, vmdt" in the netcdf_prelim() subroutine arguments (line 29 ish)
!  add the following in the netcdf_prelim() subroutine variable initializations, approximately line 63
!
!            real, intent(in) , dimension(4,1) :: X_kal
!            real, intent(in) , dimension(4,4) :: P_kal
!            real, intent(in) :: umdt, vmdt
!
!  add the following lines underneath "call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"fcor",fcor) , .true. )" ~line 427
!
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"X_kal11",X_kal(1,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"X_kal21",X_kal(2,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"X_kal31",X_kal(3,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"X_kal41",X_kal(4,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal11",P_kal(1,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal12",P_kal(1,2)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal13",P_kal(1,3)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal14",P_kal(1,4)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal21",P_kal(2,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal22",P_kal(2,2)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal23",P_kal(2,3)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal24",P_kal(2,4)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal31",P_kal(3,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal32",P_kal(3,2)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal33",P_kal(3,3)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal34",P_kal(3,4)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal41",P_kal(4,1)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal42",P_kal(4,2)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal43",P_kal(4,3)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"P_kal44",P_kal(4,4)) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"umdt",umdt) , .true. )
!            call disp_err( nf90_put_att(ncid,NF90_GLOBAL,"vmdt",vmdt) , .true. )
!
!   add the following lines above the if statement block that contains
!                            "call disp_err( nf90_inq_varid(ncid,'f_cor',varid) , .true. )", ~line 508
!
!              IF( (imove.eq.1).or.(automove.eq.1) )THEN
!                call disp_err( nf90_put_var(ncid,varid,X_kal(1,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,X_kal(2,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,X_kal(3,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,X_kal(4,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(1,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(1,2)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(1,3)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(1,4)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(2,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(2,2)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(2,3)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(2,4)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(3,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(3,2)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(3,3)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(3,4)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(4,1)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(4,2)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(4,3)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,P_kal(4,4)) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,umdt) , .true.)
!                call disp_err( nf90_put_var(ncid,varid,vmdt) , .true.)
!              ENDIF
!
!  add "X_kal, P_kal, umdt, vmdt" in the restart_prelim() subroutine arguments (line 670 ish)
!  add the following in the restart_prelim() subroutine variable initializations, approximately line 694
!
!            real, intent(in) , dimension(4,1) :: X_kal
!            real, intent(in) , dimension(4,4) :: P_kal
!            real, intent(in) :: umdt, vmdt
!
!  add the following lines after
! "call disp_err( nf90_def_var(ncid,"bsq"     ,nf90_double,(/numqid,timeid/),varid) , .true. )" ~ line 915
!
!              call disp_err( nf90_def_var(ncid,"X_kal11",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"X_kal21",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"X_kal31",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"X_kal41",nf90_float,(/timeid/),varid) , .true. )
!
!              call disp_err( nf90_def_var(ncid,"P_kal11",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal12",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal13",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal14",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal21",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal22",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal23",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal24",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal31",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal32",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal33",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal34",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal41",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal42",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal43",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"P_kal44",nf90_float,(/timeid/),varid) , .true. )
!
!              call disp_err( nf90_def_var(ncid,"umdt",nf90_float,(/timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"vmdt",nf90_float,(/timeid/),varid) , .true. )
!
!
!  add the following lines "call disp_err( nf90_def_var(ncid,"swspd"   ,nf90_float,(/niid,njid,timeid/),varid) , .true. )"  ~line 1262ish
!              call disp_err( nf90_def_var(ncid,"wstar"   ,nf90_float,(/niid,njid,timeid/),varid) , .true. )
!              call disp_err( nf90_def_var(ncid,"delta"   ,nf90_float,(/niid,njid,timeid/),varid) , .true. )
!
!
!  add the following lines before "call disp_err( nf90_inq_varid(ncid,'xh',varid) , .true. )" ~line 1528ish?
!
!              call disp_err( nf90_inq_varid(ncid,'X_kal11',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,X_kal(1,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'X_kal21',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,X_kal(2,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'X_kal31',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,X_kal(3,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'X_kal41',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,X_kal(4,1)) , .true. )
!
!              call disp_err( nf90_inq_varid(ncid,'P_kal11',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(1,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal12',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(1,2)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal13',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(1,3)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal14',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(1,4)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal21',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(2,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal22',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(2,2)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal23',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(2,3)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal24',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(2,4)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal31',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(3,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal32',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(3,2)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal33',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(3,3)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal34',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(3,4)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal41',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(4,1)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal42',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(4,2)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal43',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(4,3)) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'P_kal44',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,P_kal(4,4)) , .true. )
!
!              call disp_err( nf90_inq_varid(ncid,'umdt',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,umdt) , .true. )
!              call disp_err( nf90_inq_varid(ncid,'vmdt',varid) , .true. )
!              call disp_err( nf90_put_var(ncid,varid,vmdt) , .true. )
!
!----------------------------    cm1.F     ---------------------------------------------
!
!   add "use autotrans_module" in the use statements right below "use azimavg_module, only : azimavg" ~ line 40
!   add the following right after "real :: xcenter,ycenter" ~ line 201
!
!              logical :: restarted_autotrans
!              real, dimension(4,1) :: X_kal
!              real, dimension(4,4) :: P_kal
!              real :: umdt,vmdt
!
!   add "restarted_autotrans = .false." right after "restarted = .false." near line 265 ish
!   add "restarted_autotrans = .true." right above the read_restart() call near line 1763
!   add the arguments "X_kal, P_kal, umdt, vmdt" in the read_restart() call near line 1791ish
!   add "restarted_autotrans = .false." in the else block that contains "restarted = .false." ~line 1823
!   add the arguments "restarted_autotrans,X_kal, P_kal, umdt, vmdt" in the solve() call near line 2165ish
!   add the arguments "X_kal, P_kal, umdt, vmdt" in the writeout() call near line 2449ish
!   add the arguments "X_kal, P_kal, umdt, vmdt" in the write_restart() call near line 2722ish

!-------------------------       Makefile       -------------------------------
!
!   add the following lines near the top of the Makefile to correctly point to FFTW
!
!                FFTWINC = -I$(FFTW_ROOT)/include # location of include files for fftw
!                FFTWLIB = -L$(FFTW_ROOT)/lib # location of libraries for fftw
!
!   change the "LINKOPTS" variable to "LINKOPTS  = -lnetcdff -lnetcdf -lfftw3"
!
!   add "autotrans.F \" after "anelp.F \" in the "SRC" variable ~ line 116
!
!   change the cm1: compile call near line 199 to include the following (adds the FFTW flags):
!          $(FC) $(OBJS) $(FFLAGS) $(OUTPUTINC) $(FFTWINC) $(OUTPUTLIB) $(FFTWLIB) $(LINKOPTS) -o ../run/cm1.exe
!
!   likewise change the .F.o: compile call near line 204 to include the following (adds the FFTW flags):
!          $(FC) $(FFLAGS) $(OUTPUTINC) $(FFTWINC) -c $*.f90
!
!
!*********    NOTE     ***************
!   using the autotrans module requires the use of the FFTW library if using gaussian filtering for UH identification
!   The FFTW library (short for the fastest fourier transform in the west, fftw.org) is a common library on many supercomputers
!   FFTW can either be installed from fftw.org, or loaded in using LMOD or spack.
!*************************************
!
!-------------------------      namelist.input      ------------------------------
!
!   add "automove=1," in param2, directly after imove
!
!-----------------------------------------------------------------------------------

use, intrinsic :: iso_fortran_env, only: error_unit

implicit none

private

public autotrans
!  public gaussian_krnl
!  public convolve
!  public assert
!  public tile_and_reflect

CONTAINS

  !ASCHUETH, fortran implementation of my python centering code based on smoothed UH

  subroutine autotrans(uf,vf,zh,zf, &
                       ug,vg,u0,ua,u3d,v0,va,v3d,wa, &
                       dum2,dum5,dum6,zs,rgzu,rgzv,rds,sigma, &
                       rdsf,sigmaf,dat1,dat2,dat3,reqt, &
                       xfref,yfref,dt,mtime,nstep,restarted_autotrans,X_kal,P_kal,umdt,vmdt)

  use misclibs
  use input
  use constants
  !use gaussian_filter, only: gaussian_krnl, convolve

#ifdef MPI
  use mpi
#endif


  implicit none

  include 'fftw3.f'

!umove, vmove, dx, dy ostensibly are globally declared
  real, intent(in), dimension(ib:ie+1) :: uf
  real, intent(in), dimension(jb:je+1) :: vf
  real, intent(in), dimension(ib:ie,jb:je,kb:ke) :: zh
  real, intent(in), dimension(ib:ie,jb:je,kb:ke+1) :: zf
  real, intent(inout), dimension(ib:ie+1,jb:je,kb:ke) :: u0,ua,u3d
  real, intent(inout), dimension(ib:ie,jb:je+1,kb:ke) :: v0,va,v3d
  real, intent(inout), dimension(kb:ke) :: ug,vg
  real, intent(in), dimension(ib:ie,jb:je,kb:ke+1) :: wa
  real, intent(inout), dimension(ib:ie,jb:je,kb:ke) :: dum2,dum5,dum6
  real, intent(in), dimension(ib:ie,jb:je) :: zs
  real, intent(in), dimension(itb:ite,jtb:jte) :: rgzu,rgzv
  real, intent(in), dimension(kb:ke) :: rds,sigma
  real, intent(in), dimension(kb:ke+1) :: rdsf,sigmaf
  real, intent(inout), dimension(ni+1,nj+1) :: dat1
  real, intent(inout), dimension(d2i,d2j) :: dat2
  real, intent(inout), dimension(d3i,d3j,0:d3n-1) :: dat3 ! JESSMCDO changed d3n to 0:d3n-1
  integer, intent(inout), dimension(d3t) :: reqt
  real, intent(in), dimension(1-ngxy:nx+ngxy+1) :: xfref
  real, intent(in), dimension(1-ngxy:ny+ngxy+1) :: yfref
  real, intent(in) :: dt
  double precision, intent(in) :: mtime
  integer, intent(in) :: nstep
  logical, intent(inout) :: restarted_autotrans
  integer :: i,j,k

  real, dimension(ib:ie,jb:je) :: uhel
  real, allocatable :: flat(:)
  double precision, dimension(nx,ny) :: fixgrid, uhelsmth, krnl
  double precision, dimension(nx*ny) :: flattened_array
  real :: sigma_gauss, truncate
  integer :: i_idx, j_idx
  real :: uh_max,smth_thresh
  real :: WxCi, WxCj, Weights, wci, wcj, wcx, wcy
  integer :: in1, ip1, jn1, jp1
  double complex,dimension(nx/2+1,ny) :: fourier_data,convolved_DK !have to be the same size in order to be multiplied
  double complex, allocatable, save :: fourier_krnl(:,:)
  integer*8,save :: plandatar2c,plandatac2r, plankrnlr2c


  integer, save :: early_nstep
  logical :: missing_obs
  real, save :: sigv
  real, intent(inout) :: umdt,vmdt
  real, save :: umdt_save,vmdt_save
  real, save, dimension(4,4) :: Q_kalman,I_kalman,A_kalman
  real, intent(inout), dimension(4,4) :: P_kal
  real, save, dimension(4,4) :: P_kalman
  real, save, dimension(2,4) :: H_kalman
  real, save, dimension(4,2) :: K_kalman
  real, save, dimension(2,2) :: S_kalman,S_kalman_inv,R_kalman
  real, intent(inout), dimension(4,1) :: X_kal
  real, save, dimension(4,1) :: X_kalman
  real, save, dimension(2,1) :: Z_kalman

  if ((mtime .eq. 0.d0) .OR. (restarted_autotrans)) then

    call dfftw_plan_dft_r2c_2d(plandatar2c,nx,ny,fixgrid,fourier_data,FFTW_ESTIMATE)!plan for fourier trasform of data
    call dfftw_plan_dft_c2r_2d(plandatac2r,nx,ny,convolved_DK,uhelsmth,FFTW_ESTIMATE)!plan for inverse fourier trasform of data
    call dfftw_plan_dft_r2c_2d(plankrnlr2c,nx,ny,krnl,fourier_krnl,FFTW_ESTIMATE)

    !create gaussian krnl the size of the domain
    allocate(fourier_krnl(nx/2+1,ny))
    sigma_gauss = INT(5000/dx)
    truncate = 4
    call gaussian_krnl(sigma_gauss, krnl, truncate)
    call dfftw_execute_dft_r2c(plankrnlr2c,krnl,fourier_krnl)

    umdt_save=0
    vmdt_save=0

    sigv = (7e-5)**2

    H_kalman(1,1)=1
    H_kalman(1,2)=0
    H_kalman(1,3)=0
    H_kalman(1,4)=0
    H_kalman(2,1)=0
    H_kalman(2,2)=1
    H_kalman(2,3)=0
    H_kalman(2,4)=0

    !These initial values on the diagonal only matter at the beginning and their impact is small
    P_kalman(1,1)=0
    P_kalman(1,2)=0
    P_kalman(1,3)=0
    P_kalman(1,4)=0
    P_kalman(2,1)=0
    P_kalman(2,2)=0
    P_kalman(2,3)=0
    P_kalman(2,4)=0
    P_kalman(3,1)=0
    P_kalman(3,2)=0
    P_kalman(3,3)=0
    P_kalman(3,4)=0
    P_kalman(4,1)=0
    P_kalman(4,2)=0
    P_kalman(4,3)=0
    P_kalman(4,4)=0

    R_kalman(1,1)=1e3
    R_kalman(1,2)=0
    R_kalman(2,1)=0
    R_kalman(2,2)=1e3

    I_kalman(1,1)=1
    I_kalman(1,2)=0
    I_kalman(1,3)=0
    I_kalman(1,4)=0
    I_kalman(2,1)=0
    I_kalman(2,2)=1
    I_kalman(2,3)=0
    I_kalman(2,4)=0
    I_kalman(3,1)=0
    I_kalman(3,2)=0
    I_kalman(3,3)=1
    I_kalman(3,4)=0
    I_kalman(4,1)=0
    I_kalman(4,2)=0
    I_kalman(4,3)=0
    I_kalman(4,4)=1

    X_kalman(1,1)=0
    X_kalman(2,1)=0
    X_kalman(3,1)=0
    X_kalman(4,1)=0

  endif
  if( restarted_autotrans )then
    if (myid.eq.0) print *, 'restarted_autotrans at time', mtime
    if (myid.eq.0) print *, 'X_kalman from restart', X_kal
    if (myid.eq.0) print *, 'P_kalman from restart', P_kal
    if (myid.eq.0) print *, 'umdt from restart', umdt
    if (myid.eq.0) print *, 'vmdt from restart', vmdt
    if (myid.eq.0) print *, 'umove and vmove at restart', umove,vmove

    X_kalman = X_kal
    P_kalman = P_kal
    umdt_save = umdt
    vmdt_save = vmdt
    restarted_autotrans = .false.
    umove = X_kal(3,1)
    vmove = X_kal(4,1)
  endif

  ! sigma defined in param.F, make sure to call this after that
  call calcuh(uf,vf,zh,zf,ua,va,wa,uhel,dum2,dum5,dum6, &
              zs,rgzu,rgzv,rds,sigma,rdsf,sigmaf)

  call gather(uhel(ib,jb),dat1(1,1),dat2(1,1),dat3(1,1,0),reqt)

  if( myid.eq.0)then

    ! This bit is kinda magic, takes the jumbled grid, flattens it, and then stacks nx sized arrays on top of each other to ny
    flat = pack(dat2, .true.)
    do j=1, ny
      fixgrid(:,j)=flat((nx*(j-1)+1):(nx*j+1)) !1 based bullshit
    enddo

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !This convolves a guassian krnl (defined above) with the raw UH field
    !fourier transform fixgrid (UH field)
    call dfftw_execute_dft_r2c(plandatar2c,fixgrid,fourier_data)

    !convolve the krnl and the data (convolution theorem)
    convolved_DK = fourier_data * fourier_krnl

    !apply FFT shift
    do i=1,nx/2+1
      do j=1,ny
        convolved_DK(i,j) = convolved_DK(i,j)*(-1)**(i+j)
      enddo
    enddo

    !inverse fourier transform back to normal space
    call dfftw_execute_dft_c2r(plandatac2r,convolved_DK,uhelsmth)

    uhelsmth = uhelsmth/(nx*ny) ! normalize data


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !This calculates the weighted centroid of UH > 10 m2/s2

    WxCi = 0 !float
    WxCj = 0 !float
    Weights = 0 !float

    !Loop through all points, but exclude those outside a 20x20 km box around the center.
    !If UH is greater than the threshold, then include that in the weighted centering algorithm.
    !Use the quicksort alogrithm to sort the smoothed helicity values, the find the 99.75
    !percentile value to use as the threshold. 99.75% corresponds to ~10 m2/s2 in the raw field.

    flattened_array = pack(uhelsmth,.true.)
    call quicksort(flattened_array)
    smth_thresh = flattened_array(INT(0.9975*nx*ny))
    do i=1,nx
        do j=1,ny
            IF( (xfref(i)>-20000).AND.(xfref(i)<20000)) THEN
                IF( (yfref(j)>-20000).AND.(yfref(j)<20000)) THEN
                    IF( uhelsmth(i,j) >= (smth_thresh)) THEN !was 10 for absolute magnitude
                        WxCi = WxCi + (uhelsmth(i,j)*i)
                        WxCj = WxCj + (uhelsmth(i,j)*j)
                        Weights = Weights + uhelsmth(i,j)
                    ENDIF
                ENDIF
            ENDIF
        enddo
    enddo

    !If there is no UH greater than threshold, then set the weighted index to be the center of the domain
    IF((WxCi.eq.0).AND.(Weights.eq.0)) THEN
      missing_obs = .true.
      wci = nx/2
      wcj = ny/2
    ELSE
      missing_obs = .false.
      wci = WxCi/Weights !float
      wcj = WxCj/Weights !float
    ENDIF

    !xfref and yfref are weird, so add 1 to the calculated index
    wci = wci+1
    wcj = wcj+1

    !This section interpolates the float index to a float x-value and y-value
    ip1 = CEILING(wci) !int
    in1 = FLOOR(wci) !int
    IF (ip1.eq.in1) THEN
      wcx = xfref(ip1)
    ELSE
      wcx = xfref(in1) + (wci-in1)*((xfref(ip1)-xfref(in1))/(ip1-in1)) !float
    ENDIF

    jp1 = CEILING(wcj) !int
    jn1 = FLOOR(wcj) !int
    IF (jp1.eq.jn1) THEN
      wcy = yfref(jp1)
    ELSE
      wcy = yfref(jn1) + (wcj-jn1)*((yfref(jp1)-yfref(jn1))/(jp1-jn1)) !float
    ENDIF

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !added umdt to get storm position relative to a stationary frame of reference
    Z_kalman(1,1)=wcx+umdt_save
    Z_kalman(2,1)=wcy+vmdt_save
  endif !myid = 0

#ifdef MPI
call MPI_BCAST(Z_kalman,2,MPI_REAL,0,MPI_COMM_WORLD,ierr)! send observations to all processes
call MPI_BCAST(missing_obs,1,MPI_REAL,0,MPI_COMM_WORLD,ierr)! send observations to all processes
#endif

   if (mtime.le.60)then !initialize position based on the first 60 s of UHcenter
     X_kalman(1,1)=Z_kalman(1,1)
     X_kalman(2,1)=Z_kalman(2,1)
     X_kalman(3,1)=0
     X_kalman(4,1)=0
   endif

  Q_kalman(1,1)=sigv*((dt**2)/3)
  Q_kalman(1,2)=0
  Q_kalman(1,3)=sigv*((dt)/2)
  Q_kalman(1,4)=0
  Q_kalman(2,1)=0
  Q_kalman(2,2)=sigv*((dt**2)/3)
  Q_kalman(2,3)=0
  Q_kalman(2,4)=sigv*((dt)/2)
  Q_kalman(3,1)=sigv*((dt)/2)
  Q_kalman(3,2)=0
  Q_kalman(3,3)=sigv
  Q_kalman(3,4)=0
  Q_kalman(4,1)=0
  Q_kalman(4,2)=sigv*((dt)/2)
  Q_kalman(4,3)=0
  Q_kalman(4,4)=sigv


  A_kalman(1,1)=1
  A_kalman(1,2)=0
  A_kalman(1,3)=dt
  A_kalman(1,4)=0
  A_kalman(2,1)=0
  A_kalman(2,2)=1
  A_kalman(2,3)=0
  A_kalman(2,4)=dt
  A_kalman(3,1)=0
  A_kalman(3,2)=0
  A_kalman(3,3)=1
  A_kalman(3,4)=0
  A_kalman(4,1)=0
  A_kalman(4,2)=0
  A_kalman(4,3)=0
  A_kalman(4,4)=1

  X_kalman = MATMUL(A_kalman,X_kalman)

  if (myid.eq.0) print *, 'prior x:',X_kalman(1,1)
  if (myid.eq.0) print *, 'prior u:',X_kalman(3,1)
  if (myid.eq.0) print *, 'prior y:',X_kalman(2,1)
  if (myid.eq.0) print *, 'prior v:',X_kalman(4,1)

  if (myid.eq.0) print *,'Zx: ',Z_kalman(1,1)
  if (myid.eq.0) print *,'Zy: ',Z_kalman(2,1)

  P_kalman = MATMUL(MATMUL(A_kalman,P_kalman),TRANSPOSE(A_kalman))+Q_kalman

  S_kalman = MATMUL(MATMUL(H_kalman,P_kalman),TRANSPOSE(H_kalman))+R_kalman

  !long hand of a 2x2 matix inversion
  S_kalman_inv(1,1) = S_kalman(2,2)
  S_kalman_inv(1,2) = -S_kalman(2,1)
  S_kalman_inv(2,1) = -S_kalman(1,2)
  S_kalman_inv(2,2) = S_kalman(1,1)
  S_kalman_inv = (1/((S_kalman(1,1)*S_kalman(2,2))-(S_kalman(2,1)*S_kalman(1,2))))*S_kalman_inv

  K_kalman = MATMUL(MATMUL(P_kalman,TRANSPOSE(H_kalman)),S_kalman_inv)

  P_kalman = MATMUL((I_kalman - MATMUL(K_kalman,H_kalman)),P_kalman)

  X_kalman = MATMUL(K_kalman,(Z_kalman-MATMUL(H_kalman,X_kalman))) + X_kalman

  if (myid.eq.0) print *,'P_kalman: ',P_kalman

  if (myid.eq.0) print *, 'posterior x:',X_kalman(1,1)
  if (myid.eq.0) print *, 'posterior u:',X_kalman(3,1)
  if (myid.eq.0) print *, 'posterior y:',X_kalman(2,1)
  if (myid.eq.0) print *, 'posterior v:',X_kalman(4,1)

  umdt_save = umdt_save + X_kalman(3,1)*dt
  vmdt_save = vmdt_save + X_kalman(4,1)*dt

  if (myid.eq.0) print *,'umdt: ',umdt_save
  if (myid.eq.0) print *,'vmdt: ',vmdt_save

  ! add umdt and vmdt to Z to recover stationary storm position
  !the umove calculated will be the stationary-relative storm motion, so I have to do umove (from previous timestep) - X_kalman(3,1) (which is the umove at the current time step)
  do k=1,nk
    do j=jb,je
      do i=ib,ie+1
        u0(i,j,k) = u0(i,j,k) + (umove - X_kalman(3,1))
        ua(i,j,k) = ua(i,j,k) + (umove - X_kalman(3,1))
        u3d(i,j,k) = u3d(i,j,k) + (umove - X_kalman(3,1))
      enddo
    enddo
    do j=jb,je+1
      do i=ib,ie
        v0(i,j,k) = v0(i,j,k) + (vmove - X_kalman(4,1))
        va(i,j,k) = va(i,j,k) + (vmove - X_kalman(4,1))
        v3d(i,j,k) = v3d(i,j,k) + (vmove - X_kalman(4,1))
      enddo
    enddo
    ug(k) = ug(k) + (umove - X_kalman(3,1))
    vg(k) = vg(k) + (vmove - X_kalman(4,1))
  enddo

  umove = X_kalman(3,1)
  vmove = X_kalman(4,1)
  if (myid.eq.0) print *,'umove,vmove: ',umove,vmove

  X_kal = X_kalman
  P_kal = P_kalman
  umdt = umdt_save
  vmdt = vmdt_save

  end subroutine autotrans

!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


  subroutine gather(var,dat1,dat2,dat3,reqt)
  use input
#ifdef MPI
  use mpi
#endif
  implicit none

  real, intent(in), dimension(ib:ie,jb:je) :: var
  real, intent(inout), dimension(ni,nj) :: dat1
  real, intent(inout), dimension(nx,ny) :: dat2
  real, intent(inout), dimension(ni,nj,0:d3n-1) :: dat3
  integer, intent(inout), dimension(d3t) :: reqt

  !----

  integer :: i,j
#ifdef MPI
  integer :: fooi,fooj,nn,nnn,n1,n2,ntot,index2
  integer :: index,tag,proc,reqs,msk
#endif

  !-------------------------------------------------------------------
  ! This subroutine collects data (from other processors if this is a
  ! MPI run)
  !-------------------------------------------------------------------

#ifdef MPI
  msk = 0
  tag = 1111
#endif

#ifndef MPI
    !-------------------- non-MPI section --------------------!
!$omp parallel do default(shared)   &
!$omp private(i,j)
    do j=1,nj
    do i=1,ni
      dat2(i,j)=var(i,j)
    enddo
    enddo
#else
    !-------------------- MPI section --------------------!

    IF(myid.ne.nodemaster)THEN
      ! ordinary processor ... send data to nodemaster:
!$omp parallel do default(shared)   &
!$omp private(i,j)
      do j=1,nj
      do i=1,ni
        dat1(i,j)=var(i,j)
      enddo
      enddo
      call MPI_ISEND(dat1(1,1),ni*nj,MPI_REAL,nodemaster,tag,MPI_COMM_WORLD,reqs,ierr)
      call MPI_WAIT(reqs,MPI_STATUS_IGNORE,ierr)
      ! DONE, ordinary processors
    ELSE
      ! begin nodemaster section:
        ! start receives from all other processors on a node:
        do proc=myid+1,myid+(ppnode-1)
          call MPI_IRECV(dat3(1,1,proc),ni*nj,MPI_REAL,proc,tag,MPI_COMM_WORLD,reqt(proc-myid),ierr)
        enddo
      IF(myid.ne.msk)THEN
        ! nodemaster, not proc msk:
!$omp parallel do default(shared)  &
!$omp private(i,j)
        do j=1,nj
        do i=1,ni
          dat3(i,j,myid)=var(i,j)
        enddo
        enddo
        ! wait for receives to finish:
        call mpi_waitall(ppnode-1,reqt(1:ppnode-1),MPI_STATUSES_IGNORE,ierr)
        ! send data to processor msk:
        call MPI_ISEND(dat3(1,1,myid),ni*nj*ppnode,MPI_REAL,msk,tag+1,MPI_COMM_WORLD,reqs,ierr)
        ! wait for send to finish:
        call MPI_WAIT(reqs,MPI_STATUS_IGNORE,ierr)
        ! DONE, nodemaster (not proc msk)
      ELSE
        ! proc msk:
          ! start receives from other nodemasters:
          do nn = 1,(nodes-1)
            if( nn.le.mynode )then
              proc = (nn-1)*ppnode
            else
              proc = nn*ppnode
            endif
            call MPI_IRECV(dat3(1,1,proc),ni*nj*ppnode,MPI_REAL,proc,tag+1,MPI_COMM_WORLD,reqt(ppnode-1+nn),ierr)
          enddo
        ! my data:
        if( myid.eq.0 )then
!$omp parallel do default(shared)  &
!$omp private(i,j)
          do j=1,nj
          do i=1,ni
            dat2(i,j)=var(i,j)
          enddo
          enddo
        else
          fooj = myid / nodex + 1
          fooi = myid - (fooj-1)*nodex  + 1
          fooi = (fooi-1)*ni
          fooj = (fooj-1)*nj
!$omp parallel do default(shared)  &
!$omp private(i,j)
          do j=1,nj
          do i=1,ni
            dat2(fooi+i,fooj+j)=var(i,j)
          enddo
          enddo
        endif
        ! wait for data to arrive:
        ntot = ppnode-1 + nodes-1
        do nn=1,ntot
          call mpi_waitany(ntot,reqt(1:ntot),index,MPI_STATUS_IGNORE,ierr)
          if( index.le.(ppnode-1) )then
            ! data from ordinary procs on node:
            proc = myid+index
            fooj = proc / nodex + 1
            fooi = proc - (fooj-1)*nodex  + 1
            fooi = (fooi-1)*ni
            fooj = (fooj-1)*nj
!$omp parallel do default(shared)  &
!$omp private(i,j)
            do j=1,nj
            do i=1,ni
              dat2(fooi+i,fooj+j) = dat3(i,j,proc)
            enddo
            enddo
          else
            ! data from other nodemasters:
            index2 = index-(ppnode-1)
            if( index2.le.mynode )then
              index2 = index2-1
            endif
            n1 = index2*ppnode
            n2 = (index2+1)*ppnode-1
            do nnn = n1,n2
              proc = nnn
              fooj = proc / nodex + 1
              fooi = proc - (fooj-1)*nodex  + 1
              fooi = (fooi-1)*ni
              fooj = (fooj-1)*nj
!$omp parallel do default(shared)  &
!$omp private(i,j)
              do j=1,nj
              do i=1,ni
                dat2(fooi+i,fooj+j) = dat3(i,j,proc)
              enddo
              enddo
            enddo
          endif
        enddo
        ! DONE, proc 0
      ENDIF
      !-------------------- end MPI section --------------------!
    ENDIF
    ! seems to help with memory:
    call MPI_BARRIER (MPI_COMM_WORLD,ierr)
#endif


    end subroutine gather


!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

! This is a copy of code found in gaussian_filter.py. These two implementations
! must remain equivalent for tests to pass.
subroutine gaussian_krnl(sigma_gauss, krnl, truncate)

    use misclibs
    use input
    use constants

    real, intent(in) :: sigma_gauss
    double precision, intent(inout), dimension(nx,ny):: krnl
    real, intent(in), optional :: truncate

    integer :: radius, trunc, i, j

    if (present(truncate)) then
        trunc = truncate
    else
        trunc = 4.0
    endif

    radius = int(trunc * sigma_gauss + 0.5)

    do i = 1,nx
      do j = 1,ny
        if ((ABS(i-int(nx/2))<=radius).AND.(ABS(j-int(ny/2))<=radius)) then
          krnl(i,j)=exp(-0.5 * ((i-int(nx/2))**2 + (j-int(ny/2))**2) / sigma_gauss**2)
        else
          krnl(i,j) = 0.0
        endif
      enddo
    enddo

    krnl = krnl / sum(krnl)

end subroutine gaussian_krnl

!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

! This is a copy of code found at https://www.mjr19.org.uk/IT/sorts/sorts.f90

recursive subroutine quicksort(array)
  integer, parameter :: prec=kind(1d0), i64=selected_int_kind(15)
  real(prec), intent(inout)::array(:)
  real(prec) :: temp,pivot
  integer :: i,j,last,left,right

  last=size(array)

  if (last.lt.50) then ! use insertion sort on small arrays
     do i=2,last
        temp=array(i)
        do j=i-1,1,-1
           if (array(j).le.temp) exit
           array(j+1)=array(j)
        enddo
        array(j+1)=temp
     enddo
     return
  endif
  ! find median of three pivot
  ! and place sentinels at first and last elements
  temp=array(last/2)
  array(last/2)=array(2)
  if (temp.gt.array(last)) then
     array(2)=array(last)
     array(last)=temp
  else
     array(2)=temp
  endif
  if (array(1).gt.array(last)) then
     temp=array(1)
     array(1)=array(last)
     array(last)=temp
  endif
  if (array(1).gt.array(2)) then
     temp=array(1)
     array(1)=array(2)
     array(2)=temp
  endif
  pivot=array(2)

  left=3
  right=last-1
  do
     do while(array(left).lt.pivot)
        left=left+1
     enddo
     do while(array(right).gt.pivot)
        right=right-1
     enddo
     if (left.ge.right) exit
     temp=array(left)
     array(left)=array(right)
     array(right)=temp
     left=left+1
     right=right-1
  enddo
  if (left.eq.right) left=left+1
  call quicksort(array(1:left-1))
  call quicksort(array(left:))

end subroutine quicksort



END MODULE autotrans_module
