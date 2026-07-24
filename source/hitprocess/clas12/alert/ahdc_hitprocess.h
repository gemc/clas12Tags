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

	double cubicInterpolate (double p[4], double x) {
		return p[1] + 0.5 * x*(p[2] - p[0] + x*(2.0*p[0] - 5.0*p[1] + 4.0*p[2] - p[3] + x*(3.0*(p[1] - p[2]) + p[3] - p[0])));
	}
	double linearInterpolate(double p[2], double x) {
		return p[0] + x*(p[1] - p[0]);
	}
	double interpolate(vector<double> x, vector<double> y, double val){

		if(val < x[0]){
			return y[0];
		}
		if(val > x[(int)x.size() -1]){
			return y[(int)y.size() -1];
		}
		//find appropriate bibn to start interpolation:
		int low = 0;
		int high = x.size() - 1;
		while (low <= high) {
			int mid = low + (high - low) / 2;
			// Check if x is present at mid, if so exactvalue is known.
			if (x[mid] == val){
				return y[mid]; 
			}
			// If x greater, ignore left half
			if (x[mid] < val) low = mid + 1;

			// If x is smaller, ignore right half
			else high = mid - 1;
		}
	
		low--;
		high++;

		if(low != high -1) cout << "issue with interpolation of AHDC T2D function" << endl;

		if(low >= 1 && high < (int)x.size() -2){
			vector<double> yv = {y[low-1], y[low], y[low+1],y[low+2]};
			val = (val - x[low])/(x[low+1] - x[low]);
			double yret = cubicInterpolate(&yv[0],val);
			return yret;
		}else{
			vector<double> yv = {y[low],y[low +1]};
			val = (val - x[low])/(x[low+1] - x[low]);
			double yret = linearInterpolate(&yv[0],val);
                        return yret;
		}
		
		return -1;
	}

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
	double T2D[10][576]; // contains the coefficients of a fit per wire
	double t2dmax[576]; //contains the maximum value for distance from T2D function for each wire.
	double eval_t2d(int wireId, double t){
		// T2D function consists of three 1st order polynomials (p1, p2, p3) and two transition functions (t1, t2).
		double p1 = (T2D[0][wireId] + T2D[1][wireId]*t);
		double p2 = (T2D[2][wireId] + T2D[3][wireId]*t);
		double p3 = (T2D[4][wireId] + T2D[5][wireId]*t);
		
		double t1 = 1.0/(1.0 + exp(-(t - T2D[6][wireId])/T2D[7][wireId]));
		double t2 = 1.0/(1.0 + exp(-(t - T2D[8][wireId])/T2D[9][wireId]));
		
		double retval = (p1)*(1.0 - t1) + (t1)*(p2)*(1.0 - t2) + (t2)*(p3);
		return retval;
	};
	//distance to time variables:
	vector<vector<double>> D2Tx;
	vector<vector<double>> D2Ty;
	void initializeInverseT2D(){
		double tmin = 0.0;
		double tmax = 500.0;
		double nstep = 100;
		double tstep = (tmax - tmin)/nstep;
		for(int i = 0; i < 576; i++){
			t2dmax[i] = 0;
			vector<double> x; //time
			vector<double> y; //distance
			int jmax = 0;
			for(int j = 0; j < nstep + 1; j++){
				double t = tmin + (double)j*tstep;
				x.push_back(t);
				y.push_back(eval_t2d(i,t));
				if(y[j] >  t2dmax[i]){
					t2dmax[i] = y[j];
					jmax = j;
				}
			}
			//to create an invertible function, we need the slope of the function to be positive always.  At larger t, the function can turn over, so we look for the maximum value of the function, and then force all additional points to follow the from the last positive slope before the inflection.
			double slope = (y[jmax] - y[jmax -1])/(x[jmax] - x[jmax -1]);
			if(slope <=0){
				cout << "issue with inversion  of T2D function in ALERT AHDC" << endl;
			}
			double yint = y[jmax] - slope*x[jmax];
			for(int j = jmax +1; j < nstep + 1; j++){
				y[j] = yint + slope*x[j];
			}

			D2Tx.push_back(y); //x is now distance
			D2Ty.push_back(x); //y is now time
		}
	}
	
	double eval_inv_t2d(int wireId, double dist){
		//cout << "starting inverse " << wireId << "  " << dist << endl;
		double retval = interpolate(D2Tx[wireId],D2Ty[wireId],dist);
		//cout << "found inverse: " << retval << endl;
		return retval;
	};
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
		double doca; ///< for now, distance of the closest hit in the AHDC cell
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
