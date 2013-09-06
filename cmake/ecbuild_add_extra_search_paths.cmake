# (C) Copyright 1996-2012 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
#
# macro for adding search paths to CMAKE_PREFIX_PATH
# for example the ECMWF /usr/local/apps paths
#
# usage: ecbuild_search_paths( netcdf4 )

macro( ecbuild_add_extra_search_paths pkg )

    foreach( _apps /usr/local/apps/${pkg} )

         foreach( p ${_apps} ${_apps}/current ${_apps}/stable ${_apps}/new ${_apps}/next ${_apps}/prev )

           if( EXISTS ${p} )
               list( APPEND CMAKE_PREFIX_PATH ${p} )
           endif()
           if( EXISTS ${p}/LP64 )
               list( APPEND CMAKE_PREFIX_PATH ${p}/LP64 )
           endif()

         endforeach()

         file( GLOB ps ${_apps}/*)
         foreach( p ${ps} )
             if( IS_DIRECTORY ${p} )
                  list( APPEND CMAKE_PREFIX_PATH  ${p} )
                  if( EXISTS ${p}/LP64 )
                      list( APPEND CMAKE_PREFIX_PATH ${p}/LP64 )
                  endif()
             endif()
         endforeach()

    endforeach()

    list( REMOVE_DUPLICATES CMAKE_PREFIX_PATH )

endmacro()

