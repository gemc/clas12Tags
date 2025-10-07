#include "calculations.h"
#include "show_phe.h"
#include "vars.h"
#include <TCanvas.h>
#include <TF2.h>
#include <TLatex.h>
#include <fstream>

using std::ifstream;
using std::ofstream;

// number of photons as a function of energy and particle
void draw_W() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* NN = new TCanvas("NN", "n. photo-electrons yield", 800, 600);

  TF2* momF;

  if (PART == 0) {
    momF = dndxdlFelectron;
    momF->SetParameter(0, eMass);
  }
  if (PART == 1) {
    momF = dndxdlFpion;
    momF->SetParameter(0, piMass);
  }
  if (PART == 2) {
    momF = dndxdlFkaon;
    momF->SetParameter(0, kMass);
  }

  momF->SetParameter(1, MIRROR);
  momF->SetParameter(2, PMT);
  momF->SetParameter(3, GAS);
  momF->SetParameter(4, WC);

  momF->Draw("surfFB");

  lab.SetTextSize(0.05);
  lab.DrawLatex(.25, .95, "photo-electron yield dN/d#lambdadx");

  lab.SetTextSize(0.04);
  lab.SetTextColor(kBlack);
  lab.SetTextAngle(10);

  lab.SetTextAlign(32);
  lab.DrawLatex(.6, .78, Form("%s", pname[PART].c_str()));
  lab.DrawLatex(.6, .73, Form("%s mirror", mirname[MIRROR].c_str()));
  lab.DrawLatex(.6, .68, Form("%s pmt", pmtname[PMT].c_str()));
  lab.DrawLatex(.6, .63, Form("%s gas", gasname[GAS].c_str()));
  lab.DrawLatex(.6, .58, Form("%s wc", wcname[WC].c_str()));

  lab.SetTextAlign(11);
  lab.DrawLatex(.58, .04, "photon wavelength [nm]");
  lab.SetTextSize(0.034);
  lab.SetTextAngle(-31);
  lab.DrawLatex(.07, .25, "Particle Momentum [GeV]");

  if (PRINT != "no") {
    NN->Print(Form("photon_yield_spectrum_%s_gas%s_mirror%s_pmt%s%s",
                   pname[PART].c_str(), gasname[GAS].c_str(),
                   mirname[MIRROR].c_str(), pmtname[PMT].c_str(),
                   PRINT.c_str()));
  }
}

void plot_yields() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* YY = new TCanvas("YY", "Photon Yields", 800, 600);

  PART = 0;
  integrate_yield();
  TGraph* ele_yield = new TGraph(MNP, electron_m, electron_n);

  PART = 1;
  integrate_yield();
  TGraph* pio_yield = new TGraph(MNP, pion_m, pion_n);

  PART = 2;
  integrate_yield();
  TGraph* kao_yield = new TGraph(MNP, kaon_m, kaon_n);

  ele_yield->SetMarkerSize(1.6);
  ele_yield->SetMarkerStyle(33);
  pio_yield->SetMarkerStyle(21);
  kao_yield->SetMarkerStyle(8);

  ele_yield->SetMarkerColor(kBlack);
  pio_yield->SetMarkerColor(kBlue);
  kao_yield->SetMarkerColor(kRed);

  ele_yield->SetMinimum(0);
  ele_yield->Draw("AP");
  pio_yield->Draw("Psame");
  kao_yield->Draw("Psame");

  lab.SetTextAlign(32);
  lab.DrawLatex(.86, .65, Form("%s mirror", mirname[MIRROR].c_str()));
  lab.DrawLatex(.86, .60, Form("%s pmt", pmtname[PMT].c_str()));
  lab.DrawLatex(.86, .55, Form("%s gas", gasname[GAS].c_str()));

  TLegend* lstudy = new TLegend(0.12, 0.6, 0.3, 0.75);
  lstudy->AddEntry(ele_yield, "electrons", "P");
  lstudy->AddEntry(pio_yield, "pions", "P");
  lstudy->AddEntry(kao_yield, "kaons", "P");
  lstudy->SetBorderSize(0);
  lstudy->SetFillColor(0);
  lstudy->Draw();

  lab.SetTextSize(0.04);
  lab.SetTextAlign(11);
  lab.DrawLatex(.5, .03, "particle momentum [GeV]");

  lab.SetTextSize(0.05);
  lab.DrawLatex(.28, .94, "Photo-electron Yield / cm");

  if (PRINT != "no") {
    YY->Print(Form("photon_yield_gas%s_mirror%s_pmt%s%s", gasname[GAS].c_str(),
                   mirname[MIRROR].c_str(), pmtname[PMT].c_str(),
                   PRINT.c_str()));
  }
}

// calculate the effect of re-coating the mirrors and using different PMTs
void normalized_yields_mirrors() {
  TCanvas* YR = new TCanvas("YR", "Photon Yields Ratios", 800, 600);

  double unfocusing = 1.3;

  double
      pion_ratio_1[MNP]; // no changes: same mirror, same PMT, same wc (so-so)
  double pion_ratio_2[MNP]; // recoated mirror, same PMT, same wc (so-so)
  double pion_ratio_3[MNP]; // recoated mirror, improved PMT, same wc (so-so)
  double pion_ratio_4[MNP]; // recoated mirror, improved PMT, coated wc (good)
  double pion_ratio_5[MNP]; // recoated mirror, improved PMT, bad wc
  double pion_ratio_6[MNP]; // recoated mirror, improved PMT, perfect wc (2
                            // reflections only)

  // getting data from file
  if (RECALC == 0) {
    ifstream in("pionYield.txt");

    for (int i = 0; i < MNP; i++) {
      in >> pion_ratio_1[i] >> pion_ratio_2[i] >> pion_ratio_3[i] >>
          pion_ratio_4[i] >> pion_ratio_5[i] >> pion_ratio_6[i];
    }

    in.close();
  } else if (RECALC == 1) {

    // reference
    PART = 0;   // electron
    GAS = 1;    // c4f10
    MIRROR = 1; // ltcc mirror
    PMT = 2;    // uv glass pmt
    WC = 1;     // ltcc wc (good)
    integrate_yield();

    // No changes: same mirror, same PMT, same wc (so-so)
    // this will show ratio if we don't change anything
    PART = 1;   // pion
    GAS = 1;    // c4f10
    MIRROR = 1; // ltcc mirror
    PMT = 2;    // uv glass pmt
    WC = 2;     // ltcc wc (so/so)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_1[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // recoated mirror, same PMT, same wc (so-so)
    PART = 1;   // pion
    GAS = 1;    // c4f10
    MIRROR = 3; // ltcc mirror
    PMT = 2;    // uv glass pmt
    WC = 2;     // ltcc wc (so/so)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_2[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // recoated mirror, improved PMT, same wc (so-so)
    PART = 1;   // pion
    GAS = 1;    // c4f10
    MIRROR = 3; // ltcc mirror
    PMT = 3;    // uv glass pmt
    WC = 2;     // ltcc wc (so/so)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_3[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // recoated mirror, improved PMT, coated wc (good)
    PART = 1;   // electron
    GAS = 1;    // c4f10
    MIRROR = 3; // ltcc mirror
    PMT = 3;    // uv glass pmt
    WC = 1;     // ltcc wc (good)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_4[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // recoated mirror, improved PMT, bad wc
    PART = 1;   // electron
    GAS = 1;    // c4f10
    MIRROR = 3; // ltcc mirror
    PMT = 3;    // uv glass pmt
    WC = 3;     // ltcc wc (bad)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_5[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // recoated mirror, improved PMT, perfect wc (2 reflections only)
    PART = 1;   // electron
    GAS = 1;    // c4f10
    MIRROR = 3; // ltcc mirror
    PMT = 3;    // uv glass pmt
    WC = 0;     // ltcc wc (bad)
    integrate_yield();
    for (int i = 0; i < MNP; i++) {
      pion_ratio_6[i] = pion_n[i] / electron_n[i] / unfocusing;
    }

    // saving graph to files
    ofstream out("pionYield.txt");

    for (int i = 0; i < MNP; i++) {
      out << pion_ratio_1[i] << " " << pion_ratio_2[i] << " " << pion_ratio_3[i]
          << " " << pion_ratio_4[i] << " " << pion_ratio_5[i] << " "
          << pion_ratio_6[i] << endl;
    }
    out.close();
  }

  TGraph* pi1 = new TGraph(MNP, pion_m, pion_ratio_1);
  TGraph* pi2 = new TGraph(MNP, pion_m, pion_ratio_2);
  TGraph* pi3 = new TGraph(MNP, pion_m, pion_ratio_3);
  TGraph* pi4 = new TGraph(MNP, pion_m, pion_ratio_4);
  TGraph* pi5 = new TGraph(MNP, pion_m, pion_ratio_5);
  TGraph* pi6 = new TGraph(MNP, pion_m, pion_ratio_6);

  pi1->SetMarkerStyle(8);
  pi2->SetMarkerStyle(21);
  pi3->SetMarkerStyle(8);
  pi4->SetMarkerStyle(26);
  pi5->SetMarkerStyle(32);

  pi1->SetMarkerSize(1.6);
  pi4->SetMarkerSize(1.6);
  pi1->SetMarkerColor(kBlack);
  pi2->SetMarkerColor(kBlue);
  pi3->SetMarkerColor(kRed);
  pi4->SetMarkerColor(kGreen);
  pi5->SetMarkerColor(kRed - 4);

  pi1->SetMinimum(0);
  pi1->SetMaximum(1.8);
  pi1->Draw("AP");
  pi2->Draw("Psame");
  pi3->Draw("Psame");
  pi4->Draw("Psame");
  pi5->Draw("Psame");

  TLegend* lstudy = new TLegend(0.1, 0.65, 0.6, 0.88);
  lstudy->AddEntry(pi1, "Same Mirror, Same PMT, Same WC", "P");
  lstudy->AddEntry(pi2, "Coat Mirror, Same PMT, Same WC", "P");
  lstudy->AddEntry(pi3, "Coat Mirror, Coat PMT, Same WC", "P");
  lstudy->AddEntry(pi4, "Coat Mirror, Coat PMT, Coat WC", "P");
  lstudy->AddEntry(pi5, "Coat Mirror, Coat PMT, Bad  WC", "P");
  lstudy->SetBorderSize(0);
  lstudy->SetFillColor(0);
  lstudy->Draw();

  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();
  lab.SetTextSize(0.034);
  lab.DrawLatex(.4, .03, "Particle Momentum               [GeV]");

  if (PRINT != "no") {
    YR->Print(Form("photon_yield_ratios_%s_gas%s_mirror%s_pmt%s%s",
                   pname[PART].c_str(), gasname[GAS].c_str(),
                   mirname[MIRROR].c_str(), pmtname[PMT].c_str(),
                   PRINT.c_str()));
  }
}
