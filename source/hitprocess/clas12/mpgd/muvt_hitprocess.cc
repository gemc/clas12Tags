// gemc headers
#include "muvt_hitprocess.h"

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

std::unordered_map<int, StripDigitizer> muvt_HitProcess::digiU_byLayer;
std::unordered_map<int, StripDigitizer> muvt_HitProcess::digiV_byLayer;

static StripConstants initializemuvtConstants(int runno,
                                              string digiVariation = "default",
                                              string digiSnapshotTime = "no",
                                              bool accountForHardwareStatus = false)
{

  StripConstants muvtC;

  if (runno == -1)
    return muvtC;

  string timestamp = "";
  if (digiSnapshotTime != "no")
  {
    timestamp = ":" + digiSnapshotTime;
  }

  muvtC.runNo = runno;
  muvtC.digiVariation = digiVariation;
  muvtC.digiSnapshotTime = digiSnapshotTime;

  if (getenv("CCDB_CONNECTION") != nullptr)
    muvtC.connection = (string)getenv("CCDB_CONNECTION");
  else
    muvtC.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";

  vector<vector<double>> data;
  std::unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(muvtC.connection));

  // --- Global table
  snprintf(muvtC.database, sizeof(muvtC.database),
           "/test/muvt/muvt_global:%d:%s%s",
           muvtC.runNo, digiVariation.c_str(), timestamp.c_str());

  data.clear();
  calib->GetCalib(data, muvtC.database);

  {
    const int row = 0;
    muvtC.width = data[row][10];                     // mm
    muvtC.pitch = data[row][11];                     // mm
    muvtC.stereoAngleY = data[row][12] * M_PI / 180; // rad
  }

  // --- Digitization table
  snprintf(muvtC.database, sizeof(muvtC.database),
           "/test/muvt/muvt_dgt:%d:%s%s",
           muvtC.runNo, digiVariation.c_str(), timestamp.c_str());

  data.clear();

  calib->GetCalib(data, muvtC.database);

  {
    const int row = 0;
    muvtC.w_i = data[row][0];      // eV
    muvtC.sigma_td = data[row][1]; // mm
    muvtC.gain = data[row][2];
    muvtC.v_drift = data[row][3];    // cm/ns
    muvtC.sigma_time = data[row][4]; // ns
  }

  return muvtC;
}

// ------------------ integrateDgt ------------------

map<string, double> muvt_HitProcess::integrateDgt(MHit *aHit, int hitn)
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
  dgtz["ADC_ADC"] = (1.0 * (int)(muvtC.gain * 1e6 * tInfos.eTot / muvtC.w_i));
  dgtz["ADC_time"] = identity[3].time;
  dgtz["ADC_ped"] = 0;

  if (rejectHitConditions)
    writeHit = false;

  // cout<<"tIntos.eTot "<<tInfos.eTot<<endl;
  // cout<<dgtz["sector"]<<" "<<dgtz["layer"]<<" "<<dgtz["component"]<<" "<<dgtz["ADC_ADC"]<<endl;

  return dgtz;
}

vector<identifier> muvt_HitProcess::processID(vector<identifier> id, G4Step *aStep, detector Detector)
{

  if (muvtC.runNo == -1)
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

  const StripConstants base = muvtC;
  vector<identifier> yid;

  const G4ThreeVector xyz = aStep->GetPostStepPoint()->GetPosition();

  // GLOBAL->LOCAL (utile per strip finding in locale)
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

  int physLayer = 0;
  std::string name = trap->GetName();
  auto pos = name.find("_l");
  if (pos != std::string::npos)
  {
    pos += 2;
    physLayer = std::stoi(name.substr(pos, name.find_first_not_of("0123456789", pos) - pos));
  }

  StripConstants cBase = base;
  cBase.xHalfSmall = trap->GetXHalfLength1();
  cBase.xHalfLarge = trap->GetXHalfLength2();
  cBase.yHalf = trap->GetYHalfLength1();
  cBase.zHalf = trap->GetZHalfLength();
  cBase.zReadoutLocal = 0.0;

  auto pushHits = [&](const std::vector<StripHit> &hits, int viewId /*1=U,2=V*/)
  {
    if (hits.empty())
      return;

    const double denom = (muvtC.gain * 1e6 * depe / muvtC.w_i);

    for (const auto &h : hits)
    {
      for (int j = 0; j < 4; ++j)
      {
        identifier outId;
        outId.name = id[j].name;
        outId.rule = id[j].rule;

        // j=0 region ; j=1 sector
        if (j == 0 || j == 1)
          outId.id = id[j].id;

        // j=2 layer:

        if (j == 2)
          outId.id = viewId;

        // j=3 component: stripID e tempo
        if (j == 3)
        {
          outId.id = h.stripID;
          outId.time = h.time;
        }

        outId.TimeWindow = id[j].TimeWindow;
        outId.TrackId = id[j].TrackId;

        outId.id_sharing = (denom > 0.0) ? (h.electrons / denom) : 0.0;

        yid.push_back(outId);
      }
    }
  };

  // ---  U (stereo +)
  {
    auto &digiU = digiU_byLayer[physLayer]; // ok anche se physLayer=1 sempre
    StripConstants cU = cBase;
    cU.SetStripParams(+base.stereoAngleY, base.pitch, base.width);

    auto hitsU = digiU.FindStrips(lxyz, depe, cU, time);

    // cout<<"LAYER "<<physLayer<<endl;
    //  digiU.GetStripInfoByStripID(10,globalToLocal);
    pushHits(hitsU, /*viewId=*/1);
  }

  // ---  V (stereo -)
  {
    auto &digiV = digiV_byLayer[physLayer + 1];
    StripConstants cV = cBase;
    cV.SetStripParams(-base.stereoAngleY, base.pitch, base.width);

    auto hitsV = digiV.FindStrips(lxyz, depe, cV, time);
    // cout<<"LAYER "<<physLayer+1<<endl;
    //  digiV.GetStripInfoByStripID(10,globalToLocal);
    pushHits(hitsV, 2);
  }

  return yid;
}

// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit *> muvt_HitProcess ::electronicNoise()
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
map<int, vector<double>> muvt_HitProcess ::chargeTime(MHit *aHit, int hitn)
{
  map<int, vector<double>> CT;

  return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double muvt_HitProcess ::voltage(double charge, double time, double forTime)
{
  return 0.0;
}

map<string, vector<int>> muvt_HitProcess ::multiDgt(MHit *aHit, int hitn)
{
  map<string, vector<int>> MH;

  return MH;
}

void muvt_HitProcess::initWithRunNumber(int runno)
{
  string var = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
  string ts = gemcOpt.optMap["DIGITIZATION_TIMESTAMP"].args;

  if (muvtC.runNo != runno ||
      muvtC.digiVariation != var ||
      muvtC.digiSnapshotTime != ts)
  {

    cout << " > Initializing " << HCname
         << " run=" << runno
         << " variation=" << var
         << " timestamp=" << ts
         << endl;

    muvtC = initializemuvtConstants(runno, var, ts, accountForHardwareStatus);
    constantsLoaded = true;

    digiU_byLayer.clear();
    digiV_byLayer.clear();
  }
}

// this static function will be loaded first thing by the executable
StripConstants muvt_HitProcess::muvtC = initializemuvtConstants(1);
