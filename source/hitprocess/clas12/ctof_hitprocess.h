#ifndef CTOF_HITPROCESS_H
#define CTOF_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"

class ctofConstants
{
public:
	
	// Database parameters
	int    runNo;
	string date;
	string connection;
	char   database[80];
	
	int n_paddle;  // Number of ctof paddles
	int n_pmt;  // number of PMTs per paddle
	
	
	// For paddle dependent constants read from CCDB
	// Array [1][1][2] -> sector,panel,UD
	
	// status:
	//	0 - fully functioning
	//	1 - noADC
	//	2 - noTDC
	//	3 - noADC, noTDC (PMT is dead)
	// 5 - any other reconstruction problem
	vector<int> status[1][1][2];
	
	// Threshold (MeV)
	vector<double> threshold[1][1][2];
	
	// efficiency
	vector<double> efficiency[1][1][2];
	
	// tdc_conc: tdc conversion factors
	vector<double> tdcconv[1][1][2];
	
       	// adc time offsets
	vector<double> adcoffset[1][1][2];
        
	// veff: effective velocity
	vector<double> veff[1][1][2];
	
	// attlen: attenuation length
	vector<double> attlen[1][1][2];
	
	// countsForMIP: Desired ADC channel for MIP peak calibration
	vector<double> countsForMIP[1][1][2];
	
	// twlk: Time walk correction, 3 constants each for L and R
	vector<double> twlk[1][1][6];
	
	vector<double> toff_UD[1][1];
	vector<double> toff_RFpad[1][1];
	vector<double> toff_P2P[1][1];
	
	// geometry: length and z offset
	vector<double> length[1][1];
	vector<double> zoffset[1][1];
	
	// ======== FADC Pedestals and sigmas ===========
	double pedestal[48][2] = {};
	double pedestal_sigm[48][2] = {};
	
	
	
	// tres: Gaussian sigma for smearing time resolution
	vector<double> tres;
	
	int    npaddles;     // Number of paddles.
	int    thick;        // Thickness of paddles (cm).
	double dEdxMIP;      // Nominal MIP specific energy loss (MeV/gm/cm2).
	double dEMIP;        // Nominal MIP energy loss (MeV).
	
	double pmtPEYld;      // Photoelectron yield (p.e./MeV)
	double pmtQE;         // Quantum efficiency of PMT
	double pmtDynodeGain; // PMT dynode gain
	double pmtDynodeK;    // PMT dynode secondary emission statistics factor: K=0 (Poisson) K=1 (exponential)
	double pmtFactor;     // Contribution to FWHM from PMT statistical fluctuations.
	double tdcLSB;        // Conversion from ns to TDC channel.
	
	//	voltage signal parameters, using double gaussian + delay (function DGauss, need documentation for it)
	double vpar[4];
	
	// TODO: VARIATION SHOULD NOT BE HARDCODED
	// target position from (hardcoded for now) variation rga_fall2018
	double targetZPos;
	
	// translation table
	TranslationTable TT;        
};

// Class definition
/// \class ctof_HitProcess
/// <b> Central Time of Flight Hit Process Routine</b>\n\n

class ctof_HitProcess : public HitProcess
{
public:
	
	~ctof_HitProcess(){;}
	
	
	// - integrateDgt: returns digitized information integrated over the hit
	map<string, double> integrateDgt(MHit*, int);
	
	// - multiDgt: returns multiple digitized information / hit
	map< string, vector <int> > multiDgt(MHit*, int);
	
	// - charge: returns charge/time digitized information / step
	virtual map< int, vector <double> > chargeTime(MHit*, int);
	
	// - voltage: returns a voltage value for a given time. The input are charge value, time
	virtual double voltage(double, double, double);
	
	// The pure virtual method processID returns a (new) identifier
	// containing hit sharing information
	vector<identifier> processID(vector<identifier>, G4Step*, detector);
	
	// creates the HitProcess
	static HitProcess *createHitClass() {return new ctof_HitProcess;}
	
private:
	// constants initialized with initWithRunNumber
	static ctofConstants ctc;
	
	void initWithRunNumber(int runno);
	
	// - electronicNoise: returns a vector of hits generated / by electronics.
	vector<MHit*> electronicNoise();
	
	double fadc_precision = 0.0625;  // 62 picoseconds resolution
	double convert_to_precision(double time) {
		return (int( time / fadc_precision ) * fadc_precision);
	}
	
};

#endif
