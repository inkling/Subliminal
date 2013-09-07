//
//  chisqr.c
//  Subliminal
//
//  Created by Aaron Golden on 9/6/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#include "chisqr.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

double f(double s, double t) {
    return pow(t, s - 1.0) * exp(-t);
}

// Integrates f(s,t) for t = min_t to max_t, taking nsteps integration steps,
// using Simpson's rule: http://en.wikipedia.org/wiki/Simpson's_rule
double Integrate(double (*f)(double s, double t), double s, double min_t, double max_t, int nsteps) {
    const double h = (max_t - min_t) / nsteps;

    double q = f(s, min_t) + f(s, max_t);
    for (int j = 1; j <= nsteps; j += 2) {
        q += 4 * f(s, min_t + j * h);
    }
    for (int j = 2; j <= nsteps - 1; j += 2) {
        q += 2 * f(s, min_t + j * h);
    }

    return q * h / 3.0;
}

bool ChiIsUniform(double *distribution, size_t distributionLength, size_t degreesOfFreedom, double significance)
{
    double expected = 0.0;
    for (size_t j = 0; j < distributionLength; j++) {
        expected += distribution[j];
    }
    expected /= distributionLength;

    double sum = 0.0;
    for (size_t j = 0; j < distributionLength; j++) {
        double x = distribution[j] - expected;
        sum += x * x;
    }

    const double chi2DistanceFromUniformDistribution = sum / expected;

    const double max_t = 0.5 * chi2DistanceFromUniformDistribution;
    const double dof_2 = degreesOfFreedom * 0.5;
    const int nsteps = max_t / 0.01 + 1;
    const double lowerIncompleteGamma = Integrate(f, dof_2, 0.0, max_t, nsteps);
    const double p = 1.0 - lowerIncompleteGamma / tgamma(dof_2);

    return p >= significance;
}
