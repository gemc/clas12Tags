#include "StripDigitizer.h"

#include <cmath>
#include <algorithm>
#include <iostream>
#include <iomanip>

#include "CLHEP/Random/RandGaussQ.h"
#include "CLHEP/Random/RandPoissonQ.h"
#include "CLHEP/Random/RandBinomial.h"
#include "CLHEP/Units/PhysicalConstants.h"

using namespace CLHEP;

// ---------------- Trap2D ----------------

// Build the trapezoid cross-section on the READOUT plane (z = zReadoutLocal).
// The trapezoid is defined in the GAS local frame:
//  - y = -yHalf: small base (xHalfSmall)s
//  - y = +yHalf: large base (xHalfLarge)
StripDigitizer::Trap2D StripDigitizer::Trap2D::FromConstants(const StripConstants &c)
{
    Trap2D t;
    const double z = c.zReadoutLocal;
    t.bl = {-c.xHalfSmall, -c.yHalf, z};
    t.br = {c.xHalfSmall, -c.yHalf, z};
    t.tl = {-c.xHalfLarge, c.yHalf, z};
    t.tr = {c.xHalfLarge, c.yHalf, z};

    /*
    cout << "[Trap2D::FromConstants] Readout plane z = " << z / mm << " mm\n"
           << "  bl = (" << t.bl.x() / mm << ", " << t.bl.y() / mm << ", " << t.bl.z() / mm << ") mm\n"
           << "  br = (" << t.br.x() / mm << ", " << t.br.y() / mm << ", " << t.br.z() / mm << ") mm\n"
           << "  tl = (" << t.tl.x() / mm << ", " << t.tl.y() / mm << ", " << t.tl.z() / mm << ") mm\n"
           << "  tr = (" << t.tr.x() / mm << ", " << t.tr.y() / mm << ", " << t.tr.z() / mm << ") mm\n";
    */
    return t;
}

// Return the 4 trapezoid edges as line segments
std::array<std::pair<G4ThreeVector, G4ThreeVector>, 4> StripDigitizer::Trap2D::edges() const
{
    return {{{bl, br},
             {br, tr},
             {tr, tl},
             {tl, bl}}};
}

// Intersect segment AB with line in normal form: n·(x,y)=rhs
bool StripDigitizer::IntersectEdgeWithLineNormal(const G4ThreeVector &A,
                                                 const G4ThreeVector &B,
                                                 const G4ThreeVector &n_xy,
                                                 double rhs,
                                                 G4ThreeVector &out)
{
    const double Ax = A.x(), Ay = A.y();
    const double Bx = B.x(), By = B.y();

    const double nA = n_xy.x() * Ax + n_xy.y() * Ay;
    const double nB = n_xy.x() * Bx + n_xy.y() * By;
    const double denom = (nB - nA);

    if (std::fabs(denom) < 1e-9)
        return false;

    const double t = (rhs - nA) / denom;
    if (t < 0.0 || t > 1.0)
        return false;

    out = A + t * (B - A);
    return true;
}

// ---------------- Strip frame (stereoAngle w.r.t Y) ----------------

// stereoAngle = angle of strip direction measured from +Y toward +X.
// strip direction unit u = (sin a, cos a)
// perpendicular (pitch direction) v = (cos a, -sin a)
//
// x_s = u·(x,y)  (along strip)
// y_s = v·(x,y)  (perpendicular to strip, pitch direction)
std::pair<double, double> StripDigitizer::ToStripFrameXY(double x, double y,
                                                         const StripConstants &c)
{
    const double a = c.stereoAngle;
    const double sa = std::sin(a);
    const double ca = std::cos(a);

    const double xs = sa * x + ca * y;
    const double ys = ca * x - sa * y;

    return {xs, ys};
}

G4ThreeVector StripDigitizer::ToStripFrame(const G4ThreeVector &p,
                                           const StripConstants &c)
{
    auto [xs, ys] = ToStripFrameXY(p.x(), p.y(), c);
    return {xs, ys, p.z()};
}

// Weight = integral of 2D Gaussian over strip rectangle in strip frame.
double StripDigitizer::WeightFraction(const StripGeom &s,
                                      const G4ThreeVector &hit_s,
                                      const StripConstants &c)
{
    const double sig = c.sigma_td;
    if (sig <= 0.0)
        return 0.0;

    // Along strip: x_s, across strip: y_s
    const double dx1 = (s.centerXs - s.halfLenXs) - hit_s.x();
    const double dx2 = (s.centerXs + s.halfLenXs) - hit_s.x();
    const double dy1 = (s.centerYs - 0.5 * c.width) - hit_s.y();
    const double dy2 = (s.centerYs + 0.5 * c.width) - hit_s.y();

    auto Erf = [&](double u)
    { return std::erf(u / (std::sqrt(2.0) * sig)); };

    const double wx = 0.5 * (Erf(dx2) - Erf(dx1));
    const double wy = 0.5 * (Erf(dy2) - Erf(dy1));

    const double w = wx * wy;
    return (w > 0.0) ? w : 0.0;
}

// Build the strip segment inside the trapezoid for a given mathematical index.
// A strip is defined as the line of constant y_s in strip frame:
//   y_s = (idx + 0.5) * pitch
// Since y_s = v·(x,y) with v=(cos a, -sin a), the strip line in local XY is:
//   cos(a)*x - sin(a)*y = rhs
//
// We intersect this infinite line with the 4 trapezoid edges and keep the two
// farthest intersection points as the segment endpoints
bool StripDigitizer::BuildStripSegment(int internalIndex,
                                       const StripConstants &c,
                                       G4ThreeVector &out_p1,
                                       G4ThreeVector &out_p2) const
{
    const Trap2D tr = Trap2D::FromConstants(c);

    const double a = c.stereoAngle;
    const double sa = std::sin(a);
    const double ca = std::cos(a);

    const G4ThreeVector n_xy(ca, -sa, 0.0);
    const double rhs = (internalIndex + 0.5) * c.pitch;

    std::vector<G4ThreeVector> inters;
    inters.reserve(4);

    for (const auto &e : tr.edges())
    {
        G4ThreeVector P;
        if (IntersectEdgeWithLineNormal(e.first, e.second, n_xy, rhs, P))
            inters.push_back(P);
    }

    if (inters.size() < 2)
        return false;

    double bestD2 = -1.0;
    size_t iBest = 0, jBest = 1;
    for (size_t i = 0; i < inters.size(); ++i)
        for (size_t j = i + 1; j < inters.size(); ++j)
        {
            const double d2 = (inters[j] - inters[i]).mag2();
            if (d2 > bestD2)
            {
                bestD2 = d2;
                iBest = i;
                jBest = j;
            }
        }

    out_p1 = inters[iBest];
    out_p2 = inters[jBest];
    return true;
}

// ---------------- Cache ----------------

static inline bool eq(double a, double b, double eps = 1e-12)
{
    return std::fabs(a - b) < eps;
}

bool StripDigitizer::SameSignature(const StripConstants &c) const
{
    return eq(sig.pitch, c.pitch) &&
           eq(sig.width, c.width) &&
           eq(sig.stereoAngle, c.stereoAngle) &&
           eq(sig.xHalfSmall, c.xHalfSmall) &&
           eq(sig.xHalfLarge, c.xHalfLarge) &&
           eq(sig.yHalf, c.yHalf) &&
           eq(sig.zReadoutLocal, c.zReadoutLocal);
}

void StripDigitizer::EnsureCache(const StripConstants &c)
{
    /*
            if (!cacheBuilt) {
            std::cout << "EnsureCache: cacheBuilt=false (nuovo digitizer)\n";
        } else if (!SameSignature(c)) {
            std::cout << "EnsureCache: SameSignature=false (signature cambiata)\n";
            std::cout << std::setprecision(17)
                      << " old xHalfSmall=" << sig.xHalfSmall << " new=" << c.xHalfSmall << "\n"
                      << " old xHalfLarge=" << sig.xHalfLarge << " new=" << c.xHalfLarge << "\n"
                      << " old yHalf="      << sig.yHalf      << " new=" << c.yHalf      << "\n"
                      << " old angle="      << sig.stereoAngle<< " new=" << c.stereoAngle<< "\n";
        }
    */
    if (!cacheBuilt || !SameSignature(c))
    {
        sig.pitch = c.pitch;
        sig.width = c.width;
        sig.stereoAngle = c.stereoAngle;
        sig.xHalfSmall = c.xHalfSmall;
        sig.xHalfLarge = c.xHalfLarge;
        sig.yHalf = c.yHalf;
        sig.zReadoutLocal = c.zReadoutLocal;

        BuildCache(c);
        cacheBuilt = true;
    }
}

/*
  BuildCache()

  Precompute the full strip geometry on the readout plane and assign stable strip IDs.

  - The trapezoid cross-section is built in the GAS local frame on the readout plane
  - Candidate strip indices are scanned using the range of the trapezoid corners in strip frame
    (y_s is the coordinate perpendicular to strips, i.e. the pitch direction).
  - For each candidate index, the strip segment is obtained by intersecting the strip line with
    the trapezoid edges; indices that do not intersect are skipped.
  - Endpoints are stored both in GAS local coordinates (used by physics) and in GLOBAL coordinates
    (useful for debugging/visualization).
  - Strip IDs (1..N) are assigned by sorting strips using the LOCAL X coordinate of their midpoint:
      stripID=1 corresponds to the most negative local X strip midpoint.
  - Cached strip-frame quantities (centerXs/centerYs/halfLenXs) are computed to speed up
    charge-sharing weight calculations during digitization.
*/
void StripDigitizer::BuildCache(const StripConstants &c)
{
    strips.clear();
    idxToID.clear();
    cacheVersion++;
    /*

           std::cout << "\n=== Rebuilding strip cache ===\n"
                  << " cacheVersion = " << cacheVersion << "\n"
                  << " pitch        = " << c.pitch << "\n"
                  << " width        = " << c.width << "\n"
                  << " stereoAngle  = " << c.stereoAngle << "\n"
                  << " xHalfSmall   = " << c.xHalfSmall << "\n"
                  << " xHalfLarge   = " << c.xHalfLarge << "\n"
                  << " yHalf        = " << c.yHalf << "\n"
                  << " zReadoutLoc  = " << c.zReadoutLocal << "\n"
                  << std::endl;
    */

    const Trap2D tr = Trap2D::FromConstants(c);

    auto cornerYs = [&](const G4ThreeVector &p)
    {
        auto [xs, ys] = ToStripFrameXY(p.x(), p.y(), c);
        (void)xs;
        return ys;
    };

    const double ys1 = cornerYs(tr.bl);
    const double ys2 = cornerYs(tr.br);
    const double ys3 = cornerYs(tr.tl);
    const double ys4 = cornerYs(tr.tr);

    const double ysMin = std::min({ys1, ys2, ys3, ys4});
    const double ysMax = std::max({ys1, ys2, ys3, ys4});

    const int iMin = static_cast<int>(std::floor(ysMin / c.pitch)) - 2;
    const int iMax = static_cast<int>(std::ceil(ysMax / c.pitch)) + 2;

    std::vector<StripGeom> tmp;
    tmp.reserve(iMax - iMin + 1);

    for (int idx = iMin; idx <= iMax; ++idx)
    {
        G4ThreeVector p1_local, p2_local;
        if (!BuildStripSegment(idx, c, p1_local, p2_local))
            continue;

        StripGeom s;
        s.internalIndex = idx;

        // Store endpoints in GAS local frame (on readout plane z=zReadoutLocal).
        s.p1_local = p1_local;
        s.p2_local = p2_local;

        const G4ThreeVector mid_l = 0.5 * (s.p1_local + s.p2_local);
        s.orderX_local = mid_l.x(); // <-- local ordering key

        // Cache rectangle info in strip frame for fast weight evaluation.
        // In strip frame: x_s along strip direction, y_s across strip (pitch direction).
        const auto [x1s, y1s] = ToStripFrameXY(s.p1_local.x(), s.p1_local.y(), c);
        const auto [x2s, y2s] = ToStripFrameXY(s.p2_local.x(), s.p2_local.y(), c);

        s.centerXs = 0.5 * (x1s + x2s);
        s.centerYs = 0.5 * (y1s + y2s);
        s.halfLenXs = 0.5 * std::sqrt((x2s - x1s) * (x2s - x1s) +
                                      (y2s - y1s) * (y2s - y1s));

        tmp.push_back(s);
    }

    // Local numbering: stripID=1 is the strip with the most negative LOCAL X midpoint.
    std::sort(tmp.begin(), tmp.end(),
              [](const StripGeom &a, const StripGeom &b)
              {
                  if (a.orderX_local != b.orderX_local)
                      return a.orderX_local < b.orderX_local;
                  return a.internalIndex < b.internalIndex; // stable tie-breaker
              });

    strips.reserve(tmp.size());
    for (size_t i = 0; i < tmp.size(); ++i)
    {
        tmp[i].stripID = static_cast<int>(i) + 1;
        idxToID[tmp[i].internalIndex] = tmp[i].stripID;
        strips.push_back(tmp[i]);
    }
    /*

            std::cout << "--- Dumping strips (cacheVersion "
                      << cacheVersion << ") ---\n";


            for (const auto& s : strips)
            {
                std::cout << "stripID=" << s.stripID
                          << " internalIndex=" << s.internalIndex
                          << " p1=(" << s.p1_local.x()
                          << "," << s.p1_local.y()
                          << "," << s.p1_local.z() << ")"
                          << " p2=(" << s.p2_local.x()
                          << "," << s.p2_local.y()
                          << "," << s.p2_local.z() << ")"
                          << "\n";
            }
        */
}

// ---------------- Digitization ----------------

std::vector<StripHit> StripDigitizer::FindStrips(const G4ThreeVector &localPos,
                                                 double Edep,
                                                 const StripConstants &c,
                                                 double t0)
{
    EnsureCache(c);

    std::vector<StripHit> out;
    if (Edep <= 0.0)
        return out;

    // primary electrons
    const double n_mean = (Edep / eV) / c.w_i;
    if (n_mean <= 0.0)
        return out;

    const int n_prim = std::max(0, (int)RandPoissonQ::shoot(n_mean));
    const int n_e = std::max(0, (int)RandPoissonQ::shoot(n_prim * c.gain));
    if (n_e == 0)
        return out;

    // drift time to readout plane zReadoutLocal
    const double dz_cm = std::fabs((c.zReadoutLocal / cm) - (localPos.z() / cm));
    const double t_drift = dz_cm / c.v_drift;

    const G4ThreeVector hit_s = ToStripFrame(localPos, c);

    // IMPORTANT: pitch direction is y_s (perpendicular to strips)
    const int i0 = static_cast<int>(std::floor(hit_s.y() / c.pitch));

    const int window = 10;
    std::vector<std::pair<int, double>> weights;
    weights.reserve(2 * window + 1);

    for (int di = -window; di <= window; ++di)
    {

        const int internal = i0 + di;
        auto it = idxToID.find(internal);
        if (it == idxToID.end())
            continue;
        const int stripID = it->second;
        const StripGeom &sg = strips[stripID - 1];

        const double w = WeightFraction(sg, hit_s, c);
        if (w > 0.0)
            weights.emplace_back(stripID, w);
    }

    if (weights.empty())
        return out;

    double sumw = 0.0;
    for (const auto &p : weights)
        sumw += p.second;
    if (sumw <= 0.0)
        return out;

    int remaining = n_e;

    for (size_t i = 0; i < weights.size(); ++i)
    {
        const int stripID = weights[i].first;
        const double w = weights[i].second;

        int n_assigned = 0;
        if (i + 1 < weights.size())
        {
            double p = w / sumw;
            if (p < 0.0)
                p = 0.0;
            if (p > 1.0)
                p = 1.0;

            n_assigned = RandBinomial::shoot(remaining, p);
            remaining -= n_assigned;
            sumw -= w;
        }
        else
        {
            n_assigned = remaining;
        }

        if (n_assigned <= 0)
            continue;

        StripHit h;
        h.stripID = stripID;
        h.electrons = n_assigned;
        h.time = t0 + t_drift + RandGauss::shoot(0.0, c.sigma_time);

        out.push_back(h);
    }

    return out;
}

int StripDigitizer::GetNumberOfStrips(const StripConstants &c,
                                      const G4AffineTransform &globalToLocal)
{
    EnsureCache(c);
    return static_cast<int>(strips.size());
}

void StripDigitizer::DumpStripsDebug(std::ostream &os,
                                     int layer,
                                     const G4AffineTransform &globalToLocal) const
{
    os << "=== Strip cache dump for layer " << layer << " ===\n";
    os << "Nstrips=" << strips.size() << "\n";

    G4AffineTransform localToGlobal = globalToLocal.Inverse();

    for (const auto &s : strips)
    {
        G4ThreeVector p1g = localToGlobal.TransformPoint(s.p1_local);
        G4ThreeVector p2g = localToGlobal.TransformPoint(s.p2_local);

        os << "stripID=" << s.stripID
           << " internalIndex=" << s.internalIndex
           << "  p1_local=(" << s.p1_local.x() << "," << s.p1_local.y() << "," << s.p1_local.z() << ")"
           << "  p2_local=(" << s.p2_local.x() << "," << s.p2_local.y() << "," << s.p2_local.z() << ")"
           << "  p1_global=(" << p1g.x() << "," << p1g.y() << "," << p1g.z() << ")"
           << "  p2_global=(" << p2g.x() << "," << p2g.y() << "," << p2g.z() << ")"
           << "\n";
    }
}

void StripDigitizer::GetStripInfoByStripID(int stripID,
                                           const G4AffineTransform &globalToLocal)
{
    G4AffineTransform localToGlobal = globalToLocal.Inverse();
    for (const auto &s : strips)
    {
        if (s.stripID == stripID)
        {
            G4ThreeVector p1g = localToGlobal.TransformPoint(s.p1_local);
            G4ThreeVector p2g = localToGlobal.TransformPoint(s.p2_local);

            cout << "stripID=" << s.stripID
                 << " internalIndex=" << s.internalIndex
                 << "  p1_local=(" << s.p1_local.x() << "," << s.p1_local.y() << "," << s.p1_local.z() << ")"
                 << "  p2_local=(" << s.p2_local.x() << "," << s.p2_local.y() << "," << s.p2_local.z() << ")"
                 << "  p1_global=(" << p1g.x() << "," << p1g.y() << "," << p1g.z() << ")"
                 << "  p2_global=(" << p2g.x() << "," << p2g.y() << "," << p2g.z() << ")"
                 << "\n";
        }
    }
}
