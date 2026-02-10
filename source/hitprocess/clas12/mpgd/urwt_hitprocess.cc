// gemc headers
#include "urwt_hitprocess.h"

// geant4 headers
#include "G4Trap.hh"
#include "G4AffineTransform.hh"
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

// ccdb
#include <CCDB/Calibration.h>
#include <CCDB/CalibrationGenerator.h>

#include <cmath>
#include <numeric>
#include <memory>
#include <vector>
#include <string>
#include <iostream>
#include <set>
#include <unordered_set>

using namespace ccdb;
using std::string;
using std::vector;

std::unordered_map<int, StripDigitizer> urwt_HitProcess::digiU_byLayer;
std::unordered_map<int, StripDigitizer> urwt_HitProcess::digiV_byLayer;

static StripConstants initializeurwtConstants(int runno,
                                              string digiVariation = "default",
                                              string digiSnapshotTime = "no",
                                              bool accountForHardwareStatus = false)
{

  StripConstants urwtC;

  if (runno == -1)
  {
    return urwtC;
  }
  string timestamp = "";
  if (digiSnapshotTime != "no")
  {
    timestamp = ":" + digiSnapshotTime;
  }

  urwtC.runNo = runno;
  urwtC.digiVariation = digiVariation;
  urwtC.digiSnapshotTime = digiSnapshotTime;

  if (getenv("CCDB_CONNECTION") != nullptr)
    urwtC.connection = (string)getenv("CCDB_CONNECTION");
  else
    urwtC.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";

  vector<vector<double>> data;
  std::unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(urwtC.connection));

  // --- Global table
  snprintf(urwtC.database, sizeof(urwtC.database),
           "/test/urwt/urwt_global:%d:%s%s",
           urwtC.runNo, digiVariation.c_str(), timestamp.c_str());

  data.clear();
  calib->GetCalib(data, urwtC.database);

  {
    const int row = 0;
    urwtC.width = data[row][10];                     // mm
    urwtC.pitch = data[row][11];                     // mm
    urwtC.stereoAngleY = data[row][12] * M_PI / 180; // rad
  }

  // --- Digitization table
  snprintf(urwtC.database, sizeof(urwtC.database),
           "/test/urwt/urwt_dgt:%d:%s%s",
           urwtC.runNo, digiVariation.c_str(), timestamp.c_str());

  data.clear();

  calib->GetCalib(data, urwtC.database);

  {
    const int row = 0;
    urwtC.w_i = data[row][0];      // eV
    urwtC.sigma_td = data[row][1]; // mm
    urwtC.gain = data[row][2];
    urwtC.v_drift = data[row][3];    // cm/ns
    urwtC.sigma_time = data[row][4]; // ns
  }

  return urwtC;
}

// ------------------ integrateDgt ------------------

map<string, double> urwt_HitProcess::integrateDgt(MHit *aHit, int hitn)
{

  map<string, double> dgtz;
  vector<identifier> identity = aHit->GetId();

  rejectHitConditions = false;
  writeHit = true;

  trueInfos tInfos(aHit);

  dgtz["hitn"] = hitn;
  dgtz["sector"] = identity[1].id;
  dgtz["layer"] = identity[2].id;
  dgtz["component"] = identity[3].id;

  // No sentinel IDs: every entry corresponds to a real strip
  dgtz["ADC_ADC"] = (1.0 * (int)(urwtC.gain * 1e6 * tInfos.eTot / urwtC.w_i));
  dgtz["ADC_time"] = identity[3].time;
  dgtz["ADC_ped"] = 0;

  if((1.0 * (int)(urwtC.gain * 1e6 * tInfos.eTot / urwtC.w_i))<2){
      rejectHitConditions =true;
  }

  if (rejectHitConditions)
    writeHit = false;

  // cout<<"tIntos.eTot "<<tInfos.eTot<<endl;
  // cout<<dgtz["sector"]<<" "<<dgtz["layer"]<<" "<<dgtz["component"]<<" "<<dgtz["ADC_ADC"]<<endl;

  return dgtz;
}

vector<identifier> urwt_HitProcess ::processID(vector<identifier> id, G4Step *aStep, detector Detector)
{

  if (urwtC.runNo == -1)
  {
    vector<identifier> yid;

    for (int j = 0; j < 4; ++j)
    {
      identifier outId;
      outId.name = id[j].name;
      outId.rule = id[j].rule;

      outId.id = id[j].id;

      // component dummy
      if (j == 3)
      {
        outId.id = 1; // strip fittizia
        outId.time = aStep->GetPostStepPoint()->GetGlobalTime();
      }
      outId.id_sharing = -1.0;

      outId.TimeWindow = id[j].TimeWindow;
      outId.TrackId = id[j].TrackId;

      yid.push_back(outId);
    }

    return yid;
  }

  const StripConstants base = urwtC;

  vector<identifier> yid;

  const G4ThreeVector xyz = aStep->GetPostStepPoint()->GetPosition();

  // Save the GLOBAL->LOCAL transform (needed for zReadoutLocal logic + global strip ordering)
  const auto globalToLocal = aStep->GetPreStepPoint()
                                 ->GetTouchableHandle()
                                 ->GetHistory()
                                 ->GetTopTransform();

  const G4ThreeVector lxyz = globalToLocal.TransformPoint(xyz);

  const double depe = aStep->GetTotalEnergyDeposit();
  const double time = aStep->GetPostStepPoint()->GetGlobalTime();

  G4VTouchable *TH = (G4VTouchable *)aStep->GetPreStepPoint()->GetTouchable();
  G4Trap *trap = dynamic_cast<G4Trap *>(TH->GetSolid());
  if (!trap)
    return yid;

  int layer = 0;
  auto pos = trap->GetName().find("_l");

  if (pos != std::string::npos)
    layer = std::stoi(trap->GetName().substr(pos + 2));

  const bool wantU = (layer % 2 == 1);

  auto &digi = wantU ? digiU_byLayer[layer] : digiV_byLayer[layer];
  StripConstants c = base;

  c.xHalfSmall = trap->GetXHalfLength1();
  c.xHalfLarge = trap->GetXHalfLength2();
  c.yHalf = trap->GetYHalfLength1();
  c.zHalf = trap->GetZHalfLength();
  c.zReadoutLocal = 0.0;

  if (wantU)
    c.SetStripParams(+base.stereoAngleY, base.pitch, base.width);
  else
    c.SetStripParams(-base.stereoAngleY, base.pitch, base.width);

  auto pushHits = [&](const std::vector<StripHit> &hits)
  {
    if (hits.empty())
      return;

    for (const auto &h : hits)
    {
      for (int j = 0; j < 4; ++j)
      {
        identifier outId;
        outId.name = id[j].name;
        outId.rule = id[j].rule;

        // identifiers  j=0 region ; j=1 sector; j2 layer; j3 component
        if (j == 0 || j == 1)
          outId.id = id[j].id;

        // Encode view in the layer field
        if (j == 2)
          outId.id = layer;

        // Strip component ID (global 1..N) + time
        if (j == 3)
        {
          outId.id = h.stripID;
          outId.time = h.time;
        }

        outId.TimeWindow = id[j].TimeWindow;
        outId.TrackId = id[j].TrackId;

        const double denom = (urwtC.gain * 1e6 * depe / urwtC.w_i);
        outId.id_sharing = (denom > 0.0) ? (h.electrons / denom) : 0.0;
        // cout <<layer<<" "<< h.stripID<< " "<< h.electrons<<" "<<denom<<" "<<outId.id_sharing<< endl;
        yid.push_back(outId);
      }
    }
  };

  auto out = digi.FindStrips(lxyz, depe, c, time);
  pushHits(out);
  /*
     cout<<"LAYER "<<layer<<endl;
     digi.GetStripInfoByStripID(10,globalToLocal);
  */
  return yid;
}

// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit *> urwt_HitProcess ::electronicNoise()
{
  vector<MHit *> noiseHits;

  // first, identify the cells that would have electronic noise
  // then instantiate hit with energy E, time T, identifier IDF:
  //
  // MHit* thisNoiseHit = new MHit(E, T, IDF, pid);

  // push to noiseHits collection:
  // noiseHits.push_back(thisNoiseHit)

  return noiseHits;
}

// - charge: returns charge/time digitized information / step
map<int, vector<double>> urwt_HitProcess ::chargeTime(MHit *aHit, int hitn)
{
  map<int, vector<double>> CT;

  return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double urwt_HitProcess ::voltage(double charge, double time, double forTime)
{
  return 0.0;
}

map<string, vector<int>> urwt_HitProcess ::multiDgt(MHit *aHit, int hitn)
{
  map<string, vector<int>> MH;

  return MH;
}

void urwt_HitProcess::initWithRunNumber(int runno)
{
  string var = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
  string ts = gemcOpt.optMap["DIGITIZATION_TIMESTAMP"].args;
  if (urwtC.runNo != runno ||
      urwtC.digiVariation != var ||
      urwtC.digiSnapshotTime != ts)
  {

    cout << " > Initializing " << HCname
         << " run=" << urwtC.runNo
         << " variation=" << urwtC.digiVariation
         << " timestamp=" << urwtC.digiSnapshotTime
         << endl;

    urwtC = initializeurwtConstants(runno, var, ts, accountForHardwareStatus);
    constantsLoaded = true;

    // INVALIDA CACHE
    digiU_byLayer.clear();
    digiV_byLayer.clear();
  }
}

// this static function will be loaded first thing by the executable
StripConstants urwt_HitProcess::urwtC = initializeurwtConstants(-1);
