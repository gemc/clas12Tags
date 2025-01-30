#include "../parameters/ltcc.h"
#include "io.h"
#include "vars.h"
#include <TF1.h>
#include <TF2.h>
#include <fstream>
#include <iomanip>

using std::ifstream;
using std::ofstream;
using std::string;

// read parameters from files

string stringify(double x) {
  ostringstream o;
  o << x;
  return o.str();
}
string stringify(int x) {
  ostringstream o;
  o << x;
  return o.str();
}

void init_parameters() {
  ifstream in("parameters/ccngeom.dat");
  // reading ellipse parameters
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 5; p++) {
      in >> pe0[p][s];
    }
  }

  // reading hyperbola parameters
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 5; p++) {
      in >> ph0[p][s];
    }
  }

  double dummy;
  // winston cones and pmts
  for (int s = 0; s < NSEG; s++) {
    in >> dummy >> wc0[0][s] >> wc0[1][s] >> pmt0[0][s] >> pmt0[1][s] >>
        wcr[s] >> pmtr[s] >> dplwc[s] >> wcang[s]  >> cyl_r[s] >> shield[0][s] >> shield[1][s] >> shield[2][s] >> 
	shieldangz[s] >> shields[s] >> cyl_L[s] >> cyl_R[s] >> pmt_sec[0][s] >> pmt_sec[1][s] >> pmt_sec[2][s];
    wc0[2][s] = 0;
    pmt0[2][s] = 0;
  }

  for (int s = 0; s < NSEG; s++) {
     for (int p = 0; p < 6; p++) {
      in >> shield_pos[p][s];
     }
    
  }

  for (int s = 0; s < NSEG; s++) {
     for (int p = 0; p < 6; p++) {
      in >> mirror_pos[p][s];
     }
    
  }

   for (int s = 0; s < NSEG; s++) {
     for (int p = 0; p < 6; p++) {
      in >> wc_pos[p][s];
     }
    
  }

  // PMT, ell. edges
  // THESE are recalculated in Alex routine so no need to store them
  // Reading them anyway
  for (int s = 0; s < NSEG; s++) {
    in >> x11y11[0][s] >> x11y11[1][s] >> x12y12[0][s] >> x12y12[1][s];
  }

  // redefining y11 here
  x11y11[1][0] = 493.552;
  x11y11[1][1] = 491.283;
  x11y11[1][2] = 486.884;
  x11y11[1][3] = 483.772;
  x11y11[1][4] = 479.522;
  x11y11[1][5] = 475.046;
  x11y11[1][6] = 471.254;
  x11y11[1][7] = 467.854;
  x11y11[1][8] = 465.462;
  x11y11[1][9] = 463.461;
  x11y11[1][10] = 464.269;
  x11y11[1][11] = 460.85;
  x11y11[1][12] = 461.68;
  x11y11[1][13] = 460.678;
  x11y11[1][14] = 456.161;
  x11y11[1][15] = 451.584;
  x11y11[1][16] = 446.927;
  x11y11[1][17] = 441.409;

  // hpmins are hardcoded
  hp_min[0] = 0.;
  hp_min[1] = 0.;
  hp_min[2] = 6.7;
  hp_min[3] = 12.7;
  hp_min[4] = 20.6;
  hp_min[5] = 27.3;
  hp_min[6] = 33.2;
  hp_min[7] = 37.7;
  hp_min[8] = 44.0;
  hp_min[9] = 45.2;
  hp_min[10] = 49.0;
  hp_min[11] = 51.7;
  hp_min[12] = 55.8;
  hp_min[13] = 59.6;
  hp_min[14] = 63.1;
  hp_min[15] = 64.8;
  hp_min[16] = 68.0;
  hp_min[17] = 75.6;

  // coil, yp. edges
  for (int s = 0; s < NSEG; s++) {
    in >> x21y21[0][s] >> x21y21[1][s] >> x22y22[0][s] >> x22y22[1][s];
  }

  // thicknesses
  for (int s = 0; s < NSEG; s++) {
    in >> hwde[s] >> hwdh[s] >> dummy >> dummy >> dummy >> dummy >> dummy >>
        dummy >> dummy >> dummy >> dummy;
  }

  for (int s = 0; s < NSEG; s++) {
    in >> dummy >> thetamin[s] >> theta[s] >> dummy >> dummy >> dummy >> dummy;
  }

  // theta

  // end of file
  in.close();

  // filling c4f10 refraction index using Sellmeier equaion
  for (int i = 0; i < NP; i++) {
    lambda[i] = 190.0 + i * 10.0;
    c4f10n[i] = 1.0 + pow(10, -6) * p1_S / (pow(p2_S, -2) - pow(lambda[i], -2));

    // uncomment below for quartz radiator
    //		double l = lambda[i]/1000.0;
    //		c4f10n[i]  = sqrt(1.28604141 + (1.07044083*l*l)/(l*l-0.0100585997) +
    //(1.10202242*l*l)/(l*l-100));
  }

  // read PMT quantum efficiency
  double tmpL;
  in.open("parameters/pmt_qe.txt");
  for (int i = 0; i < NP; i++) {
    in >> tmpL >> stdPmt_qe[i] >> uvgPmt_qe[i] >> qtzPmt_qe[i];
    if (lambda[i] != tmpL) {
      cout << " Error: lambda from file is " << tmpL << " but should be "
           << lambda[i] << endl;
    }
  }
  in.close();

  // read C4F10 transparency
  in.open("parameters/c4f10_tr.txt");
  for (int i = 0; i < NP; i++) {
    in >> c4f10t[i];
  }
  in.close();

  // read Mirrors reflectivities
  in.open("parameters/mirrors_refl.txt");
  for (int i = 0; i < NP; i++) {
    in >> tmpL >> ltcc_refl[i] >> ecis_witn[i] >> ecis_samp[i];

    //		ltcc_refl[i] -= 0.1;
    //		ecis_samp[i] -= 0.1;
    if (lambda[i] != tmpL) {
      cout << " Error: lambda from file is " << tmpL << " but should be "
           << lambda[i] << endl;
    }
  }
  in.close();

  // read WC reflectivities
  in.open("parameters/wc_refl.txt");
  for (int i = 0; i < NP; i++) {
    in >> tmpL >> wc_good[i] >> wc_soso[i] >> wc_bad[i];

    if (lambda[i] != tmpL) {
      cout << " Error: lambda from file is " << tmpL << " but should be "
           << lambda[i] << endl;
    }
  }
  in.close();

  dndxdlFpion = new TF2("dndxdlFpion", dndxdl, 180, 660, min_m, max_m, 5);
  dndxdlFpion->SetNpx(NF);
  dndxdlFpion->SetNpy(NF);
  dndxdlFpion->SetParameter(0, piMass);
  dndxdlFpion->SetParameter(1, 0);
  dndxdlFpion->SetParameter(2, 0);
  dndxdlFpion->SetParameter(3, 0);

  dndxdlFelectron =
      new TF2("dndxdlFelectron", dndxdl, 180, 660, min_m, max_m, 5);
  dndxdlFelectron->SetNpx(NF);
  dndxdlFelectron->SetNpy(NF);
  dndxdlFelectron->SetParameter(0, eMass);
  dndxdlFelectron->SetParameter(1, 0);
  dndxdlFelectron->SetParameter(2, 0);
  dndxdlFelectron->SetParameter(3, 0);

  dndxdlFkaon = new TF2("dndxdlFkaon", dndxdl, 180, 660, min_m, max_m, 5);
  dndxdlFkaon->SetNpx(NF);
  dndxdlFkaon->SetNpy(NF);
  dndxdlFkaon->SetParameter(0, kMass);
  dndxdlFkaon->SetParameter(1, 0);
  dndxdlFkaon->SetParameter(2, 0);
  dndxdlFkaon->SetParameter(3, 0);

  windowMore_nocut_nonose = new TF1("windowy", windowy, -20, 280, 2);
  windowMore_nocut_nonose->SetParameter(0, 0.0);
  windowMore_nocut_nonose->SetParameter(1, 0.0);
  windowMore_nocut_nonose->SetLineColor(kBlack);

  windowMore_nocut_nose = new TF1("windowy", windowy, -20, 280, 2);
  windowMore_nocut_nose->SetParameter(0, 0.0);
  windowMore_nocut_nose->SetParameter(1, 1.0);
  windowMore_nocut_nose->SetLineColor(kRed);

  windowMore_cut_nonose = new TF1("windowy", windowy, -20, 280, 2);
  windowMore_cut_nonose->SetParameter(0, 1.0);
  windowMore_cut_nonose->SetParameter(1, 0.0);
  windowMore_cut_nonose->SetLineColor(kBlue);

  windowMore_cut_nose = new TF1("windowy", windowy, -20, 280, 2);
  windowMore_cut_nose->SetParameter(0, 1.0);
  windowMore_cut_nose->SetParameter(1, 1.0);
  windowMore_cut_nose->SetLineColor(kGreen);

  double dmom = (max_m - min_m) / MNP;

  for (int i = 0; i < MNP; i++) {
    electron_m[i] = min_m + i * dmom;
    pion_m[i] = min_m + i * dmom;
    kaon_m[i] = min_m + i * dmom;
  }
}

void write_parameters() {
  string fname = "ltcc__parameters_" + variation + ".txt";

  ofstream OUT(fname.c_str());
  OUT.setf(ios::left);

  // ellipse implicit equation pars
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 5; p++) {
      // par name
      OUT << "ltcc.elpars.s" << s + 1 << ".p";
      OUT.width(4);
      OUT << p << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << pe0[p][s] << "\t | cm | ellipse segment " << s + 1
          << " parameter p";
      OUT.width(4);
      OUT << p << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // hyperbola implicit equation pars
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 5; p++) {
      // par name
      OUT << "ltcc.hypars.s" << s + 1 << ".p";
      OUT.width(4);
      OUT << p << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << ph0[p][s] << "\t | cm | hyperbola segment " << s + 1
          << " parameter p";
      OUT.width(4);
      OUT << p << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // ellipse span points
  string spoints[2] = {"x12", "y12"};
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 2; p++) {
      // par name
      OUT << "ltcc.el.s" << s + 1 << "_" << spoints[p] << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << x12y12[p][s] << "\t | cm | ellipse span point " << s + 1
          << " parameter " << spoints[p] << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // hyperbola edge point for all CC section
  string epoints[2] = {"x21", "y21"};
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 2; p++) {
      // par name
      OUT << "ltcc.hy.s" << s + 1 << "_" << epoints[p] << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << x21y21[p][s] << "\t | cm | hyperbola edge points  " << s + 1
          << " parameter " << epoints[p] << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // hyperbola x minimum
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.hy.s" << s + 1 << "_xmin"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << hp_min[s] << "\t | degrees | yperbola x minimum of mirror " << s + 1
        << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  // PMT, ell. edges
  string ppoints[2] = {"x11", "y11"};
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 2; p++) {
      // par name
      OUT << "ltcc.el.s" << s + 1 << "_" << ppoints[p] << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << x11y11[p][s] << "\t | cm | PMT, ell. edges " << s + 1
          << " parameter " << ppoints[p] << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // segment theta min, theta
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.s" << s + 1 << "_theta"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << theta[s] << "\t | degrees | ell. theta at midline of mirror "
        << s + 1 << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  // ell. mirror widths
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.el.s" << s + 1 << "_width"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << hwde[s] << "\t | cm | width of ell. mirror  " << s + 1 << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  // hyp. mirror widths
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.hy.s" << s + 1 << "_width"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << hwdh[s] << "\t | cm | width of hyp. mirror  " << s + 1 << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  // PMT center
  string pmptcenter[2] = {"pmt0x", "pmt0y"};
  for (int s = 0; s < NSEG; s++) {
    for (int p = 0; p < 2; p++) {
      // par name
      OUT << "ltcc.pmt.s" << s + 1 << "_" << pmptcenter[p] << "\t | ";

      // par value, units, comment
      OUT.width(14);
      OUT << pmt0[p][s] << "\t | cm | PMT center for " << s + 1
          << ", coordinate  " << pmptcenter[p] << "\t | ";

      // author, emails
      OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 3/10/12";

      OUT << endl;
    }
  }

  // PMT radius
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.pmt.s" << s + 1 << "_radius"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << pmtr[s] << "\t | cm | PMT Radius (all PMTs are 5')  " << s + 1
        << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  // WC angle
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.wc.s" << s + 1 << "_angle"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << wcang[s] << "\t | degrees | Winston Cone Angle  " << s + 1 << " \t | ";

    // author, emails
    OUT << " vlassov, ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/10/12";

    OUT << endl;
  }

  
  // cylindrical mirror outer radius
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.cyl.s" << s + 1 << "_router"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << cyl_r[s] << "\t | cm | cylindrical mirror outer radius  " << s + 1 << " \t | ";

    // author, emails
    OUT << " duran | bduran@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 3/2/17";

    OUT << endl;
  }
  
  // shield dimensions (shield is centered around PMT face)
  string shielddim[3] = {"dx", "dy", "dz"};
  for (int s = 0; s < NSEG; s++) {
    // loop over x,y,z and z-angle
    for (int p = 0; p < 4; p++) {
      // x,y,z
      if (p < 3) {
        // par name
        OUT << "ltcc.shield.s" << s + 1 << "_" << shielddim[p] << "\t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << shield[p][s] << "\t | cm | shield dimensions for " << s + 1
            << ", coordinate  " << shielddim[p] << "\t | ";
      // z-angle
      } else {
        // par name
        OUT << "ltcc.shield.s" << s + 1 << "_zangle \t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << shield[p][s] << "\t | degrees | shield z angle for " << s + 1
            << "\t | ";
      }

      // author, emails
      OUT << " duran, joosten | bduran@jlab.org, sjjooste@jlab.org | ";

      // link to drawings, name, date
      OUT << " none | none | 10/20/16";

      OUT << endl;
    }
  }

  // shift in shield's z direction
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.shield.s" << s + 1 << "_shift"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << shields[s] << "\t | cm | shield shift in z direction  " << s + 1 << " \t | ";

    // author, emails
    OUT << " duran | bduran@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 1/22/16";

    OUT << endl;
  }

  // cylindrical mirror (left) rotation around z 
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.cyl.s" << s + 1 << "_leftAngle"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << cyl_L[s] << "\t | cm | cylindrical mirror(left) rotation around z  " << s + 1 << " \t | ";

    // author, emails
    OUT << " duran | bduran@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 2/19/16";

    OUT << endl;
  }

 // cylindrical mirror (right) rotation around z 
  for (int s = 0; s < NSEG; s++) {
    // par name
    OUT << "ltcc.cyl.s" << s + 1 << "_rightAngle"
        << "\t | ";

    // par value, units, comment
    OUT.width(14);
    OUT << cyl_R[s] << "\t | cm | cylindrical mirror(right) rotation around z  " << s + 1 << " \t | ";

    // author, emails
    OUT << " duran | bduran@jlab.org | ";

    // link to drawings, name, date
    OUT << " none | none | 2/19/16";

    OUT << endl;
  }

 // pmt positions in sector
  string pmtpos[3] = {"x", "y", "z"};
  for (int s = 0; s < NSEG; s++) {
    
    for (int p = 0; p < 3; p++) {
    
        // par name
        OUT << "ltcc.pmt.s" << s + 1 << "_" << pmtpos[p] << "\t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << pmt_sec[p][s] << "\t | cm | pmt positions  " << s + 1 << "\t | ";
        // author, emails
      	OUT << " duran, joosten | bduran@jlab.org, sjjooste@jlab.org | ";

      	// link to drawings, name, date
      	OUT << " none | none | 10/20/16";

      	OUT << endl;
      }	
 
  }

  // shield positions in sector
  string shieldpos[6] = {"xR", "yR", "zR", "xL", "yL", "zL"};
  for (int s = 0; s < NSEG; s++) {
    
    for (int p = 0; p < 6; p++) {
    
        // par name
        OUT << "ltcc.shield.s" << s + 1 << "_" << shieldpos[p] << "\t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << shield_pos[p][s] << "\t | cm | shield positions  " << s + 1 << "\t | ";
        // author, emails
      	OUT << " duran, joosten | bduran@jlab.org, sjjooste@jlab.org | ";

      	// link to drawings, name, date
      	OUT << " none | none | 10/20/16";

      	OUT << endl;
      }	

  }

  // mirror positions in sector
  string mirrorpos[6] = {"xR", "yR", "zR", "xL", "yL", "zL"};
  for (int s = 0; s < NSEG; s++) {
    
    for (int p = 0; p < 6; p++) {
    
        // par name
        OUT << "ltcc.mirror.s" << s + 1 << "_" << mirrorpos[p] << "\t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << mirror_pos[p][s] << "\t | cm | mirror positions  " << s + 1 << "\t | ";
        // author, emails
      	OUT << " duran, joosten | bduran@jlab.org, sjjooste@jlab.org | ";

      	// link to drawings, name, date
      	OUT << " none | none | 10/20/16";

      	OUT << endl;
      }	  
 
  }

  // WC positions in sector
  string WCpos[6] = {"xR", "yR", "zR", "xL", "yL", "zL"};
  for (int s = 0; s < NSEG; s++) {
    
    for (int p = 0; p < 6; p++) {
    
        // par name
        OUT << "ltcc.wc.s" << s + 1 << "_" << WCpos[p] << "\t | ";

        // par value, units, comment
        OUT.width(14);
        OUT << wc_pos[p][s] << "\t | cm | wc positions  " << s + 1 << "\t | ";
        // author, emails
      	OUT << " duran, joosten | bduran@jlab.org, sjjooste@jlab.org | ";

      	// link to drawings, name, date
      	OUT << " none | none | 10/20/16";

      	OUT << endl;
      }	  
 
  }
  // number of mirrors
  // par name par value, units, comment , author, emails
  OUT << "nmirrors | \t 18 |  na | number of mirrors on one side |  vlassov, "
         "ungaro | vlassov@jlab.org, ungaro@jlab.org | ";

  // link to drawings, name, date
  OUT << " none | none | 3/10/12";
  OUT << endl;
}
