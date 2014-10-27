//
//  Constants.h
//  TouchChart
//
//  Created by Adam Wulf on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef TouchChart_Constants_h
#define TouchChart_Constants_h

#ifdef DEBUG
#define DebugLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DebugLog(format, ...)
#endif


#endif

