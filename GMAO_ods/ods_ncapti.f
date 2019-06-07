

*...................................................................


      subroutine ODS_NCAPTI ( ncid,   varid,
     .                        AttNam, AtType, AttLen,
     .                        values, ierr )

      implicit NONE

!-------------------------------------------------------------------------
!         NASA/GSFC, Data Assimilation Office, Code 910.3, GEOS/DAS      !
!-------------------------------------------------------------------------
!
! !ROUTINE:  ODS_NCAPTI
! 
! !DESCRIPTION: 
!     This routine calls the NetCDF routine, NCAPT, to 
!     create or chcange the NetCDF attribute values for a
!     user specified  variable id and attribute name.  The
!     attribute values are return as native integers.
!     This routine was design to create/change a limited
!     number of values as specified by the variable,
!     Max_WorkSp defined in the header file, ods_worksp.h
!
! !INTERFACE:  ODS_NCAPTI ( ncid,   varid,
!                                  AttNam, AtType, AttLen,
!                                  values, ierr )
!
! !INPUT PARAMETERS:
      integer            ncid          ! NetCDF file id
      integer            varid         ! NetCDF variable id
      character * ( * )  AttNam        ! Name of attribute values
      integer            AtType        ! NetCDF data type
      integer            AttLen        ! Number of attribute values
      integer            values  ( * ) ! Attribute values
!
! !OUTPUT PARAMETER:
      integer            ierr          ! Returned error code
!
!     NOTE: This routine does perform checks to verify whether
!     the range of values on input is consistent with the
!     internal variable type in the file. For example, an
!     integer variable here could be stored as a two byte integer
!     variable on file.  Therefore, all elements in the array
!     to be stored as two byte integers should have values
!     between -32,767 and 32,767.  Be careful.  If the software
!     does detect a number inconsistent with the variable type,
!     then the routine returns with an error message without
!     saving at least some of the values.  This check prevents
!     overflows from occurring which would produce unexpected
!     results and probable abnormal program termination.  The 
!     range of values for the internal variable types are as
!     follows:
!
!       type                      minimum value    maximum value
!       ----                      -------------    -------------
!       byte                               -128              255
!       short (2 byte) integer          -32,767          -32,767
!       long  (4 byte) integer   -2,147,483,643    2,147,483,643
!       real  (4 bytes )               -3.40e38          3.40e38
!
!     This routine treats each byte as unsigned integers
!     with values within the range from 0 to 255, inclusively.
!     An offset value of 256 is added to any negative value.
!
! !FILES USED:
!     netcdf.inc, a header file, for defining NetCDF library 
!            parameters
!     ods_stdio.h, a header file, for defining standard input/output
!            unit numbers
!     ods_worksp.h, a header file, for defining hardwired constants
!            and defining global variables and setting up data
!            structures for work space
!
! !LIBRARIES ACCESSED:
!     NetCDF
!
! !REVISION HISTORY: 
!     05Jun1996   C. Redder   Origional version
!     16Feb2000   R. Todling  Rename stdio.h to ods_stdio.h
!     13Sep2002   C. Redder   Changes made to handle one-byte integers
!                             stored in a long character string 
!     27Feb2009   D. Nadeau   Fixed variable type mismatch (char/int1)
!
!-------------------------------------------------------------------------

      include 'netcdf.inc'
      include 'ods_stdio.h'
      include 'ods_worksp.h'

*     one more than the maximum value for
*     any integer in unsigned byte format
*     -----------------------------------
      integer            I1Max
      parameter        ( I1Max      = 256 )

*     scratch space for ...
*     ----------------------
      integer            itemp   ! native integers
      real               rtemp   ! native real numbers

*     Other variables
*     ---------------
      integer            iAtt    ! index variable for do loop

*     Default value for error code
*     ----------------------------
      ierr    = NCNoErr

*     If the number of attribute values is too large ( i.e. insuf-
*     ficient scatch space), then print message and return
*     ------------------------------------------------------------
      if ( AttLen .gt. Max_WorkSp ) then

         write ( stderr, 901 ) AttLen
         ierr = NCSysErr
         return

      end if

*     Check the the attribute values to determine
*     if the values are within the range of the
*     NetCDF variable type
*     ---------------------------------------------

*     one byte integers
*     -----------------
      if      ( AtType .eq. NCByte  ) then

         do 10, iAtt = 1, AttLen
            itemp    =        values ( iAtt )
            if ( itemp .lt. I1_Min .or.
     .           itemp .gt. I1_Max ) ierr  =  NCSysErr
 10      continue

*     two byte integers
*     -----------------
      else if ( AtType .eq. NCShort ) then

         do 20, iAtt = 1, AttLen
            itemp    =        values ( iAtt )
            if ( itemp .lt. I2_Min .or.
     .           itemp .gt. I2_Max ) ierr  =  NCSysErr
 20      continue

*     four byte integers
*     ------------------
      else if ( AtType .eq. NCLong  ) then

         do 30, iAtt = 1, AttLen
            itemp    =        values ( iAtt )
            if ( itemp .lt. I4_Min .or.
     .           itemp .gt. I4_Max ) ierr  = NCSysErr
 30      continue

*     four byte real numbers
*     ----------------------
      else if ( AtType .eq. NCFloat ) then

         do 40, iAtt = 1, AttLen
            rtemp    = real ( values ( iAtt ) )
            if ( rtemp .lt. R4_Min .or.
     .           rtemp .gt. R4_Max ) ierr  = NCSysErr
 40      continue

*     Return with an error message if the attribute type
*     is not recognized as valid.
*     --------------------------------------------------
      else 

         write ( stderr, 902 )
         ierr = NCEBadTy
         return

      end if

*     Return with an error message if any value is out of range
*     ---------------------------------------------------------
      if ( ierr .ne. NCNoErr ) then
         if ( AtType .eq. NCByte  )
     .      write ( stderr, 903 ) 'NCByte',  AttNam
         if ( AtType .eq. NCShort )
     .      write ( stderr, 903 ) 'NCShort', AttNam
         if ( AtType .eq. NCLong  )
     .      write ( stderr, 903 ) 'NCLong',  AttNam
         if ( AtType .eq. NCFloat )
     .      write ( stderr, 903 ) 'NCFloat', AttNam
         return
      end if

*     Write the attribute values if the type of
*     values as stored in the NetCDF file are 
*     -----------------------------------------

*     one byte integers
*     -----------------
      if      ( AtType .eq. NCByte  ) then

         do 60, iAtt = 1, AttLen
            itemp                  =        values ( iAtt )
            I1_Val ( iAtt ) = itemp 
 60      continue

         call ncapt  ( ncid,   varid,
     .                 AttNam, AtType, AttLen,
     .                 I1_Val, ierr )

*     two byte integers
*     -----------------
      else if ( AtType .eq. NCShort ) then

         do 70, iAtt = 1, AttLen
            I2_Val ( iAtt )        =        values ( iAtt )
 70      continue

         call ncapt  ( ncid,   varid,
     .                 AttNam, AtType, AttLen,
     .                 I2_Val, ierr )

*     four byte integers
*     ------------------
      else if ( AtType .eq. NCLong  ) then

         do 80, iAtt = 1, AttLen
            I4_Val ( iAtt )        =        values ( iAtt )
 80      continue

         call ncapt  ( ncid,   varid,
     .                 AttNam, AtType, AttLen,
     .                 I4_Val, ierr )

*     four byte real numbers
*     ----------------------
      else if ( AtType .eq. NCFloat ) then

         do 90, iAtt = 1, AttLen
            R4_Val ( iAtt )        = real ( values ( iAtt ) )
 90      continue

         call ncapt  ( ncid,   varid,
     .                 AttNam, AtType, AttLen,
     .                 R4_Val, ierr )

      end if

      return
*     ------
 901  format ( /, ' ODS_NCAPTI: Attribute length exceeds the ',
     .         /, '             maximum allowed.  Increase ',
     .         /, '             Max_WorkSp to at least ', i9 )
 902  format ( /, ' ODS_NCAPTI: Not an appropriate attribute ',
     .         /, '             type for this routine. ' )
 903  format ( /, ' ODS_NCAPTI: Value to be written as the ',
     .         /, '             NetCDF attribute type ', a, ' ,',
     .         /, '             is out of range. ',
     .         /, '             Attribute name is ', a )

      end
