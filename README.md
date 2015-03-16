<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. Makes your Assimage code Heimdali compatible</a></li>
</ul>
</div>
</div>

Work in progress &#x2026;

# Makes your Assimage code Heimdali compatible<a id="sec-1" name="sec-1"></a>

1.  Add a `CMakeLists.txt` file in your source directory. This 
    file must contain:
    
        cmake_minimum_required(VERSION 2.8)
        cmake_policy(VERSION 2.8)
        
        # Adapt this line to your project
        project (SimulationAIMI)
        
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -g")
        set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -O2 -g")
        # if you have fortran source files
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2 -g")
        
        ### FIXME: this part will be summurized in a uniqu call  ###
        
        # Search for ITK.
        ## FIXME: mettre une clause sur la version minimale d'ITK
        find_package(ITK 4.8 REQUIRED)
        include(${ITK_USE_FILE})
        
        # TCLAP include
        find_path(TCLAP_INCLUDES tclap/CmdLine.h)
        
        # h5unixpipe libraries
        find_library(H5UNIXPIPE_LIBRARY NAMES h5unixpipe)
        find_library(H5UNIXPIPE_CXX_LIBRARY NAMES h5unixpipe_cxx)
        set(H5UNIXPIPE_LIBRARIES
          ${H5UNIXPIPE_LIBRARY}
          ${H5UNIXPIPE_CXX_LIBRARY}
          )
        
        # h5unixpipe include
        find_path(H5UNIXPIPE_INCLUDE h5unixpipe.h)
        
        # minimal traceback
        find_library(MINIMAL_TRACEBACK_LIBRARIES NAMES minimal_traceback)
        
        # HDF5 libraries
        find_library(HDF5_HL_CPP_LIBRARY NAMES hdf5_hl_cpp)
        find_library(HDF5_HL_LIBRARY NAMES hdf5_hl)
        find_library(HDF5_CPP_LIBRARY NAMES hdf5_cpp)
        find_library(HDF5_LIBRARY NAMES hdf5)
        set(HDF5_LIBRARIES
          ${HDF5_HL_CPP_LIBRARY}
          ${HDF5_HL_LIBRARY}
          ${HDF5_CPP_LIBRARY}
          ${HDF5_LIBRARY}
          )
        
        # INRimage include.
        find_path(INRIMAGE_INCLUDE inrimage/image.h)
        
        # INRimage library.
        find_library(INRIMAGE_LIBRARY NAMES inrimage)
        
        # INRImageIO library
        find_library(ITKINRIMAGEIO_LIBRARY NAMES itkINRImageIO)
        find_path(ITKINRIMAGEIO_INCLUDE itkINRImageIO.h)
        
        # Heimdali library
        find_library(HEIMDALI_LIBRARY heimdali)
        find_path(HEIMDALI_INCLUDE heimdali/itkhelper.hxx)
        
        
        #### End of Heimdali configuration ####
        
        
        ## Following lines are for your project. You probably
        ## edit and change to your project.
        
        # comment if we don't need to compile fortran source
        enable_language (Fortran)
        
        include_directories("../share")
        
        set (TOOL_SRCS modeleAIMI.c)
        
        add_executable(SimulationAIMI ${TOOL_SRCS} SimulationAIMI.cpp)
        target_link_libraries(SimulationAIMI ${HEIMDALI_LIBRARY} ${ITK_LIBRARIES} ${ITKINRIMAGEIO_LIBRARY} ${INRIMAGE_LIBRARY})
    
    You can now remove your `SConstruct` file.
2.  Edit your `toolsXXX.hxx` file, remplace the line :
    
        #include <Inr++.h>
    
    by:
    
        #include "heimdali/inrimage.hxx"
        #include "heimdali/itkhelper.hxx"
        using namespace Heimdali;
3.  Edit your `AssimXXX.cpp` (or `SimulationXXX.cpp`) file and comment
    the line:
    
        InitInrimage(argc, argv, (char*)"1.0", Ucmd, Udetail);
    
    FIXME: il faut garder le principe de documenter la commande.
    Donc remplacer InitInrimage() par InitHeimdali() qui se contente
    d'imprimer des choses avec -help, -version etc&#x2026;

The file `heimdali/inrimage.hxx` is an Heimdali replacement of `Inr++.h`.
So, you doesn't need to change your calls to the image library.
1.  ITK uses the filename extension to determine the image format. So change     
    strings ".inr" into ".h5" in your output filenames.

To compile your code:

    $ mkdir build; cd build
    $ source activate heim
    $ CONDA_ENV_PATH=$(conda info -e | fgrep '*' | awk '{print $3}')  
    $ cmake -DCMAKE_PREFIX_PATH=$CONDA_ENV_PATH ..
    $ make

FIXME:
modify the code in order to deal with inrimage files (in input)
