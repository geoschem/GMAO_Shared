esma_set_this ()
string (REPLACE GMAO_gfio_ "" precision ${this})


set (srcs
  gfio.f
  gfioCF.F
  diffdate.f
  getdate.f
  timesubs.f
  gfioutil.f
  m_GFIO_GetFld.f
  m_GFIO_PutFld.f
  )

set_source_files_properties (gfio.f PROPERTIES COMPILE_FLAGS ${PP})
set_source_files_properties (gfioutil.f PROPERTIES COMPILE_FLAGS ${PP})
set_source_files_properties (m_GFIO_PutFld.f PROPERTIES COMPILE_FLAGS ${PP})


# Need to build r4 and r8 versions.  See details at bottom
esma_add_library (${this} SRCS ${srcs} DEPENDENCIES GMAO_mpeu)
set_property(TARGET ${this} PROPERTY POSITION_INDEPENDENT_CODE ON)

if (EXTENDED_SOURCE)
  set_target_properties (${this} PROPERTIES COMPILE_FLAGS ${EXTENDED_SOURCE})
endif()
set_target_properties (${this} PROPERTIES Fortran_MODULE_DIRECTORY ${include_${this}})
target_link_libraries (${this} PUBLIC ${ESMF_LIBRARIES})
target_include_directories (${this} PUBLIC ${INC_ESMF})
target_include_directories (${this} PUBLIC ${INC_NETCDF})
  
# Specs for r8 version
if (precision STREQUAL "r8")
  string(REPLACE " " ";" tmp ${FREAL8})
  foreach(flag ${tmp})
     target_compile_options (${this} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:${flag}>)
  endforeach()
  # Create a softlink (_r8 is default for gfio)
  add_custom_target (link_target ALL
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${this} GMAO_gfio
    WORKING_DIRECTORY ${esma_include}
    )
  add_dependencies (${this} link_target)
endif ()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories (${BASEDIR}/lib)
include_directories (${include_${this}})
include_directories (${INC_NETCDF})
include_directories (${NETCDF_F77_INCLUDE_DIR})

if (F2PY_FOUND)
   if (precision STREQUAL "r4")
   add_f2py_module(GFIO_ SOURCES GFIO_py.F90
      DESTINATION lib/Python
      ONLY gfioopen gfiocreate gfiodiminquire gfioinquire
      gfiogetvar gfiogetvart gfioputvar gfiogetbegdatetime
      gfiointerpxy gfiointerpnn gfiocoordnn gfioclose
      LIBRARIES GMAO_gfio_r4 ${NETCDF_LIBRARIES}
      INCLUDEDIRS ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_BINARY_DIR}/lib ${BASEDIR}/lib ${include_${this}} ${INC_NETCDF}
      USE_MPI
      )
   add_dependencies(GFIO_ ${this})
   endif ()
endif (F2PY_FOUND)

ecbuild_add_executable(TARGET GFIO_mean_${precision}.x SOURCES GFIO_mean.f90 LIBS GMAO_gfio_${precision} )

install(
   PROGRAMS gfio.py
   DESTINATION lib/Python
   )
