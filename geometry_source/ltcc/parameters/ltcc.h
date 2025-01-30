#ifndef LTCC_PARAMETERS_LTCC_LOADED
#define LTCC_PARAMETERS_LTCC_LOADED

const double PI    = 3.141592654;
const double alpha = 1.0/137.0;

const double eMass  = 0.0005;
const double piMass = 0.1396;
const double kMass  = 0.4937;

// mirror geometry
// Parameters of mirror definition p1*x2+p2*y2+p3*xy+p4*x+p5*y+1=0
const int NSEG = 18; // ltcc number of segments
// elliptical mirrors pars
double pe0[5][NSEG];
double el_foci[4][NSEG];


// x11,y11 (in the WC window plane) is the point in OUTER
// WC surface (shield?), nearest to the middle plane
// x12,y12 is the distant edge of elliptic mirror
double x11y11[2][NSEG];
double x12y12[2][NSEG];
double el_center[2][NSEG];
double el_axis[2][NSEG];
double el_alpha[NSEG];
// half of the elliptical width
double hwde[NSEG];

double thetamin[NSEG], theta[NSEG];


// hyperbolic mirror pars
double ph0[5][NSEG];
double hp_foci[4][NSEG];
double hp_min[NSEG];
// COIL plane
// x22,y22 is the distant point of inner surface of WC window.
// x21,y21 defines an edge point for all CC section when discribed
// as a trapezoid. If photon crosses this plane in positive
// direction, it suppose to be absorbed.
double x21y21[2][NSEG];
double x22y22[2][NSEG];
// half of the hiperbolic width
double hwdh[NSEG];

// winstone cone pars in its coordinate system:
// pw0(1)*x**2 + pw0(2)*y**2 + pw0(3)*z**2 + 1 = 0
// where z is along the biggest axis of the ellips.
double pwo[3][NSEG];
// coordinates of WC window center.
double wc0[3][NSEG]; // OLD - DEPRECATED
// coordinates of PMT window center.
double pmt0[3][NSEG];
// WC max radius 
double wcr[NSEG]; // OLD - DEPRECATED
// pmt radius
double pmtr[NSEG];
// distance between two planes in WC.
double dplwc[NSEG]; // OLD - DEPRECATED
// angle between this planes and Segment median plane.
// PLANES ARE DEFINED as p(1)*x + p(2)*y + p(3)*z + 1.0 = 0
double wcang[NSEG];
// cylindrical mirror outer radius
double cyl_r[NSEG];
// shield half lengths (x,y,z)
double shield[3][NSEG];
// shield z-angle
double shieldangz[NSEG];
// shield shift in z direction
double shields[NSEG];
// cylindrical mirror (left) rotation around z
double cyl_L[NSEG];
// cylindrical mirror (right) rotation around z
double cyl_R[NSEG];
// pmt positions in sector
double pmt_sec[3][NSEG];
//shield positions in sector
double shield_pos[6][NSEG];
//mirror positions in sector
double mirror_pos[6][NSEG];
//wc positions in sector
double wc_pos[6][NSEG];

// refractive index of C4F10 is given by Sellmeier equation
// (n-1) 10^6 = p1/(p2^-2 - lambda^-2)
const double p1_S = 0.232; // nm^-2
const double p2_S = 73.63; // nm
// data tables dimension: from 190 nm to 650 nm
const int NP = 46;
// various tables: mirrors reflectivity, pmt q.e., c4f10 transparency
double lambda[NP];
double c4f10n[NP];
double c4f10t[NP];
double stdPmt_qe[NP];
double uvgPmt_qe[NP];
double qtzPmt_qe[NP];
double ltcc_refl[NP];
double ecis_witn[NP];
double ecis_samp[NP];
double wc_bad[NP];
double wc_soso[NP];
double wc_good[NP];



// function dimension
const int NF  = 20;      // points on the function
const int MNP = 12;      // momentum points
const double min_m = 2;  // min momentum
const double max_m = 22;  // max momentum
// absolute yields
double electron_m[MNP];
double electron_n[MNP];
double pion_m[MNP];
double pion_n[MNP];
double kaon_m[MNP];
double kaon_n[MNP];

// 2 dim D2N/DxDlambda photo-electron yields
TF2 *dndxdlFelectron;
TF2 *dndxdlFpion;
TF2 *dndxdlFkaon;

// calculating distance of wall to window
const double NOSEY = 9.39*2.54;     // nose extension size
// no cut
const double WR    = 137.288*2.54;  // radious of window shape
const double WD    = 126.47*2.54;    // distance between nose and wall corner
const double WX0   = WD/2.0;        // X center of radius
const double WY0   = sqrt(WR*WR-WD*WD/4.0); // Y center of radius
// cut LTCC case
const double WD2   = 99.94*2.54;    // distance between nose and leftmost cut
const double WX02   = WD2/2.0;        // X center of radius
const double WY02   = sqrt(WR*WR-WD2*WD2/4.0); // Y center of radius

// window addition volume increase
TF1 *windowMore_nocut_nonose;
TF1 *windowMore_nocut_nose;
TF1 *windowMore_cut_nonose;
TF1 *windowMore_cut_nose;

#endif
