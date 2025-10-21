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

if(WIN32)  # Windows
    set(CPACK_GENERATOR "WIX")
    set(CPACK_SOURCE_GENERATOR "WIX")
    set(CPACK_WIX_VERSION 4)
    set(CPACK_WIX_UPGRADE_GUID "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    # set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/icon.ico")
    set(CPACK_WIX_PROGRAM_MENU_FOLDER "Doom C++")
    set(CPACK_WIX_PROPERTY_ARPHELPLINK "https://github.com/yourusername/doom-cpp/issues")
    set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "https://github.com/yourusername/doom-cpp/blob/main/README.md")
    set(CPACK_WIX_PROPERTY_ARPURLUPDATEINFO "https://github.com/yourusername/doom-cpp/releases")
else()  # Linux
    set(CPACK_GENERATOR "TGZ;DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Your Name")
    set(CPACK_PACKAGE_CONTACT "your.email@example.com")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27), freeglut3, libgl1, libglu1-mesa")
endif()

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")
set(CPACK_PACKAGE_VENDOR "Your Name")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A Doom-style 3D game engine written in C++ with OpenGL")

include(CPack)

# Install target
install(TARGETS doom-cpp DESTINATION bin)