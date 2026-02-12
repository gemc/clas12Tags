#ifndef LORENTZ_H
#define LORENTZ_H 1

// c++
#include <vector>
#include "HitProcess.h"
#include <string>
using namespace std;


class Lorentz {
public:
	Lorentz() = default;
	~Lorentz() = default;

	std::vector<double> Lor_grid;
	std::vector<double> E_grid;
	std::vector<double> B_grid;

	float emin = 999999.f;
	float emax = 0.f;
	float bmin = 999999.f;
	float bmax = 0.f;
	int Ne = 0;
	int Nb = 0;

	std::string variation;
	std::string date;
	std::string connection;
	char database[80] = {0};

	void Initialize(int runno);
	int getBin(float e, float b);
	float GetAngle(float xe, float xb);
	float linInterp(float x, float x1, float x2, float y1, float y2);
};


#endif
