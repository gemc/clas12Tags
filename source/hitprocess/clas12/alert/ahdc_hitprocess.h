#ifndef AHDC_HITPROCESS_H
#define AHDC_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"


class ahdcConstants
{
public:
	
	// Database parameters
	int    runNo;
	string date;
	string connection;
	char   database[80];

	// convert each (sector, layer, component) to a number between 0 and 575 (we have 576 wires)
	static int getUniqueId(int sector, int layer, int component) {
		if      (layer == 11) {
			return component - 1;
		} 
		else if (layer == 21) {
			return 47 + component - 1;
		} 
		else if (layer == 22) {
			return 47 + 56 + component - 1;
		} 
		else if (layer == 31) {
			return 47 + 56 + 56 + component - 1;
		} 
		else if (layer == 32) {
			return 47 + 56 + 56 + 72 + component - 1;
		} 
		else if (layer == 41) {
			return 47 + 56 + 56 + 72 + 72 + component - 1;
		} 
		else if (layer == 42) {
			return 47 + 56 + 56 + 72 + 72 + 87 + component - 1;
		} 
		else if (layer == 51) {
			return 47 + 56 + 56 + 72 + 72 + 87 + 87 + component - 1;
		} else {
			return -1; // not a ahdc wire
		}
	}

	// translation table
	TranslationTable TT;
	
	// t0 table
	double T0Correction[576];
	double get_T0(int sector, int layer, int component) { return T0Correction[getUniqueId(sector, layer, component)];}
	double get_T0(int wireId) { return T0Correction[wireId];}
	// time2distance 
	double T2D[6]; // contains the coefficients of a polynomial fit : p0 + p1*x + ... + p5*x^5
	double eval_t2d(double x) { return T2D[0] + T2D[1]*pow(x, 1.0) + T2D[2]*pow(x, 2.0) + T2D[3]*pow(x, 3.0) + T2D[4]*pow(x, 4.0) + T2D[5]*pow(x, 5.0);}
	double xi[50];
	double yi[50]; 
	// inverse of the xime2yistance	
	double eval_inv_t2d(double y) {
		if (y < 0) {
			return ((xi[1]-xi[0])/(yi[1]-yi[0]))*(y - yi[0]) + xi[0];
		} 
		else if (y >= yi[49]) {
			return ((xi[49]-xi[48])/(yi[49]-yi[48]))*(y - yi[48]) + xi[48];
		} else {
			int i = 0;
			while (i < 48) {
				if ((y >= yi[i]) && (y < yi[i+1])) {
					break;
				}
				i++;
			}
			return ((xi[i+1]-xi[i])/(yi[i+1]-yi[i]))*(y - yi[i]) + xi[i];
		}
	}
};


// Class definition
/// \class ahdc_HitProcess
/// <b> Alert Drift Chamber Hit Process Routine</b>\n\n

class ahdc_HitProcess : public HitProcess
{
public:
	
	~ahdc_HitProcess(){;}
	
	// constants initialized with initWithRunNumber
	static ahdcConstants ahdcc;
	
	void initWithRunNumber(int runno);
	
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
	static HitProcess *createHitClass() {return new ahdc_HitProcess;}
	
	// - electronicNoise: returns a vector of hits generated / by electronics.
	vector<MHit*> electronicNoise();
	
public:
	// AHDC geometry parameters
	float PAD_W, PAD_L, PAD_S, RTPC_L;
	float phi_per_pad;
	
	// parameters for drift and diffustion equations for drift time, 
	// drift angle, and diffusion in z
	float a_t, b_t, c_t, d_t;
	float a_phi, b_phi, c_phi, d_phi;
	float a_z, b_z;
	
	// variables for storing drift times and diffusion in time
	float t_2GEM2, t_2GEM3, t_2PAD, t_2END;
	float sigma_t_2GEM2, sigma_t_2GEM3, sigma_t_2PAD, sigma_t_gap;
	
	// variables for storing drift angle and diffusion in phi
	float phi_2GEM2, phi_2GEM3, phi_2PAD, phi_2END;
	float sigma_phi_2GEM2, sigma_phi_2GEM3, sigma_phi_2PAD, sigma_phi_gap;
	
	float z_cm;
	float TPC_TZERO;
	
	map<int, double> timeShift_map;
	double shift_t;
	
};

#include <string>
#include "CLHEP/GenericFunctions/Landau.hh"

/**
 * @class ahdcSignal
 * 
 * @brief ahdc signal simulation
 *
 * This class simulates the waveform of the ahdc signal and provide 
 * algorithms to extract relevant informations from this signal.
 *
 * @author Felix Touchte Codjo
 */
class ahdcSignal {
	// MHit or wires identifiers
	private : 
		int hitn; ///< n-th MHit of the event, also corresponds to the n-th activated wire
		int sector; ///< sector, first wire identifier
		int layer; ///< layer, second wire identifer
		int component; ///< component, third wire identifier
		int nsteps; ///< number of steps in this MHit, i.e number of Geant4 calculation steps in the sensitive area of the wire
	// vectors
	private :
		std::vector<double> Edep; ///< array of deposited energy in each step [keV]
		std::vector<double> G4Time; ///< array of Geant4 time corresponding to each step [ns]
		std::vector<double> Doca; ///< array of distance of closest approach corresponding each step [mm]
		std::vector<double> DriftTime; ///< array of drift time corresponding each step [ns]
		vector<double> stepTime; ///< Geant4 time of each step [ns]
		double Etot; ///< sum of Edep
		double doca; ///< for now, min of Doca
		double docaTime; ///< time corresponding to the doca using the time2distance
		/**
		 * @brief Fill the arrays Doca and DriftTime
		 * 
		 * Compute the doca corresponding to each step and
		 * deducte the driftime using a "time to distance"
		 * relation
		 *
		 * @param aHit an object derived from Geant4 "G4VHit" class
		 */
		void ComputeDocaAndTime(MHit * aHit);
		std::vector<short> Dgtz; ///< Array containing the samples of the simulated signal
		std::vector<short> Noise; ///< Array containing the samples of the simulated noise
		ahdcConstants * ahdcc_ptr = nullptr;
	// setting parameters for digitization
	private : 
		const double tmin; ///< lower limit of the simulated time window
		const double tmax; ///< upper limit of the simulated time window
		const double timeOffset; ///< time offset for simulation purpose, linked to the t0 from calibration
		const double samplingTime; ///< sampling time [ns]
		const double Landau_width; ///< Width pararemeter of the Landau distribution
		double electronYield = 9500;   ///< ADC gain
		static const int ADC_LIMIT = 4095; ///< ADC limit, corresponds to 12 digits : 2^12-1
	// public methods
	public :
		/** @brief Default constructor */
		ahdcSignal() = delete;
		
		/** @brief Constructor */
		ahdcSignal(MHit * aHit, int _hitn, double _tmin, double _tmax, double _timeOffset, double _samplingTime, double _Landau_width, ahdcConstants * _ptr) 
		: tmin(_tmin), tmax(_tmax), timeOffset(_timeOffset), samplingTime(_samplingTime), Landau_width(_Landau_width) {
			ahdcc_ptr = _ptr;
			// read identifiers
			hitn = _hitn;
			vector<identifier> identity = aHit->GetId();
			sector = 1;
			layer = 10 * identity[0].id + identity[1].id ; // 10*superlayer + layer
			component = identity[2].id;
			// fill vectors
			Edep = aHit->GetEdep();
			stepTime    = aHit->GetTime();
			nsteps = Edep.size();
			Etot = 0;
			for (int s=0;s<nsteps;s++){ 
				Edep.at(s) = Edep.at(s)*1000;
				Etot += Edep.at(s);
				//std::cout << "stepTime[" << s << "] = " << stepTime[s] << std::endl;
			} // convert MeV to keV
			G4Time = aHit->GetTime();
			this->ComputeDocaAndTime(aHit); // fills Doca and DriftTime
		}
		
		/** @brief Destructor */
		~ahdcSignal(){;}
		
		/** @brief Return the value of the attribut `electronYield` */
		double GetElectronYield() {return electronYield;}
		
		/** @brief Return the content of the attribut `Edep` */
		std::vector<double>                     GetEdep() 		{return Edep;}
		
		/** @brief Return the content of the attribut `G4Time` */
		std::vector<double>                     GetG4Time()		{return G4Time;}
		
		/** @brief Return the content of the attribut `Doca` */
		std::vector<double>                     GetDoca()		{return Doca;}
		
		/** @brief Return the content of the attribut `DriftTime` */
		std::vector<double>                     GetDriftTime()		{return DriftTime;}
		
		/** @brief Return the content of the attribut `Noise` */
		std::vector<short>                     GetNoise()              {return Noise;}
		
		/** @brief Return the content of the attribut `Dgtz` */
		std::vector<short> 			GetDgtz()		{return Dgtz;}
		
		/** @brief Return the number of steps in the AHDC cell */		
		int GetNSteps() { return nsteps;}	

		/**
		 * @brief Set the electron yield. 
		 * 
		 * Only relevant before the use of the method `Digitize`
		 */
		void SetElectronYield(double electronYield_)		{electronYield = electronYield_;}
		
		/**
		 * @brief Overloaded `()` operator to get the value of the signal at a given time.
		 * 
		 * @param t Time at which to calculate the signal's value
		 *
		 * @return Value of the signal at the time `t`
		 */
		/*double operator()(double timePoint){
			using namespace Genfun;
			double signalValue = 0;
			for (int s=0; s<nsteps; s++){
				double sigma = Landau_width;	
				double mu = DriftTime.at(s) + 1.36*sigma;
				//std::cout << DriftTime.at(s) << " ";
				Landau L;
				L.peak() = Parameter("Peak",mu,tmin,tmax); 
				L.width() = Parameter("Width",sigma,0,400); 
				signalValue += Edep.at(s)*L(timePoint-timeOffset);
			}
			return signalValue;
		}*/
		double operator()(double timePoint){
			using namespace Genfun;
			double sigma = Landau_width;	
			double mu = docaTime + 1.36*sigma;
			//mu -= 4; // systematic correction from the decoding
			Landau L;
			L.peak() = Parameter("Peak",mu,tmin,tmax); 
			L.width() = Parameter("Width",sigma,0,400); 
			return Etot*L(timePoint-timeOffset);
		}
		
		/**
		 * @brief Digitize the simulated signal
		 *
		 * This method perfoms several steps
		 * - step 1 : it produces samples from the simulated signal (using `samplingTime`)
		 * - step 2 : it converts keV/ns in ADC units (using `electronYield`)
		 * - step 3 : it adds noise
		 *
		 * @return Fill the attributs `Dgtz` and `Noise` 
		 */
		void Digitize();

		/** @brief Generate gaussian noise
		 *
		 * @return Fill the attribut `Noise`
		 */
		void GenerateNoise(double mean, double stdev);
		
		double GetMeanTimeValue(); 
		double GetDocaTimeValue(); 
		double GetDocaValue(); 
		double GetEtotValue(); 
		
};



#endif




