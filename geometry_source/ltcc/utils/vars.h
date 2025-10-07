#ifndef LTCC_UTILS_VARS_LOADED
#define LTCC_UTILS_VARS_LOADED

#include <string>
#include <vector>

// application settings, defined in mirrors.C
extern const std::string variation;
extern const std::string PRINT;
extern const int RECALC;
extern const int RECALC2;

// names
const std::vector<std::string> pname = {"electron", "pion", "kaon"};
const std::vector<std::string> mirname = {"perfect", "ltcc", "eciw", "ecis"};
const std::vector<std::string> gasname = {"perfect", "c4f10"};
const std::vector<std::string> pmtname = {"perfect", "std", "uvg", "qtz"};
const std::vector<std::string> wcname = {"perfect", "wc_good", "wc_soso",
                                         "wc_bad"};

// variable global indices
// TODO: factor these into function arguments
extern int PART;
extern int MIRROR;
extern int GAS;
extern int PMT;
extern int WC;

#endif
