#include "parameters/ltcc.h"
#include "utils/calculations.h"
#include "utils/io.h"
#include "utils/showMeasurements.h"
#include "utils/show_phe.h"
//#include "utils/show_segment.h" <== not called from anywhere
#include "utils/utils.h"
#include "utils/vars.h"
#include <TControlBar.h>

// global application settings
const std::string variation = "default";
const std::string PRINT = ".png";
const int RECALC  = 0;
const int RECALC2 = 0;

// include all the other function definitions when running with cling (currently
// the only supported mode)
#include "utils/io.C"
#include "utils/calculations.C"
#include "utils/showMeasurements.C"
#include "utils/show_phe.C"
//#include "utils/show_segment.C" <== not called from anywhere
#include "utils/utils.C"
#include "utils/vars.C"

void mirrors() {
  
  setStyle();

  init_parameters();
  write_parameters();

  simulateResponse();

  TControlBar* bar = new TControlBar("vertical", "LTCC Segments  by Maurizio Ungaro");
  bar->AddButton("", "");
  bar->AddButton("Show Photon Yield", "draw_W()");
  bar->AddButton("", "");
  bar->AddButton("Show refractive index of C4F10", "draw_c4f10n()");
  bar->AddButton("Show quantum efficiencies", "draw_qes()");
  bar->AddButton("Show reflectivities", "draw_reflectivities()");
  bar->AddButton("Show wc reflectivities", "draw_wcreflectivities()");
  bar->AddButton("Show Window Gains", "draw_window_gain()");
  bar->AddButton("", "");
  bar->AddButton("Integrate Yield", "integrate_yield()");
  bar->AddButton("Plot Yields", "plot_yields()");
  bar->AddButton("Plot Ratios", "normalized_yields_mirrors()");
  bar->AddButton("", "");
  bar->AddButton("Change particle", "change_particle()");
  bar->AddButton("Change mirror", "change_mirror()");
  bar->AddButton("Change gas", "change_gas()");
  bar->AddButton("Change pmt", "change_pmt()");
  bar->AddButton("Change WC", "change_WC()");
  bar->AddButton("", "");
  bar->AddButton("Simulate Response", "simulateResponse()");
  bar->AddButton("", "");
  bar->AddButton("Write Parameters", "write_parameters()");
  bar->AddButton("", "");
  bar->Show();

}
