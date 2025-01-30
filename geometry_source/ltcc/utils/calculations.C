#include "../parameters/ltcc.h"
#include "calculations.h"
#include "vars.h"
#include <TCanvas.h>
#include <TF1.h>
#include <TF12.h>
#include <TF2.h>
#include <TFile.h>
#include <TGraph.h>
#include <TH1D.h>
#include <TLatex.h>
#include <TLegend.h>
#include <TPad.h>
#include <TStyle.h>
#include <cmath>
#include <iostream>

using std::cout;
using std::endl;

// interpolate linearly table values
double interpolate(double x, string what) {
  // out of range
  if (x < 190 || x > 650) {
    return 0;
  }

  // getting wavelength indexes

  int i1 = floor((x - 190.0) / 10.0);
  int i2 = i1 + 1;

  double* data;

  if (what == "n") {
    data = c4f10n;
  } else if (what == "stdPMT") {
    data = stdPmt_qe;
  } else if (what == "uvgPMT") {
    data = uvgPmt_qe;
  } else if (what == "qtzPMT") {
    data = qtzPmt_qe;
  } else if (what == "c4f10t") {
    data = c4f10t;
  } else if (what == "ltcc_refl") {
    data = ltcc_refl;
  } else if (what == "ecis_witn") {
    data = ecis_witn;
  } else if (what == "ecis_samp") {
    data = ecis_samp;
  } else if (what == "wc_bad") {
    data = wc_bad;
  } else if (what == "wc_soso") {
    data = wc_soso;
  } else if (what == "wc_good") {
    data = wc_good;
  } else {
    cout << " No data selected in interpolation routine. This will crash "
            "the macro"
         << endl;
  }

  if (i2 >= NP) {
    return data[NP - 1];
  }

  double dx = lambda[i2] - lambda[i1];
  double dy = data[i2] - data[i1];

  double m = dy / dx;
  double b = data[i1] - m * lambda[i1];

  return m * x + b;
}

// pure photon yield as from Tamm's formula
double dndxdl(double* x, double* par) {
  // x[0] is the wavelength
  // x[1] is momentum
  // par[0] is the particle mass
  // par[1] is the mirror reflectivity: 0 is 100%, 1 is LTCC, 2 is ECI witness 3
  // is for ECI sample
  // par[2] is the PMT quantum efficiency: 0 for 100%, 1 for std, 2 for UV, 3
  // for quartz
  // par[3] is the gas transparency: 0 for 100%, 1 c4f10

  double l = x[0];
  double p = x[1];
  double m = par[0];

  // refraction index as a function of lambda
  double ri = 1 + pow(10, -6) * p1_S / (pow(p2_S, -2) - pow(l, -2));

  // uncomment below for quartz radiator
  // double l2 = l/1000.0;
  // double ri = sqrt(1.28604141 + (1.07044083*l2*l2)/(l2*l2-0.0100585997) +
  // (1.10202242*l2*l2)/(l2*l2-100.0));

  double c = 2 * PI * alpha / (l / 10000000.0 * l); // one of the lambda in cm.
                                                    // The other doesn't matter
                                                    // cause I integrate over it
  double beta = sqrt(p * p / (m * m + p * p));

  double refl = 0;
  double wrefl = 0;
  double qe = 0;
  double transp = 0;

  // mirror reflectivity choices
  if (par[1] == 0) {
    refl = 1;
  }
  if (par[1] == 1) {
    refl = interpolate(l, "ltcc_refl");
  }
  if (par[1] == 2) {
    refl = interpolate(l, "ecis_witn");
  }
  if (par[1] == 3) {
    refl = interpolate(l, "ecis_samp");
  }

  // quantum efficiency choices
  if (par[2] == 0) {
    qe = 1;
  }
  if (par[2] == 1) {
    qe = interpolate(l, "stdPMT");
  }
  if (par[2] == 2) {
    qe = interpolate(l, "uvgPMT");
  }
  if (par[2] == 3) {
    qe = interpolate(l, "qtzPMT");
  }

  // gas transparency
  if (par[3] == 0) {
    transp = 1;
  }
  if (par[3] == 1) {
    transp = interpolate(l, "c4f10t");
  };

  // wc reflectivity
  if (par[4] == 0) {
    wrefl = 1;
  }
  if (par[4] == 1) {
    wrefl = interpolate(l, "wc_good");
  }
  if (par[4] == 2) {
    wrefl = interpolate(l, "wc_soso");
  }
  if (par[4] == 3) {
    wrefl = interpolate(l, "wc_bad");
  }

  // must be above threshold
  // reflectivity is counted twice for mirrors and once for WC
  if (beta * beta * ri * ri > 1) {
    return refl * refl * wrefl * qe * transp * c *
           (1 - 1 / (beta * beta * ri * ri));
  } else {
    return 0;
  }
}
void integrate_yield() {

  double* mom;

  TF2* momF;
	
	double normalizationFactor = 3.8;

  if (PART == 0) {
    mom = electron_m;
    momF = dndxdlFelectron;
    momF->SetParameter(0, eMass);
  }
  if (PART == 1) {
    mom = pion_m;
    momF = dndxdlFpion;
    momF->SetParameter(0, piMass);
  }
  if (PART == 2) {
    mom = kaon_m;
    momF = dndxdlFkaon;
    momF->SetParameter(0, kMass);
  }

  momF->SetParameter(1, MIRROR);
  momF->SetParameter(2, PMT);
  momF->SetParameter(3, GAS);
  momF->SetParameter(4, WC);

  double ngammas[MNP];
  for (int i = 0; i < MNP; i++) {
    TF12 temp("temp", momF, mom[i], "x");

    // ngammas[i] = temp.Integral(190, 650, nullptr, 0.1);
    ngammas[i] = temp.Integral(190, 650, 0.1);

    cout << pname[PART] << " momentum: " << mom[i]
         << "   n gammas: " << ngammas[i] << " mirror: " << mirname[MIRROR]
         << "  pmt: " << pmtname[PMT] << " wc: " << wcname[WC] << endl;

    if (PART == 0) {
      electron_n[i] = normalizationFactor*ngammas[i];
    }
    if (PART == 1) {
      pion_n[i] = normalizationFactor*ngammas[i];
    }
    if (PART == 2) {
      kaon_n[i] = normalizationFactor*ngammas[i];
    }
  }
}

// formula to calculate the window percentage increase
double windowy(double* x, double* par) {
  // x[0] is the position along the side wall
  // par[0] is cut / not cut (0 or 1)
  // par[1] is nose / no nose (0 or 1)
  double nose = par[1] * NOSEY;

  double sideLength = 1; // side is 1 m long

  if (par[0] == 0) {
    double m = nose / WD;
    if (x[0] > 0 && x[0] < WD) {
      return -(WY0 - sqrt(WR * WR - pow(x[0] - WX0, 2))) + nose - m * x[0];
    } else {
      return 0;
    }
  } else {
    double m = nose / WD2;
    if (x[0] > 0 && x[0] < WD2) {
      return (-(WY02 - sqrt(WR * WR - pow(x[0] - WX02, 2))) + nose - m * x[0]) /
             sideLength;
    } else {
      return 0;
    }
  }
}

int calculateNReflection(double r) {
  double r1 = 0.3;
  double r2 = 0.7;
  double r3 = 1.0;

  if (r < r1) {
    return 2;
  } else if (r >= r1 && r < r2) {
    return 3;
  } else if (r >= r2 && r <= r3) {
    return 4;
  }

  return 0;
}

int calculateWCgroup(double r) {
  double NTOT = 192;

  double g1 = 11.0 / NTOT;
  double g2 = (52.0 + 11.0) / NTOT;
  double g3 = (52.0 + 11.0 + 129.0) / NTOT;

  if (r < g1) {
    return 1;
  } // bad
  else if (r >= g1 && r < g2) {
    return 2;
  } // so-so
  else if (r >= g2 && r <= g3) {
    return 3;
  } // good

  return 0;
}

void simulateResponse() {
  TF1 MyPoisson("MyPoisson", PoissonReal, 0., 20, 1);
  gStyle->SetPadLeftMargin(0.15);
  gStyle->SetPadRightMargin(0.05);

  int NEVT = 10000;

  // the mean number of photons from clas6
  // was 9.
  // For pions however, depending on momemntum,
  // this number will change.
  // Taking 9 as the number of photons for pions at 7.5 GeV
  // and calculating the ratio of pi3 for each momentum
  double mean7 = 9;
  double means[MNP];

  double pion_ratio_1[MNP]; // no changes: same mirror, same PMT, same wc (so-so)
  double pion_ratio_2[MNP]; // recoated mirror, same PMT, same wc (so-so)
  double pion_ratio_3[MNP]; // recoated mirror, improved PMT, same wc (so-so)
  double pion_ratio_4[MNP]; // recoated mirror, improved PMT, coated wc (good)
  double pion_ratio_5[MNP]; // recoated mirror, improved PMT, bad wc
  double pion_ratio_6[MNP]; // recoated mirror, improved PMT, perfect wc (2
                            // reflections only)

  TH1D* perfec[MNP];
  TH1D* doNoth[MNP];
  TH1D* fixBad[MNP];
  TH1D* fixAll[MNP];

  // assuming show_ration has been run (need to re-run if RECALC is 1)
  ifstream in("pionYield.txt");

  for (int i = 0; i < MNP; i++) {
    in >> pion_ratio_1[i] >> pion_ratio_2[i] >> pion_ratio_3[i] >>
        pion_ratio_4[i] >> pion_ratio_5[i] >> pion_ratio_6[i];
  }

  in.close();

  if (RECALC2 == 0) {

    TFile f("dist.root");

    for (int i = 0; i < MNP; i++) {
      perfec[i] = (TH1D*)f.Get(Form("perfec%d", i));
      doNoth[i] = (TH1D*)f.Get(Form("doNoth%d", i));
      fixBad[i] = (TH1D*)f.Get(Form("fixBad%d", i));
      fixAll[i] = (TH1D*)f.Get(Form("fixAll%d", i));

      perfec[i]->SetDirectory(0);
      doNoth[i]->SetDirectory(0);
      fixBad[i]->SetDirectory(0);
      fixAll[i]->SetDirectory(0);
    }
    f.Close();
  } else {
    for (int i = 0; i < MNP; i++) {
      perfec[i] =
          new TH1D(Form("perfec%d", i), Form("perfec%d", i), 250, 0, 25);
      doNoth[i] =
          new TH1D(Form("doNoth%d", i), Form("doNoth%d", i), 250, 0, 25);
      fixBad[i] =
          new TH1D(Form("fixBad%d", i), Form("fixBad%d", i), 250, 0, 25);
      fixAll[i] =
          new TH1D(Form("fixAll%d", i), Form("fixAll%d", i), 250, 0, 25);
    }

    for (int i = 2; i < MNP; i++) {
      // means[i] = mean7*pion_ratio_2[i]/pion_ratio_2[11];
      means[i] = mean7 * pion_ratio_3[i] / pion_ratio_3[11];

      for (int e = 1; e < NEVT; e++) {
        if (e % 1000 == 0) {
          cout << " Event number " << e << " for momentum: " << i << endl;
        }

        MyPoisson.SetParameter(0, means[i]);

        double r = MyPoisson.GetRandom();
        perfec[i]->Fill(r);

        int nr = calculateNReflection(gRandom->Uniform(0, 1));
        int gr = calculateWCgroup(gRandom->Uniform(0, 1));

        // only 2 reflections
        // wc are "perfect"
        if (nr == 2) {
          doNoth[i]->Fill(r * pion_ratio_4[i]);
          fixBad[i]->Fill(r * pion_ratio_4[i]);
          fixAll[i]->Fill(r * pion_ratio_4[i]);
        }
        if (nr == 3) {
          // bad
          if (gr == 1) {
            doNoth[i]->Fill(r * pion_ratio_5[i]);
            fixBad[i]->Fill(r * pion_ratio_4[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
          // so-so
          if (gr == 2) {
            doNoth[i]->Fill(r * pion_ratio_3[i]);
            fixBad[i]->Fill(r * pion_ratio_3[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
          // good
          if (gr == 3) {
            doNoth[i]->Fill(r * pion_ratio_4[i]);
            fixBad[i]->Fill(r * pion_ratio_4[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
        }
        if (nr == 4) {
          r = r * 0.8;
          // bad
          if (gr == 1) {
            doNoth[i]->Fill(r * pion_ratio_5[i]);
            fixBad[i]->Fill(r * pion_ratio_4[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
          // so-so
          if (gr == 2) {
            doNoth[i]->Fill(r * pion_ratio_3[i]);
            fixBad[i]->Fill(r * pion_ratio_3[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
          // good
          if (gr == 3) {
            doNoth[i]->Fill(r * pion_ratio_4[i]);
            fixBad[i]->Fill(r * pion_ratio_4[i]);
            fixAll[i]->Fill(r * pion_ratio_4[i]);
          }
        }
      }
    }

    // saving histos
    TFile f("dist.root", "RECREATE");
    for (int i = 0; i < MNP; i++) {
      perfec[i]->Write();
      doNoth[i]->Write();
      fixBad[i]->Write();
      fixAll[i]->Write();
    }
    f.Close();
  }

  // histos loaded, now plotting
  for (int i = 0; i < MNP; i++) {
    doNoth[i]->SetLineColor(kRed);
    fixBad[i]->SetLineColor(kBlue);
    fixAll[i]->SetLineColor(kGreen);

    perfec[i]->GetXaxis()->SetLabelSize(0.08);
    perfec[i]->GetYaxis()->SetLabelSize(0.08);
    perfec[i]->GetXaxis()->SetLabelOffset(-0.02);
    perfec[i]->GetYaxis()->SetLabelOffset(0.02);
  }

  double xmom[10];
  double ymomA[10];
  double ymomB[10];
  double ymomC[10];

  TCanvas* res = new TCanvas("res", "Photon Yields", 1500, 1200);

  TPad* pres = new TPad("pres", "pres", 0.01, 0.01, 0.98, 0.9);
  pres->Divide(5, 2);
  pres->Draw();

  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetTextSize(0.06);
  lab.SetNDC();

  for (int i = 2; i < 12; i++) {
    pres->cd(i - 1);

    perfec[i]->Draw();
    fixAll[i]->Draw("same");
    doNoth[i]->Draw("same");
    fixBad[i]->Draw("same");

    double perfectCounts = perfec[i]->Integral(40, 250);
    double donothCounts = doNoth[i]->Integral(40, 250);
    double fixBadCounts = fixBad[i]->Integral(40, 250);
    double fixAllCounts = fixAll[i]->Integral(40, 250);

    double dmom = (max_m - min_m) / MNP;
    double mom = min_m + i * dmom;

    xmom[i - 2] = mom;
    ymomA[i - 2] = 100 * donothCounts / perfectCounts;
    ymomB[i - 2] = 100 * fixBadCounts / perfectCounts;
    ymomC[i - 2] = 100 * fixAllCounts / perfectCounts;

    cout << " momentum: " << mom << " perfect: " << perfectCounts
         << "   nothing: " << donothCounts << "    fix bad: " << fixBadCounts
         << "   fix all " << fixAllCounts << endl;

    lab.DrawLatex(.5, .82, Form(" mom: %2.1f GeV", mom));
    lab.DrawLatex(.5, .75, Form(" do nothing: %3.1f%%",
                                100 * donothCounts / perfectCounts));
    lab.DrawLatex(
        .5, .68, Form(" fix bad: %3.1f%%", 100 * fixBadCounts / perfectCounts));
    lab.DrawLatex(
        .5, .60, Form(" fix all: %3.1f%%", 100 * fixAllCounts / perfectCounts));
  }

  //	res->Print("allMoms.png");

  TCanvas* res2 = new TCanvas("res2", "Photon Yields", 1000, 1000);
  //	perfec[5]->Draw();
  //	fixAll[5]->Draw("same");
  //	doNoth[5]->Draw("same");
  //	fixBad[5]->Draw("same");
  //
  //	res2->Print("fixAll.png");

  TGraph* mresA = new TGraph(10, xmom, ymomA);
  TGraph* mresB = new TGraph(10, xmom, ymomB);
  TGraph* mresC = new TGraph(10, xmom, ymomC);

  mresA->SetMarkerStyle(8);
  mresB->SetMarkerStyle(21);
  mresC->SetMarkerStyle(8);

  mresA->SetMarkerSize(1.6);
  mresB->SetMarkerSize(1.6);
  mresC->SetMarkerSize(1.6);
  mresA->SetMarkerColor(kBlack);
  mresB->SetMarkerColor(kRed);
  mresC->SetMarkerColor(kBlue);

  mresA->Draw("AP");
  mresB->Draw("Psame");
  mresC->Draw("Psame");

  TLegend* lstudy = new TLegend(0.6, 0.35, 0.95, 0.58);
  lstudy->AddEntry(mresA, "Current Situation", "P");
  lstudy->AddEntry(mresB, "Fix Bad", "P");
  lstudy->AddEntry(mresC, "Fix So-So", "P");
  lstudy->SetBorderSize(0);
  lstudy->SetFillColor(0);
  lstudy->Draw();
}
