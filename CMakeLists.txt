cmake_minimum_required(VERSION 3.30)
project(doom-cpp VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Compiler warnings
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.h" "include/*.hpp")

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

find_package(OpenGL REQUIRED)

# Try FreeGLUT first (preferred for vcpkg on Windows), fallback to GLUT
if(WIN32)
    find_package(FreeGLUT CONFIG)
    if(FreeGLUT_FOUND)
        target_link_libraries(doom-cpp PRIVATE 
            OpenGL::GL
            OpenGL::GLU
            $<IF:$<TARGET_EXISTS:FreeGLUT::freeglut>,FreeGLUT::freeglut,FreeGLUT::freeglut_static>
        )
        
        # Search for freeglut.dll
        set(_freeglut_dll "")
        if(TARGET FreeGLUT::freeglut)
            get_target_property(_freeglut_dll FreeGLUT::freeglut IMPORTED_LOCATION_RELEASE)
            if(NOT _freeglut_dll OR NOT EXISTS "${_freeglut_dll}")
                get_target_property(_freeglut_dll FreeGLUT::freeglut LOCATION)
            endif()
        endif()
        
        # Fallback: search for DLL in common paths
        if(NOT _freeglut_dll OR NOT EXISTS "${_freeglut_dll}")
            find_file(_freeglut_dll NAMES freeglut.dll)
        endif()

        if(_freeglut_dll AND EXISTS "${_freeglut_dll}")
            message(STATUS "Bundling freeglut runtime DLL: ${_freeglut_dll}")
            install(FILES ${_freeglut_dll} DESTINATION bin OPTIONAL)
        else()
            message(WARNING "freeglut.dll was not found; installer will not include it")
        endif()
    else()
        find_package(GLUT REQUIRED)
        target_link_libraries(doom-cpp 
            ${OPENGL_LIBRARIES} 
            ${GLUT_LIBRARIES}
            GLUT::GLUT
        )
    endif()
else()
    find_package(GLUT REQUIRED)
    target_link_libraries(doom-cpp 
        ${OPENGL_LIBRARIES} 
        ${GLUT_LIBRARIES}
        GLUT::GLUT
    )
endif()

# CPack configuration for installers
include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "0")

if(WIN32)
    set(CPACK_GENERATOR "WIX")
    set(CPACK_SOURCE_GENERATOR "WIX")
    set(CPACK_WIX_VERSION 4)
    set(CPACK_WIX_UPGRADE_GUID "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    # set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/icon.ico")
    set(CPACK_WIX_PROGRAM_MENU_FOLDER "Doom Cpp")
    set(CPACK_WIX_PROPERTY_ARPHELPLINK "https://github.com/Fabulani/doom-cpp/issues")
    set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "https://github.com/Fabulani/doom-cpp/blob/main/README.md")
    set(CPACK_WIX_PROPERTY_ARPURLUPDATEINFO "https://github.com/Fabulani/doom-cpp/releases")
else()
    set(CPACK_GENERATOR "TGZ;DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Fabiano Manschein")
    set(CPACK_PACKAGE_CONTACT "https://github.com/Fabulani/doom-cpp")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27), freeglut3, libgl1, libglu1-mesa")
endif()

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")
set(CPACK_PACKAGE_VENDOR "Fabiano Manschein")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Doom in C++ with OpenGL")

include(CPack)

# Install target
install(TARGETS doom-cpp DESTINATION bin)