// Copyright 1997-2000, 2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Header: svn+ssh://source.omnigroup.com/Source/svn/Omni/tags/OmniSourceRelease_2006-09-07/OmniGroup/Frameworks/OmniAppKit/FrameworkDefines.h 66043 2005-07-25 21:17:05Z kc $
// DO NOT MODIFY THIS FILE -- IT IS AUTOGENERATED!
//
// Platform specific defines for marking data and code
// as 'extern'.
//

#ifndef _OmniAppKitDEFINES_H
#define _OmniAppKitDEFINES_H

//
//  OpenStep/Mach or Rhapsody
//

#if defined(__MACH__)

#ifdef __cplusplus
#define OmniAppKit_EXTERN               extern
#define OmniAppKit_PRIVATE_EXTERN       __private_extern__
#else
#define OmniAppKit_EXTERN               extern
#define OmniAppKit_PRIVATE_EXTERN       __private_extern__
#endif


//
//  OpenStep/NT, YellowBox/NT, and YellowBox/95
//

#elif defined(WIN32)

#ifndef _NSBUILDING_OmniAppKit_DLL
#define _OmniAppKit_WINDOWS_DLL_GOOP       __declspec(dllimport)
#else
#define _OmniAppKit_WINDOWS_DLL_GOOP       __declspec(dllexport)
#endif

#ifdef __cplusplus
#define OmniAppKit_EXTERN			_OmniAppKit_WINDOWS_DLL_GOOP extern
#define OmniAppKit_PRIVATE_EXTERN		extern
#else
#define OmniAppKit_EXTERN			_OmniAppKit_WINDOWS_DLL_GOOP extern
#define OmniAppKit_PRIVATE_EXTERN		extern
#endif

//
// Standard UNIX: PDO/Solaris, PDO/HP-UX, GNUstep
//

#elif defined(sun) || defined(hpux) || defined(GNUSTEP)

#ifdef __cplusplus
#  define OmniAppKit_EXTERN               extern
#  define OmniAppKit_PRIVATE_EXTERN       extern
#else
#  define OmniAppKit_EXTERN               extern
#  define OmniAppKit_PRIVATE_EXTERN       extern
#endif

#else

#error Do not know how to define extern on this platform

#endif

#endif // _OmniAppKitDEFINES_H
