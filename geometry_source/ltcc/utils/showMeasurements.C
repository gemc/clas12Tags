#include "../parameters/ltcc.h"
#include "showMeasurements.h"

#include <TLatex.h>
#include <TCanvas.h>
#include <TGraph.h>
#include <TLegend.h>

// draw quantum efficiencies
void draw_qes()
{
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* QE = new TCanvas("QE", "Quantum Efficiencies", 800, 600);

  TGraph* stdg = new TGraph(NP, lambda, stdPmt_qe);
  TGraph* uvgg = new TGraph(NP, lambda, uvgPmt_qe);
  TGraph* qtzg = new TGraph(NP, lambda, qtzPmt_qe);

  stdg->SetMarkerSize(1.6);

  stdg->SetMarkerStyle(33);
  uvgg->SetMarkerStyle(21);
  qtzg->SetMarkerStyle(8);

  stdg->SetMarkerColor(kBlack);
  uvgg->SetMarkerColor(kBlue);
  qtzg->SetMarkerColor(kRed);

  stdg->Draw("AP");
  uvgg->Draw("Psame");
  qtzg->Draw("Psame");

  lab.SetTextSize(0.04);
  lab.DrawLatex(.1, .95, "Quantum Efficiencies of Std, UV glass and Quartz");

  lab.SetTextColor(kBlack);
  lab.DrawLatex(.85, .03, "nm");

  TLegend* lpmts = new TLegend(0.64, 0.65, 0.90, 0.8);
  lpmts->AddEntry(stdg, "Standard PMT", "P");
  lpmts->AddEntry(uvgg, "UV glass PMT", "P");
  lpmts->AddEntry(qtzg, "Quartz PMT", "P");
  lpmts->SetBorderSize(0);
  lpmts->SetFillColor(0);
  lpmts->Draw();

  if (PRINT != "no") {
    QE->Print(Form("quantum_efficiency%s", PRINT.c_str()));
  }
}

// draw mirrors reflectivities
void draw_reflectivities() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* RF = new TCanvas("RF", "Reflectivities", 800, 600);

  TGraph* ltcc = new TGraph(NP, lambda, ltcc_refl);
  TGraph* eciw = new TGraph(NP, lambda, ecis_witn);
  TGraph* ecis = new TGraph(NP, lambda, ecis_samp);

  ltcc->SetMarkerSize(1.6);

  ltcc->SetMarkerStyle(33);
  eciw->SetMarkerStyle(21);
  ecis->SetMarkerStyle(8);

  ltcc->SetMarkerColor(kBlack);
  eciw->SetMarkerColor(kBlue);
  ecis->SetMarkerColor(kRed);

  ecis->SetMinimum(0.4);

  //  eciw->Draw("AP");
  ecis->Draw("AP");
  ltcc->Draw("Psame");
  //  ecis->Draw("Psame");

  lab.SetTextSize(0.04);
  lab.DrawLatex(.13, .95, "Reflectivities of LTCC Mirrors and ECI re-coats");

  lab.SetTextColor(kBlack);
  lab.DrawLatex(.85, .03, "nm");

  TLegend* lmirs = new TLegend(0.6, 0.55, 0.88, 0.75);
  lmirs->AddEntry(ltcc, "LTCC Mirror", "P");
  //	lmirs->AddEntry(eciw, "ECI Witness", "P");
  lmirs->AddEntry(ecis, "ECI Mirror Re-coated", "P");
  lmirs->SetBorderSize(0);
  lmirs->SetFillColor(0);
  lmirs->Draw();

  if (PRINT != "no") {
    RF->Print(Form("reflectivity%s", PRINT.c_str()));
  }
}

// draw wc reflectivities
void draw_wcreflectivities() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* RF = new TCanvas("RF", "Reflectivities", 800, 600);

  TGraph* wcgood = new TGraph(NP, lambda, wc_good);
  TGraph* wcsoso = new TGraph(NP, lambda, wc_soso);
  TGraph* wcbad = new TGraph(NP, lambda, wc_bad);

  wcgood->SetMarkerSize(1.6);

  wcgood->SetMarkerStyle(33);
  wcsoso->SetMarkerStyle(21);
  wcbad->SetMarkerStyle(8);

  wcgood->SetMarkerColor(kBlack);
  wcsoso->SetMarkerColor(kBlue);
  wcbad->SetMarkerColor(kRed);

  wcgood->SetMinimum(0.0);
  wcgood->SetMaximum(1.0);

  wcgood->Draw("AP");
  wcsoso->Draw("Psame");
  wcbad->Draw("Psame");

  lab.SetTextSize(0.04);
  lab.DrawLatex(.3, .95, "Reflectivities of LTCC WCs");

  lab.SetTextColor(kBlack);
  lab.DrawLatex(.85, .03, "nm");

  TLegend* lmirs = new TLegend(0.6, 0.55, 0.88, 0.75);
  lmirs->AddEntry(wcgood, "Good", "P");
  lmirs->AddEntry(wcsoso, "So-So", "P");
  lmirs->AddEntry(wcbad, "Bad", "P");
  lmirs->SetBorderSize(0);
  lmirs->SetFillColor(0);
  lmirs->Draw();

  if (PRINT != "no") {
    RF->Print(Form("reflectivity%s", PRINT.c_str()));
  }
}

void draw_c4f10n() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* NN = new TCanvas("NN", "Refraction index", 800, 600);

  TGraph* ri = new TGraph(NP, lambda, c4f10n);
  ri->SetMarkerSize(0.8);
  ri->SetMarkerStyle(20);
  ri->Draw("AP");

  lab.SetTextSize(0.04);
  lab.DrawLatex(.28, .95, "Refraction index of C4F10 ");

  lab.SetTextColor(kBlack);
  lab.DrawLatex(.85, .03, "nm");

  if (PRINT != "no") {
    NN->Print(Form("refraction_index%s", PRINT.c_str()));
  }
}

void draw_window_gain() {
  TLatex lab;
  lab.SetTextFont(102);
  lab.SetTextColor(kBlue + 2);
  lab.SetNDC();

  TCanvas* WG = new TCanvas("WG", "Window gain", 800, 600);

  //	windowMore_nocut_nose->Draw();
  //	windowMore_nocut_nonose->Draw("same");
  windowMore_cut_nose->Draw("");
  windowMore_cut_nonose->Draw("same");

  TLegend* lwindow = new TLegend(0.65, 0.78, 0.9, 0.88);
  //	lwindow->AddEntry(windowMore_nocut_nonose, "No Cut, No Nose", "L");
  //	lwindow->AddEntry(windowMore_nocut_nose, "No Cut, Nose", "L");
  lwindow->AddEntry(windowMore_cut_nonose, "No Nose", "L");
  lwindow->AddEntry(windowMore_cut_nose, "Nose", "L");
  lwindow->SetBorderSize(0);
  lwindow->SetFillColor(0);
  lwindow->Draw();

  lab.SetTextSize(0.05);
  lab.DrawLatex(.18, .95, "C4F10 gas gain (middle of LTCC)");

  lab.SetTextColor(kBlack);
  lab.DrawLatex(.85, .03, "cm");

  lab.SetTextAngle(90);
  lab.DrawLatex(.05, .63, "% gas gain");

  if (PRINT != "no") {
    WG->Print(Form("window_addition_gain%s", PRINT.c_str()));
  }
}
