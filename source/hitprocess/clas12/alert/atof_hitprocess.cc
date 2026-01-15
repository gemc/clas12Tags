// G4 headers
#include "G4Poisson.hh"
#include "Randomize.hh"
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;
// gemc headers
#include "atof_hitprocess.h"
// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

//CCDB constant initialization
//reading out and storing tables
static atofConstants initializeATOFConstants(int runno, string digiVariation = "default", string digiSnapshotTime = "no", bool accountForHardwareStatus = false) {

  //Holds all the tables
  atofConstants atc;
	
  // do not initialize at the beginning, only after the end of the first event,
  // with the proper run number coming from options or run table
  if(runno == -1) return atc;
  string timestamp = "";
  if(digiSnapshotTime != "no") {
    timestamp = ":"+digiSnapshotTime;
  }
	
  atc.runNo = runno;
  if (getenv("CCDB_CONNECTION") != nullptr)
    atc.connection = (string) getenv("CCDB_CONNECTION");
  else
    atc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";	
  
  //table indices
  int isec, ilay, icomponent, iorder;
  //reads out ccdb table
  vector<vector<double>> data;
	
  unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(atc.connection));
  cout << "Connecting to " << atc.connection << "/calibration/alert/atof" << endl;

  //Effective velocity readout
  snprintf(atc.database, sizeof(atc.database),  "/calibration/alert/atof/effective_velocity:%d:%s%s", atc.runNo, digiVariation.c_str(), timestamp.c_str());
  cout << "ATOF:Getting effective_velocity" << endl;
  data.clear();
  calib->GetCalib(data, atc.database);
  for (unsigned row = 0; row < data.size(); row++) {
    isec = data[row][0];
    ilay = data[row][1];
    icomponent = data[row][2];    
    atc.veffTable[isec][ilay][icomponent].value=data[row][3];
    atc.veffTable[isec][ilay][icomponent].dvalue=data[row][4];
  }

  //Time offsets readout, T0 and TUD
  snprintf(atc.database, sizeof(atc.database), "/calibration/alert/atof/time_offsets:%d:%s%s", atc.runNo, digiVariation.c_str(), timestamp.c_str());
  cout << "ATOF:Getting time_offsets" << endl;
  data.clear();
  calib->GetCalib(data, atc.database);
  for (unsigned row = 0; row < data.size(); row++) {
    iorder = data[row][3];
    //There are two entries per order for the bars in the CCDB table
    //But it should not be the case, the convention has been chosen to be
    //that order 0 is used to store the right value.
    //wedges are always order 0
    if(iorder!=0) continue;
    isec = data[row][0];
    ilay = data[row][1];
    icomponent = data[row][2];
    atc.timeOffsetTable[isec][ilay][icomponent].value = data[row][4];
    atc.timeOffsetTable[isec][ilay][icomponent].dvalue = data[row][7];
    atc.timeUDTable[isec][ilay][icomponent].value = data[row][5];
    atc.timeUDTable[isec][ilay][icomponent].dvalue = data[row][8];
  }
  return atc;
}

//Making the digitized output
map<string, double> atof_HitProcess::integrateDgt(MHit* aHit, int hitn) {
	
  // digitized output
  map<string, double> dgtz;
  vector<identifier> identity = aHit->GetId();
  rejectHitConditions = false;
  writeHit = true;
  
  int atof_sector     = identity[0].id;
  int atof_superlayer = identity[1].id; //bar: SL = 0; wedge: SL=1
  int atof_layer      = identity[2].id;
  int atof_component  = identity[3].id;
  int atof_order      = identity[4].id;
  
  double time_to_tdc = 1./0.015625;
  
  if(aHit->isBackgroundHit == 1) {
    
    double totEdep  = aHit->GetEdep()[0];
    double stepTime = aHit->GetTime()[0];
    double tdc      = stepTime * time_to_tdc;
    
    dgtz["hitn"]      = hitn;
    dgtz["sector"]    = atof_sector; //Sector ranges from 0 to 14 counterclockwise when z is pointing towards us
    dgtz["layer"]     = atof_layer; //Layer is the index for the wedge+bar (quarter of sector) ranging 0 to 3
    dgtz["component"] = atof_component; //z slice ranging 0 to 9 for the wedge or 10 if it is the long bar
    dgtz["TDC_order"] = atof_order; //order for the bar is 0/1 for downstream/upstream and 0 for the wedge
    dgtz["TDC_ToT"]   = (int) totEdep;
    dgtz["TDC_TDC"]  = tdc; 
    return dgtz;
  }
  
  trueInfos tInfos(aHit);

  //Half length of the atof
  double halfLength = aHit->GetDetector().dimensions[0];
  //For the position of the SiPM on top of the wedges
  double dim_3, dim_4, dim_5, dim_6, l_topXY, l_a, l_b;
  dim_3 = aHit->GetDetector().dimensions[3];
  dim_4 = aHit->GetDetector().dimensions[4];
  dim_5 = aHit->GetDetector().dimensions[5];
  dim_6 = aHit->GetDetector().dimensions[6];
  l_topXY = sqrt( pow((dim_3 - dim_5),2) + pow((dim_4 - dim_6),2) );

  //True hit info
  vector<G4double>      Edep  = aHit->GetEdep();
  vector<G4ThreeVector> Lpos  = aHit->GetLPos(); // local position at each step
  vector<double>        times = aHit->GetTime();

  //Digitized hit info
  double adc_CC_upstream, adc_CC_downstream, adc_CC_top, tdc_CC_upstream, tdc_CC_downstream, tdc_CC_top;
  
  double LposX=0.0;
  double LposY=0.0;
  double LposZ=0.0;
  
  // Simple output not equal to real physics, just to feel the adc, time values
  // Should be: double energy = tInfos.eTot*att;
  double totEdep=0.0;
  
  //Distance from bar hit to up/downstream SiPMs
  double dUpstream = 0.0;
  double dDownstream = 0.0; 
  //energy factors up/downstream bar hits
  double e_Upstream = 0.0;
  double e_Downstream = 0.0;
  double E_tot_Upstream = 0.0;
  double E_tot_Downstream = 0.0;
  
  //Wedge hits, SiPM on "top"
  double H_hit_SiPM = 0.0;
  double e_Top = 0.0;
  double E_tot_Top = 0.0;

  //Att length and energy to be calibrated!
  double attlength = 1600.0; // here in mm! because all lengths from the volume are in mm!! EJ-204 160 cm
  double pmtPEYld = 10400.0; // EJ-204 10400 (photons / [1MeV*e-])
  double dEdxMIP = 1.956; // energy deposited by MIP per cm of scintillator material, to be adapted for SiPM case, it is a function of ?
  
  //Variables for tdc calculation (time)
  double EtimesTime_Upstream=0.0;
  double EtimesTime_Downstream=0.0;
  double EtimesTime_Top=0.0;

  //effective velocity
  //in principle defined separately for up bar/down bar/wedge
  //mean and sigma from ccdb fit
  double effVelocity = atc.veffTable[atof_sector][atof_layer][atof_component].value;//mm.ns-1
  double deffVelocity = atc.veffTable[atof_sector][atof_layer][atof_component].dvalue;
  double v_eff_Upstream = G4RandGauss::shoot(effVelocity, deffVelocity);
  //for now consider veff in all directions
  double v_eff_Downstream = v_eff_Upstream;

  //Global time offset
  double t0 = G4RandGauss::shoot(atc.timeOffsetTable[atof_sector][atof_layer][atof_component].value,
				 atc.timeOffsetTable[atof_sector][atof_layer][atof_component].dvalue);
  //For the bars the time offset stored in CCDB is 2*(t0+L/veff) where L is the length of the ATOF
  if(atof_component==10) t0 = t0/2 - halfLength/v_eff_Downstream;

  //Time offset between up/downstream bar channels
  double tUD = G4RandGauss::shoot(atc.timeUDTable[atof_sector][atof_layer][atof_component].value,
				  atc.timeUDTable[atof_sector][atof_layer][atof_component].dvalue);

  //Looping over steps
  for(unsigned int s=0; s<tInfos.nsteps; s++)
    {
      //Local coordinate of this step.
      LposX = Lpos[s].x();
      LposY = Lpos[s].y();
      LposZ = Lpos[s].z();

      //Bar hits
      if(atof_superlayer == 0)
	{
	  //Distance to SiPM
	  dUpstream = halfLength + LposZ;
	  dDownstream = halfLength - LposZ;
	  //Energy deposit for this step, MeV
	  e_Upstream = Edep[s] *exp(-dUpstream/attlength);
	  e_Downstream = Edep[s] *exp(-dDownstream/attlength);
	  //Sum over steps used for weighting
	  E_tot_Upstream = E_tot_Upstream + e_Upstream;
	  E_tot_Downstream = E_tot_Downstream + e_Downstream;
	  
	  // to check the totEdep MC truth value
	  totEdep = totEdep + Edep[s];
	  
	  //time in ns, weighed by energy deposit
	  EtimesTime_Upstream = EtimesTime_Upstream + (times[s] + dUpstream/v_eff_Upstream)*e_Upstream;
	  EtimesTime_Downstream = EtimesTime_Downstream + (times[s] + dDownstream/v_eff_Downstream)*e_Downstream;
	}
      
      //Wedge hits
      else
	{
	  //Position
	  l_a = sqrt( pow((dim_3 - LposX),2) + pow((dim_4 - LposY),2) );
	  l_b = sqrt( pow((dim_5 - LposX),2) + pow((dim_6 - LposY),2) );
	  	  
	  // to check the totEdep MC truth value
	  totEdep = totEdep + Edep[s];
	  
	  if( (l_a + l_b) == l_topXY) 
	    {
	      H_hit_SiPM = 0.0;
	      e_Top = Edep[s] *1.0; // H=0.0 -> exp() = 1.0
	      E_tot_Top = E_tot_Top + e_Top;
	    }	
	  else
	    {
	      H_hit_SiPM = l_a * sqrt( 1 - ((l_topXY*l_topXY + l_a*l_a - l_b*l_b)/(2*l_a*l_topXY)) );
	      e_Top = Edep[s] *exp(-H_hit_SiPM/attlength);
	      E_tot_Top = E_tot_Top + e_Top;
	    }
	  //For now we ignore veff in the wedges, to update if calibrations evolve
	  EtimesTime_Top = EtimesTime_Top + (times[s])*e_Top;// + H_hit_SiPM/v_eff_Top)*e_Top;	  
	}
    }
  
  if (atof_superlayer == 0)
    {	
      // test factor for calibration coeff. conversion
      adc_CC_upstream = 10.0;	
      adc_CC_downstream = 10.0;
      tdc_CC_upstream = 1.0;	
      tdc_CC_downstream = 1.0;
    }
  else 
    {
      adc_CC_top = 10.0;
      tdc_CC_top = 1.0;
    }
  
  double adc_upstream = 0.00000;
  double adc_downstream = 0.00000;
  double adc_top = 0.00000;
  double tdc_upstream = 0.00000;
  double tdc_downstream = 0.00000;
  double tdc_top = 0.00000;
  double time_upstream = 0.00000;
  double time_downstream = 0.00000;
  double time_top = 0.00000;
  //double sigma_time = 0.1;//would be used if realistic resolutions were not in CCDB
  //in ns, 100 ps = 0.1 ns
  
  //TOT and TDC for bars
  if ((E_tot_Upstream > 0.0) || (E_tot_Downstream > 0.0)) 
    {
      //energy to TOT conversion
      double nphe_fr = G4Poisson(E_tot_Upstream*pmtPEYld);
      double energy_fr = nphe_fr/pmtPEYld;
      
      double nphe_bck = G4Poisson(E_tot_Downstream*pmtPEYld);
      double energy_bck = nphe_bck/pmtPEYld;	

      adc_upstream = energy_fr *adc_CC_upstream *(1/(dEdxMIP*0.3)); // 3 mm sl0 (radial) thickness in XY -> 0.3 cm
      adc_downstream = energy_bck *adc_CC_downstream *(1/(dEdxMIP*0.3));

      //Time offset and tdc conversion
      time_upstream = EtimesTime_Upstream/E_tot_Upstream + t0 + tUD/2;
      time_downstream = EtimesTime_Downstream/E_tot_Downstream + t0 - tUD/2;
      //Realistic resolutions are implemented from CCs
      tdc_upstream = time_upstream/ tdc_CC_upstream;//G4RandGauss::shoot(time_upstream, sigma_time) / tdc_CC_upstream; 
      tdc_downstream = time_downstream/ tdc_CC_downstream;//G4RandGauss::shoot(time_downstream, sigma_time) / tdc_CC_downstream;
    }
  //TOT and TDC for wedges
  if(E_tot_Top > 0.0)
    {
      double nphe_top = G4Poisson(E_tot_Top*pmtPEYld);
      double energy_top = nphe_top/pmtPEYld;
      
      adc_top = energy_top *adc_CC_top *(1/(dEdxMIP*2.0)); // 20 mm sl1 (radial) thickness in XY -> 2.0 cm
      time_top = EtimesTime_Top/E_tot_Top + t0;
      tdc_top  = time_top/ tdc_CC_top;//G4RandGauss::shoot(time_top, sigma_time) / tdc_CC_top;
    }
  
  double adc = 0;
  double time = 0;
  
  if (atof_superlayer == 0) {
    if ( atof_order == 1 ) {
      adc  = adc_upstream;
      time = tdc_upstream;
    } else {
      adc  = adc_downstream;
      time = tdc_downstream ;
    }
  } else {
    adc  = adc_top;
    time = tdc_top;
  }
  
  dgtz["hitn"]      = hitn;
  dgtz["sector"]    = atof_sector; //Sector ranges from 0 to 14 counterclockwise when z is pointing towards us
  dgtz["layer"]     = atof_layer; //Layer is the index for the wedge+bar (quarter of sector) ranging 0 to 3
  dgtz["component"] = atof_component; //z slice ranging 0 to 9 for the wedge or 10 if it is the long bar
  dgtz["TDC_order"] = atof_order;
  dgtz["TDC_ToT"]   = (int)adc*100;
  dgtz["TDC_TDC"]  = time * time_to_tdc;
  
  // define conditions to reject hit
  if (rejectHitConditions) {
    writeHit = false;
  }
  
  return dgtz;
}

vector<identifier> atof_HitProcess::processID(vector<identifier> id, G4Step* aStep, detector Detector) {
  
  vector<identifier> yid = id;
  
  // top components do not modify order
  if (yid[1].id == 1) {
    id[id.size()-1].id_sharing = 1;
    return id;
  }
  
  yid[0].id_sharing = 1; // sector
  yid[1].id_sharing = 1; // superlayer
  yid[2].id_sharing = 1; // layer
  yid[3].id_sharing = 1; // component
  yid[4].id_sharing = 1; // order
  
  if (yid[4].id != 0) {
    cout << "*****WARNING***** in ahdc_HitProcess :: processID, order of the original hit should be 0 " << endl;
    cout << "yid[4].id = " << yid[4].id << endl;
  }
  
  // Now we want to have similar identifiers, but the only difference be id order to be 1, instead of 0
  identifier this_id = yid[0];
  yid.push_back(this_id);
  this_id = yid[1];
  yid.push_back(this_id);
  this_id = yid[2];
  yid.push_back(this_id);
  this_id = yid[3];
  yid.push_back(this_id);
  this_id = yid[4];
  this_id.id = 1;
  yid.push_back(this_id);
  
  return yid;
}

// - electronicNoise: returns a vector of hits generated / by electronics.

vector<MHit*> atof_HitProcess::electronicNoise() {
  vector<MHit*> noiseHits;
  
  // first, identify the cells that would have electronic noise
  // then instantiate hit with energy E, time T, identifier IDF:
  //
  // MHit* thisNoiseHit = new MHit(E, T, IDF, pid);
  
  // push to noiseHits collection:
  // noiseHits.push_back(thisNoiseHit)
	
  return noiseHits;
}

map< string, vector <int> > atof_HitProcess::multiDgt(MHit* aHit, int hitn) {
  map< string, vector <int> > MH;
  
  return MH;
}

// - charge: returns charge/time digitized information / step

map< int, vector <double> > atof_HitProcess::chargeTime(MHit* aHit, int hitn) {
  map< int, vector <double> >  CT;
  
  return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)

double atof_HitProcess::voltage(double charge, double time, double forTime) {
  return 0.0;
}

void atof_HitProcess::initWithRunNumber(int runno)
{
  string digiVariation = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
  
  if (atc.runNo != runno) {
    cout << " > Initializing " << HCname << " digitization for run number " << runno << endl;
    atc = initializeATOFConstants(runno, digiVariation);
    atc.runNo = runno;
  }
}

// this static function will be loaded first thing by the executable
atofConstants atof_HitProcess::atc = initializeATOFConstants(-1);
