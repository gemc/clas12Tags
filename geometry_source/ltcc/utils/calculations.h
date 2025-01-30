#ifndef LTCC_UTILS_CALCULATIONS_LOADED
#define LTCC_UTILS_CALCULATIONS_LOADED

#include <string>

// interpolate linearly table values
double interpolate(double x, std::string what);
// pure photon yield as from Tamm's formula
double dndxdl(double *x, double *par);

void integrate_yield();

// formula to calculate the window percentage increase
double windowy(double *x, double *par);

int calculateNReflection(double r);
int calculateWCgroup(double r);
void simulateResponse();

#endif
