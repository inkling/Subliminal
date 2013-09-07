//
//  chisqr.h
//  Subliminal
//
//  Created by Aaron Golden on 9/6/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#include <stdbool.h>
#include <sys/types.h>

#ifndef Subliminal_chisqr_h
#define Subliminal_chisqr_h

/**
 Determines whether or not a distribution is sufficiently close to a uniform
 distribution, where "sufficiently close" is determined by the significance
 parameter.

 @param distribution        An array of doubles that is an observed distribution,
                            for example every element of distribution might be
                            an integer specifying the number of times that a
                            particular element was observed in a sample.

 @param distributionLength  The number of elements in distribution.

 @param degreesOfFreedom    The number of degrees of freedom in the statistic reflected
                            by distribution.  If the sample reflected by distribution is
                            not otherwise constrained, degreesOfFreedom should be
                            distributionLength - 1.

 @param significance        A value controlling the strictness of the uniformity test.
                            ChiIsUniform will return true if the probability of observing
                            distribution in a sample taken from a truly uniform distribution
                            is at least significance.

 @return    true if the probability of observing distribution in a sample taken from a truly
            uniform distribution is greater than or equal to significance, false otherwise.
 */
bool ChiIsUniform(double *distribution, size_t distributionLength, size_t degreesOfFreedom, double significance);

#endif
