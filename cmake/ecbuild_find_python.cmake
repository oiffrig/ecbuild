# (C) Copyright 1996-2012 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# macro to find python

# OUTPUT:
#   PYTHONINTERP_FOUND
#   PYTHONLIBS_FOUND
#   PYTHON_INCLUDE_DIRS
#   PYTHON_LIBRARIES
#   PYTHON_SITE_PACKAGES


macro( ecbuild_find_python )

    # parse parameters

    set( options REQUIRED )
    set( single_value_args VERSION )
    set( multi_value_args  )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_find_python(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    # find python executable

    if( DEFINED _PAR_REQUIRED )
        list( APPEND _py_args REQUIRED )
    endif()

    find_package( PythonInterp ${_py_args} )

    # find python version
    # execute_process( COMMAND ${PYTHON_EXECUTABLE} -V ERROR_VARIABLE _version  RESULT_VARIABLE _return ERROR_STRIP_TRAILING_WHITESPACE)
    # if( NOT _return )
    #    string(REGEX REPLACE ".*([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1.\\2.\\3" PYTHON_VERSION ${_version} )
    # endif()
    # endif()

    # message( STATUS "Python version ${PYTHON_VERSION_STRING}" )
    # debug_var(PYTHON_VERSION_MAJOR)
    # debug_var(PYTHON_VERSION_MINOR)
    # debug_var(PYTHON_VERSION_PATCH)

    if( PYTHONINTERP_FOUND AND DEFINED _PAR_VERSION )
        if( _PAR_VERSION VERSION_GREATER "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH}" )
            set( PYTHONINTERP_FOUND 0 )
            set( PYTHON_EXECUTABLE "PYTHON_EXECUTABLE-NOTFOUND" )
            if( DEFINED _PAR_REQUIRED )
                message( FATAL_ERROR "Required python version at least ${_PAR_VERSION} but found only ${PYTHON_VERSION_STRING}" )
            else()
                message( SEND_ERROR "Looking for python version at least ${_PAR_VERSION} but found only ${PYTHON_VERSION_STRING}" )
            endif()
        endif()
    endif()

    if( PYTHONINTERP_FOUND )

        # find pythonn config

        if( PYTHON_EXECUTABLE AND EXISTS ${PYTHON_EXECUTABLE}-config )
            set(PYTHON_CONFIG ${PYTHON_EXECUTABLE}-config CACHE PATH "" FORCE)
        else()
            find_program( PYTHON_CONFIG NAMES python-config python-config${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} )
        endif()

        # find python libs

        # The OpenBSD python packages have python-config's 
        # that don't reliably report linking flags that will work.
        
        if( PYTHON_CONFIG AND NOT ${CMAKE_SYSTEM_NAME} STREQUAL "OpenBSD" )
            
            execute_process(COMMAND "${PYTHON_CONFIG}" --ldflags
                            OUTPUT_VARIABLE PYTHON_LIBRARIES
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_QUIET)

            execute_process(COMMAND "${PYTHON_CONFIG}" --includes
                            OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            ERROR_QUIET)

#           debug_var(PYTHON_LIBRARIES)
#           debug_var(PYTHON_INCLUDE_DIR)

            string(REGEX REPLACE "^[-I]" "" PYTHON_INCLUDE_DIR "${PYTHON_INCLUDE_DIR}")
            string(REGEX REPLACE "[ ]-I" " " PYTHON_INCLUDE_DIR "${PYTHON_INCLUDE_DIR}")
            
            separate_arguments(PYTHON_INCLUDE_DIR)

        else() # revert to finding pythonlibs the standard way (cmake macro)
            
            find_package(PythonLibs)
            if( PYTHON_INCLUDE_PATH AND NOT PYTHON_INCLUDE_DIR )
                set(PYTHON_INCLUDE_DIR "${PYTHON_INCLUDE_PATH}")
            endif()

        endif()

        # set output variables

        find_package_handle_standard_args( PythonLibs DEFAULT_MSG PYTHON_INCLUDE_DIR PYTHON_LIBRARIES )

        set( PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIR} )

        list( REMOVE_DUPLICATES PYTHON_INCLUDE_DIRS )

        # find where python site-packages are ...

        execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)

    endif()

    debug_var( PYTHONINTERP_FOUND )
    debug_var( PYTHON_EXECUTABLE )
    debug_var( PYTHONLIBS_FOUND )
    debug_var( PYTHON_INCLUDE_DIRS )
    debug_var( PYTHON_LIBRARIES )
    debug_var( PYTHON_SITE_PACKAGES )

endmacro( ecbuild_find_python )
