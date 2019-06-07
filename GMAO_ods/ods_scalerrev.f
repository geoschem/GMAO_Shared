

*...................................................................


      subroutine ODS_ScaleRRev ( ncid, varid, nval, values, ierr )

      implicit NONE

!-------------------------------------------------------------------------
!         NASA/GSFC, Data Assimilation Office, Code 910.3, GEOS/DAS      !
!-------------------------------------------------------------------------
!
! !ROUTINE:  ODS_ScaleRRev
! 
! !DESCRIPTION: 
!     This routine scales an array of real according to the
!     expression
!
!                            R - add_offset 
!              R_scaled =   ----------------
!                             scale_factor
!
!     where R and R_scaled are the unscaled and scaled real
!     numbers, respectively and scale_factor and offset are
!     parameters extracted as attributes from the NetCDF file.
!     The routine correctly handles the cases when one or
!     both of these attributes do not exist in the NetCDF file.
!
! !INTERFACE:  ODS_ScaleRRev ( ncid,   varid,
!                                      nval,   values,
!                                      ierr )
!
! !INPUT PARAMETERS:
      integer    ncid           ! NetCDF file id
      integer    varid          ! NetCDF variable id
      integer    nval           ! Number of values to scaled
!
! !INPUT/OUTPUT PARAMETERS:
      real       values ( * )   ! Values to be scaled
!
! !OUTPUT PARAMETER:
      integer    ierr           ! Returned error code
!
! !SEE ALSO:
!     ODS_ScaleIRev  ( The parallel routine for integers      )
!     ODS_ScaleR     ( The inverse companion of this routine  )
!     ODS_ScaleI     ( The inverse companion of ODS_ScaleIRev )
!
! !FILES USED:
!     netcdf.inc, a header file, for defining NetCDF library 
!            parameters
!
! !REVISION HISTORY: 
!     16May96   C. Redder   Origional version
!
!-------------------------------------------------------------------------

      include 'netcdf.inc'
      include 'ods_stdio.h'

*     Other variables
*     ---------------
      real       scale_factor   ! scale factor
      real       add_offset     ! add offset term
      integer    ierr_scale     ! ierr return code from routine
                                !   ODS_NCAGTR for scale factor
      integer    ierr_offset    ! ierr return code from routine
                                !   ODS_NCAGTR for add offset term
      integer    AttLen         ! length of attribute (= 1 for this
                                !   routine
      integer    ival           ! index variable for do loop
      integer    ncopts         ! NetCDF error handling options

*     initialize routine error return code to valid
*     ---------------------------------------------
      ierr = NCNoErr

*     Save current options of error handling and turn off
*     error messages and set errors to be non-fatal.
*     ---------------------------------------------------
      call ncgopt ( ncopts )
      call ncpopt ( 0 )

*     Get scaling factor
*     ------------------
      call ODS_NCAGTR ( ncid, varid, 'scale_factor',
     .                        AttLen, scale_factor, ierr_scale  )
      if ( ierr_scale  .ne. NCNoErr .and.
     .     ierr_scale  .ne. NCENoAtt ) then
         write ( stderr, 901 ) 'scale_factor'
         ierr = ierr_scale
         return
      end if

*     Get offset term
*     ---------------
      call ODS_NCAGTR ( ncid, varid, 'add_offset',
     .                        AttLen, add_offset,   ierr_offset )
      if ( ierr_offset .ne. NCNoErr .and.
     .     ierr_offset .ne. NCENoAtt ) then
         write ( stderr, 901 ) 'add_offset'
         ierr = ierr_offset
         return
      end if

*     Return error handling option to their previous values
*     -----------------------------------------------------
      call ncpopt ( ncopts )

*     If neither attribute exists ...
*     -------------------------------
      if       ( ierr_scale  .eq. NCENoAtt  .and.
     .           ierr_offset .eq. NCENoAtt ) then

*        continue without any changes
*        ----------------------------
         continue

*     If scale factor does not exist...
*     ---------------------------------
      else if  ( ierr_scale  .eq. NCENoAtt  .and.
     .           ierr_offset .eq. NCNoErr  ) then

*        only subtract the offset term
*        -----------------------------
         do 10, ival = 1, nval
            values ( ival )
     .         = values ( ival ) - add_offset
 10      continue

*     If the offset term does not exist ...
*     -------------------------------------
      else if  ( ierr_scale  .eq. NCNoErr   .and.
     .           ierr_offset .eq. NCENoAtt ) then

*        only divide by the scale factor
*        -------------------------------
         do 20, ival = 1, nval
            values ( ival )
     .         = values ( ival ) / scale_factor
 20      continue

*     If both attributes exist ...
*     ----------------------------
      else if  ( ierr_scale  .eq. NCNoErr   .and.
     .           ierr_offset .eq. NCNoErr  ) then

*        first subtract by the add offset and then
*        divide by the offset term
*        -----------------------------------------
         do 30, ival = 1, nval
            values ( ival )
     .         = ( values ( ival ) - add_offset )
     .                             / scale_factor
 30      continue

      end if

      return
*     ------

 901  format ( /, ' ODS_ScaleRRev: Error in extracting an ',
     .         /, '                attribute. ',
     .         /, '                Attribute name is ', a )

      end
