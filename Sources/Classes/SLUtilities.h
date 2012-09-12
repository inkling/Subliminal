//
//  SLUtilities.h
//  Subliminal
//
//  Created by Jeffrey Wear on 9/17/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#define SLStringWithFormatAfter(param) \
({ \
    va_list args; \
    va_start(args, param); \
    NSString *_string = [[NSString alloc] initWithFormat:param arguments:args]; \
    va_end(args); \
    _string; \
})
