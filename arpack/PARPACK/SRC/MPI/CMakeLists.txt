esma_set_this (OVERRIDE parpack)

set (SRCS
  pcgetv0.f  pcnaupd.f  pdlamch.f  pdnaupd.f  pdsaitr.f  pdseupd.f   pslamch.f  psnaupd.f  pssaitr.f  psseupd.f  pznapps.f  pzngets.f
  pclarnv.f  pcneigh.f  pdlarnv.f  pdneigh.f  pdsapps.f  pdsgets.f   pslarnv.f  psneigh.f  pssapps.f  pssgets.f  pznaup2.f
  pcnaitr.f  pcneupd.f  pdnaitr.f  pdneupd.f  pdsaup2.f  pdznorm2.f  psnaitr.f  psneupd.f  pssaup2.f  pzgetv0.f  pznaupd.f
  pcnapps.f  pcngets.f  pdnapps.f  pdngets.f  pdsaupd.f  pscnorm2.f  psnapps.f  psngets.f  pssaupd.f  pzlarnv.f  pzneigh.f
  pcnaup2.f  pdgetv0.f  pdnaup2.f  pdnorm2.f  pdseigt.f  psgetv0.f   psnaup2.f  psnorm2.f  psseigt.f  pznaitr.f  pzneupd.f
  )

# This is equivalent to FOPT=$(FOPT2) in GNU Make
if (CMAKE_Fortran_COMPILER_ID MATCHES Intel)
   string (REPLACE "${FOPT3}" "${FOPT2} ${BIG_ENDIAN}" CMAKE_Fortran_FLAGS_RELEASE ${CMAKE_Fortran_FLAGS_RELEASE})
   string (REPLACE "${OPTREPORT0}" "" CMAKE_Fortran_FLAGS_RELEASE ${CMAKE_Fortran_FLAGS_RELEASE})
   string (REPLACE "${FTZ}" "" CMAKE_Fortran_FLAGS_RELEASE ${CMAKE_Fortran_FLAGS_RELEASE})
   string (REPLACE "${ALIGN_ALL}" "" CMAKE_Fortran_FLAGS_RELEASE ${CMAKE_Fortran_FLAGS_RELEASE})
   string (REPLACE "${NO_ALIAS}" "" CMAKE_Fortran_FLAGS_RELEASE ${CMAKE_Fortran_FLAGS_RELEASE})
endif ()

esma_add_library (${this}
  SRCS ${SRCS}
  )
