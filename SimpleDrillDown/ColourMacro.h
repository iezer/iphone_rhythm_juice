//
//  ColourMacro.h
//  SimpleDrillDown
//
//  Created by  on 12-05-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SimpleDrillDown_ColourMacro_h
#define SimpleDrillDown_ColourMacro_h

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RJColorBlue UIColorFromRGB(0x3399CC)
#define RJColorRed UIColorFromRGB(0xCC3333)
#define RJColorGreen UIColorFromRGB(0x339933)
#define RJColorDarkBlue UIColorFromRGB(0x336699)
#endif
