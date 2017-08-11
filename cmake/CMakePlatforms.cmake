cmake_minimum_required(VERSION 3.8)

# This module is shared; use include blocker.
if( _PLATFORMS_ )
	return()
endif()
set(_PLATFORMS_ 1)

include(CMakeCompiler)

# Detect target platform
if( ${CMAKE_SYSTEM_NAME} STREQUAL "Windows" )
	set(PLATFORM_WINDOWS 1)
	set(PLATFORM_NAME "windows")
	if( MSVC_VERSION GREATER 1800 )
		set(REQUIRED_WINDOWSSDK_VERSION 10.0.10586.0)
		message(STATUS "Windows SDK version found: ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}")
		if ( CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION VERSION_LESS REQUIRED_WINDOWSSDK_VERSION ) # Versions before this have serious bugs
			message(FATAL_ERROR "Unsupported Windows SDK Version, ${REQUIRED_WINDOWSSDK_VERSION} or greater required")
		endif()
	endif()
	set(PLATFORM_TOOLCHAIN_ENVIRONMENT_ONLY 1)
	include(Toolchain-XBoxOne)
	include(Toolchain-PS4)
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "WindowsStore" )
	set(PLATFORM_UWP 1)
	set(PLATFORM_NAME "uwp")
	set(UWP_VERSION_MIN ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION})
	set(UWP_VERSION_TARGET ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION})
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin" )
	if( IOS )
		set(PLATFORM_IOS 1)
		set(PLATFORM_NAME "ios")
	else()
		set(PLATFORM_OSX 1)
		set(PLATFORM_NAME "osx")
	endif()
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Linux" )
	set(PLATFORM_LINUX 1)
	set(PLATFORM_NAME "linux")
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Android" )
	set(PLATFORM_ANDROID 1)
	set(PLATFORM_NAME "android")
	set(ENGINE_ANDROID_GLES3 ON CACHE BOOL "Use OpenGL ES 3.0 for Android.")
	set(ENGINE_ANDROID_GLES3_GLSL100 OFF CACHE BOOL "Use GLSL 1.0 on OpenGL ES 3.0 for Android.")
	set(ENGINE_ANDROID_GL4 OFF CACHE BOOL "Enable OpenGL 4.0 for Android.")	# We might want to enable this. (It should work on the K1 chipset.) /aj
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Durango" )
	set(PLATFORM_XBOXONE 1)
	set(PLATFORM_NAME "xb1")
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Orbis" )
	set(PLATFORM_PS4 1)
	set(PLATFORM_NAME "ps4")
elseif( ${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten" )
	set(PLATFORM_WEB 1)
	set(PLATFORM_NAME "web")
	set(CMAKE_C_FLAGS_DEBUG "" CACHE STRING "" FORCE)
	set(CMAKE_CXX_FLAGS_DEBUG "" CACHE STRING "" FORCE)
	set(CMAKE_C_FLAGS_DEV "" CACHE STRING "" FORCE)
	set(CMAKE_CXX_FLAGS_DEV "" CACHE STRING "" FORCE)
	set(CMAKE_C_FLAGS_RELEASE "" CACHE STRING "" FORCE)
	set(CMAKE_CXX_FLAGS_RELEASE "" CACHE STRING "" FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "" FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE STRING "" FORCE)
	set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "" CACHE STRING "" FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEV "" CACHE STRING "" FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEV "" CACHE STRING "" FORCE)
	set(CMAKE_MODULE_LINKER_FLAGS_DEV "" CACHE STRING "" FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE STRING "" FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "" CACHE STRING "" FORCE)
	set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "" CACHE STRING "" FORCE)
else()
	message(FATAL_ERROR "Unknown platform ${CMAKE_SYSTEM_NAME}!")
endif()

message(STATUS "Detected platform: ${PLATFORM_NAME}")

# Detect target architecture
if( ((PLATFORM_WINDOWS OR PLATFORM_UWP) AND CMAKE_CL_64) OR (PLATFORM_IOS AND CMAKE_OSX_ARCHITECTURES MATCHES "arm64") OR PLATFORM_XBOXONE OR PLATFORM_PS4 OR PLATFORM_LINUX OR PLATFORM_OSX )
	set(PLATFORM_64BIT 1)
endif()

if( PLATFORM_WINDOWS OR PLATFORM_OSX OR PLATFORM_LINUX OR PLATFORM_XBOXONE OR PLATFORM_PS4 OR PLATFORM_WEB OR PLATFORM_UWP )
	if( PLATFORM_64BIT )
		set(ARCH_NAME "x64")
	else()
		set(ARCH_NAME "x86")
	endif()
elseif( PLATFORM_IOS OR PLATFORM_ANDROID )
	if( PLATFORM_64BIT )
		set(ARCH_NAME "arm64")
	else()
		set(ARCH_NAME "arm")
	endif()
else()
	message(FATAL_ERROR "Unknown platform architecture!")
endif()

message(STATUS "Detected architecture: ${ARCH_NAME}")

if( PLATFORM_64BIT )
	set(ARCH_BITS "64")
	set(ARCH_64BITS "64")
else()
	set(ARCH_BITS "32")
	set(ARCH_64BITS "")
endif()

set(LIB_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
set(LIB_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})

# Configure CMake global variables
set(CMAKE_INSTALL_MESSAGE LAZY)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
if( PLATFORM_WINDOWS )
	set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
endif()
