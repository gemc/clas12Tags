use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;


###########################################################################################
###########################################################################################
# Define the relevant parameters of FT Geometry
#
# the FT geometry will be defined starting from these parameters
# and the position on the torus inner ring
#
# all dimensions are in mm
#
# the geometry parameters are divided in 4 groups:
#     beamline and shield
#     calorimeter
#     hodoscope
#     tracker

my $degrad = 57.27;
my $torus_z = 2663.; # position of the front face of the Torus ring (set the limit in z)


###########################################################################################
# CALORIMETER
#
# Define the number, dimensions and position of the crystals
my $Nx = 22;                             # Number of crystals in horizontal directions
my $Ny = 22;                             # Number of crystals in horizontal directions
my $Cfront = 1897.8;                     # Position of the front face of the crystals
my $Cwidth = 15.0;                       # Crystal width in mm (side of the squared front face)
my $Clength = 200.0;                     # Crystal length in mm
my $VM2000 = 0.130;                      # Thickness of the VM2000 wrapping
my $AGap = 0.170;                        # Air Gap between Crystals, total wodth of crystal including wrapping and air gap is 15.3 mm
my $Flength = 8.0;                       # Length of the crystal front support
my $Fwidth = $Cwidth;                    # Width of the crystal front support
my $Wwidth = $Cwidth + $VM2000;          # Width of the wrapping volume
my $Vwidth = $Cwidth + $VM2000 + $AGap;  # Width of the crystal mother volume, total width of crystal including wrapping and air gap is 15.3 mm
my $Vlength = $Clength + $Flength;       # Length of the crystal mother volume
my $Vfront = $Cfront - $Flength;         # z position of the volume front face
my $Slength = 7.0;                       # Length of the sensor "box"
my $Swidth = $Cwidth;                    # Width of the sensor "box"
my $Sgap = 1.0;                          # Gap for flux detector
my $Sfront = $Vfront + $Vlength + $Sgap; # z position of the sensor front face

# Define the copper thermal shield parameters
# back disk
my $Bdisk_TN = 4.;                                  # half thickness of the copper back disk
my $Bdisk_IR = 55.;                                 # inner radius of the copper back disk
my $Bdisk_OR = 178.5;                               # outer radius of the copper back disk
my $Bdisk_Z = $Sfront + $Slength + $Bdisk_TN + 0.1; # z position of the copper back disk
# front disk
my $Fdisk_TN = 1.;                       # half thickness of the copper front disk supporting the crystal assemblies
my $Fdisk_IR = $Bdisk_IR;                # inner radius of the copper front disk
my $Fdisk_OR = $Bdisk_OR;                # outer radius of the copper front disk
my $Fdisk_Z = $Vfront - $Fdisk_TN - 0.1; # z position of the copper front disk
# space for preamps
my $BPlate_TN = 25.;                                    # half thickness of the preamps volume
my $BPlate_IR = $Bdisk_IR;                              # inner radius of the preamps volume
my $BPlate_OR = $Bdisk_OR;                              # outer radius of the preamps volume
my $BPlate_Z = $Bdisk_Z + $Bdisk_TN + $BPlate_TN + 0.1; # z position of the preamps volume
# inner copper tube
my $Idisk_LT = ($BPlate_Z + $BPlate_TN - $Fdisk_Z + $Fdisk_TN) / 2.; # length of the inner copper tube
my $Idisk_TN = 4;                                                    # thickness of the inner copper tube
my $Idisk_OR = $Fdisk_IR;                                            # outer radius of the inner copper tube matches inner radius of front and back disks
my $Idisk_IR = $Fdisk_IR - $Idisk_TN;                                # inner radius of the inner copper tube
my $Idisk_Z = ($BPlate_Z + $BPlate_TN + $Fdisk_Z - $Fdisk_TN) / 2.;  # z position of inner copper tube
# outer copper tube
my $Odisk_LT = ($BPlate_Z + $BPlate_TN - $Fdisk_Z + $Fdisk_TN) / 2.; # length of the outer copper tube
my $Odisk_TN = 2;                                                    # thickness of the outer copper tube
my $Odisk_IR = $Fdisk_OR;                                            # inner radius of the outer copper tube matches outer radius of front and back disks
my $Odisk_OR = $Fdisk_OR + $Odisk_TN;                                # outer radius of the outer copper tube
my $Odisk_Z = $Idisk_Z;                                              # z position of the outer copper tube

# Define the motherboard parameters
my $Bmtb_TN = 1.;                                     # half thickness of the motherboard
my $Bmtb_IR = $Idisk_IR;                              # inner radius of the motherboard
my $Bmtb_OR = $Odisk_OR;                              # outer radius of the motherboard
my $Bmtb_Z = $BPlate_Z + $BPlate_TN + $Bmtb_TN + 0.1; # z position of the motherboard
my $Bmtb_hear_WD = 80. / 2.;                          # half width of the motherboard extensions
my $Bmtb_hear_LN = 225. / 2;                          # half length of the motherboard extensions
my $Bmtb_hear_D0 = 0.;                                # displacement of the motherboard extensions
my @Bmtb_angle = (30., 150., 210., 330.);             # angles of the motherboard extensions

# Define LED plate geometry parameters
my $LED_TN = 6.1;                                 # half thickness of the pcb and pastic plate hosting the LEDs
my $LED_IR = $Fdisk_IR;                           # inner radius of the pcb and pastic plate hosting the LEDs
my $LED_OR = $Fdisk_OR;                           # outer radius of the pcb and pastic plate hosting the LEDs
my $LED_Z = $Fdisk_Z - $Fdisk_TN - $LED_TN - 0.1; # z position of the pcb and pastic plate hosting the LEDs

# bline: tungsten pipe inside the ft_cal
my $BLine_IR = 30.;                   # pipe inner radius;
my $BLine_SR = 33.5;                  # pipe inner radius in steel case;
my $BLine_DR = 25.1;                  # shield inner radius in steel case;
my $BLine_TN = 10.;                   # pipe thickness
my $BLine_FR = $BLine_IR + $BLine_TN; # radius in the front part, connecting to moller shield
my $BLine_OR = 100.;                  # radius of the back flange
my $BLine_BG = 1644.7;                # z location of the beginning of the beamline (to be matched to moller shield)
my $BLine_ML = 1760.0;                # z location of the end of the Moller shield


# back tungsten cup
my $BCup_tang = 0.0962;                        # tangent of 5.5 degrees
my $BCup_TN = 5.;                              # thickness of the flat part of the cup
my $BCup_ZM = $Bmtb_Z + $Bmtb_TN + 0.1 + 43.4; # z of the downstream face of the cup
my $BCup_Z1 = $Bmtb_Z + $Bmtb_TN + 0.1 + 1;    # z of the side close to the motherboard (downstream)
my $BCup_Z2 = $Bmtb_Z - $Bmtb_TN - 0.1 - 1;    # z of the side close to the motherboard (upstream)
my $BCup_ZE = $BCup_ZM + $BCup_TN;             # z of the downstream face of the cup
my $BCup_ZB = $BCup_ZM - 120.;                 # z beginning of the conical part
my $BCup_IRM = 190.;                           # inner radius at the beginning of the cone
my $BCup_ORB = $BCup_ZB * $BCup_tang;          # outer radius at the beginning of the cone
my $BCup_OR1 = $BCup_Z1 * $BCup_tang;          # outer radius close to the MTB
my $BCup_OR2 = $BCup_Z2 * $BCup_tang;          # outer radius close to the MTB
my $BCup_ORM = $BCup_ZM * $BCup_tang;          # outer radius at the front face of the plate
my $BCup_ORE = $BCup_ZE * $BCup_tang;          # outer radius at the back face of the plate
my $BCup_angle = int(atan($Bmtb_hear_WD / $Bmtb_OR) * $degrad * 10) / 10 + 0.5;
my @BCup_iangle = (30. + $BCup_angle, 150. + $BCup_angle, 210. + $BCup_angle, 330. + $BCup_angle);
my @BCup_dangle = ((90. - $BCup_iangle[0]) * 2., (180. - $BCup_iangle[1]) * 2., (90. - $BCup_iangle[0]) * 2., (180. - $BCup_iangle[1]) * 2.);

my $TPlate_TN = 20.; # thickness of the tungsten plate on the back of the FT-Cal


###########################################################################################
# OUTER INSULATION
my $O_Ins_TN = 15. - 0.01;
my $O_Ins_Z1 = $Fdisk_Z - $Fdisk_TN - $LED_TN * 2 - 10.8 - $O_Ins_TN; #1849.6
my $O_Ins_Z2 = $O_Ins_Z1 + $O_Ins_TN;
my $O_Ins_Z3 = $BCup_ZB;
my $O_Ins_Z4 = $BCup_Z2;
my $O_Ins_Z5 = $BCup_Z1;
my $O_Ins_Z6 = $BCup_ZM;
my $O_Ins_Z7 = $BCup_ZE;
my $O_Ins_Z8 = $BCup_ZE + 0.01;
my $O_Ins_Z9 = $O_Ins_Z8 + $O_Ins_TN;
my $O_Ins_Z10 = $O_Ins_Z9;
my $O_Ins_Z11 = $O_Ins_Z10 + $TPlate_TN;

my $O_Ins_I1 = $BLine_IR + $BLine_TN + 0.01;
my $O_Ins_I2 = $O_Ins_Z2 * $BCup_tang + 0.01;
my $O_Ins_I3 = $O_Ins_Z3 * $BCup_tang + 0.01;
my $O_Ins_I4 = $O_Ins_Z4 * $BCup_tang + 0.01;
my $O_Ins_I5 = $O_Ins_Z5 * $BCup_tang + 0.01;
my $O_Ins_I6 = $O_Ins_Z6 * $BCup_tang + 0.01;
my $O_Ins_I7 = $O_Ins_Z7 * $BCup_tang + 0.01;
my $O_Ins_I8 = $O_Ins_Z8 * $BCup_tang + 0.01;
my $O_Ins_I9 = $O_Ins_I1;
my $O_Ins_I10 = $O_Ins_Z10 * $BCup_tang + 0.01;
my $O_Ins_I11 = $O_Ins_I10;

my $O_Ins_O1 = $O_Ins_Z1 * $BCup_tang + 0.01 + $O_Ins_TN;
my $O_Ins_O2 = $O_Ins_I2 + $O_Ins_TN;
my $O_Ins_O3 = $O_Ins_I3 + $O_Ins_TN;
my $O_Ins_O4 = $O_Ins_I4 + $O_Ins_TN;
my $O_Ins_O5 = $O_Ins_I5 + $O_Ins_TN;
my $O_Ins_O6 = $O_Ins_I6 + $O_Ins_TN;
my $O_Ins_O7 = $O_Ins_I7 + $O_Ins_TN;
my $O_Ins_O8 = $O_Ins_I8 + $O_Ins_TN;
my $O_Ins_O9 = $O_Ins_Z9 * $BCup_tang + 0.01 + $O_Ins_TN;
my $O_Ins_O10 = $O_Ins_I10 + $O_Ins_TN;
my $O_Ins_O11 = $O_Ins_I11 + $O_Ins_TN;

$O_Ins_I4 = $O_Ins_Z4 * $BCup_tang + 0.5;
$O_Ins_I5 = $O_Ins_Z5 * $BCup_tang + 0.5;

###########################################################################################
# INNER INSULATION
my $I_Ins_LT = ($BCup_ZE - $O_Ins_Z2 - 0.1) / 2.;
my $I_Ins_OR = $Idisk_IR - 0.1;
my $I_Ins_IR = $O_Ins_I1;
my $I_Ins_Z = ($BCup_ZE + $O_Ins_Z2) / 2.;

###########################################################################################
# OUTER SHELL
my $O_Shell_TN = 2. - 0.01;
my $O_Shell_Z1 = $O_Ins_Z1 - $O_Shell_TN - 0.01;
my $O_Shell_Z2 = $O_Shell_Z1 + $O_Shell_TN;
my $O_Shell_Z3 = $O_Ins_Z3;
my $O_Shell_Z4 = $BCup_Z2;
my $O_Shell_Z5 = $BCup_Z1;
my $O_Shell_Z6 = $O_Ins_Z6;
my $O_Shell_Z7 = $O_Ins_Z7;
my $O_Shell_Z8 = $O_Ins_Z8;
my $O_Shell_Z9 = $O_Ins_Z9;
my $O_Shell_Z10 = $O_Ins_Z10;
my $O_Shell_Z11 = $O_Ins_Z11 + 0.01;
my $O_Shell_Z12 = $O_Shell_Z11;
my $O_Shell_Z13 = $O_Shell_Z12 + $O_Shell_TN;

my $O_Shell_I1 = $O_Ins_I1;
my $O_Shell_I2 = $O_Shell_Z2 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I3 = $O_Shell_Z3 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I4 = $O_Shell_Z4 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I5 = $O_Shell_Z5 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I6 = $O_Shell_Z6 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I7 = $O_Shell_Z7 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I8 = $O_Shell_Z8 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I9 = $O_Shell_Z9 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I10 = $O_Shell_Z10 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I11 = $O_Shell_Z11 * $BCup_tang + $O_Ins_TN + 0.01;
my $O_Shell_I12 = $O_Shell_I11 - $O_Ins_TN - 5.;
my $O_Shell_I13 = $O_Shell_I12;

my $O_Shell_O1 = $O_Shell_Z1 * $BCup_tang + $O_Ins_TN + 0.01 + $O_Shell_TN;
my $O_Shell_O2 = $O_Shell_I2 + $O_Shell_TN;
my $O_Shell_O3 = $O_Shell_I3 + $O_Shell_TN;
my $O_Shell_O4 = $O_Shell_I4 + $O_Shell_TN;
my $O_Shell_O5 = $O_Shell_I5 + $O_Shell_TN;
my $O_Shell_O6 = $O_Shell_I6 + $O_Shell_TN;
my $O_Shell_O7 = $O_Shell_I7 + $O_Shell_TN;
my $O_Shell_O8 = $O_Shell_I8 + $O_Shell_TN;
my $O_Shell_O9 = $O_Shell_I9 + $O_Shell_TN;
my $O_Shell_O10 = $O_Shell_I10 + $O_Shell_TN;
my $O_Shell_O11 = $O_Shell_I11 + $O_Shell_TN;
my $O_Shell_O12 = $O_Shell_O11;
my $O_Shell_O13 = $O_Shell_O12;

$O_Shell_I4 = $O_Shell_Z4 * $BCup_tang + $O_Ins_TN + 0.7;
$O_Shell_I5 = $O_Shell_Z5 * $BCup_tang + $O_Ins_TN + 0.7;

###########################################################################################
# FT BEAMLINE COMPONENTS

# ft to torus pipe
my $Tube_OR = 75.0;
my $back_flange_OR = 126.0;
my $front_flange_OR = 148.0;
my $flange_TN = 15.0;

my $TPlate_RR = $TPlate_TN * 0.6;
my $TPlate_Z1 = $O_Ins_Z9 + 0.01;
my $TPlate_Z2 = $TPlate_Z1 + $TPlate_TN - 0.01;
my $TPlate_ZM = $TPlate_Z2 - $TPlate_RR;
my $TPlate_MR = $BLine_IR + $BLine_TN + $TPlate_RR;

my $BLine_MR = $BLine_IR + $BLine_TN; # outer radius in the calorimeter section
my $BLine_Z1 = $BLine_BG;
my $BLine_Z2 = $BLine_ML + 0.2;
my $BLine_Z3 = $O_Shell_Z1 - 0.01;
my $BLine_Z4 = $TPlate_Z2 + 0.01;
my $BLine_Z5 = $BLine_Z4 - 0.01 + 20;


###########################################################################################
# Hodoscope Dimension and Parameters
my $VETO_TN = 38. / 2.;                    # thickness of the hodoscope volume
my $VETO_OR = 178.5;                       # outer radius
my $VETO_IR = 40.;                         # inner radius
my $VETO_Z = $O_Shell_Z1 - $VETO_TN - 0.1; # position along z

my $VETO_RING_TN = 37. / 2.; # thickness of the hodoscope volume
my $VETO_RING_IR = $VETO_IR;
my $VETO_RING_OR = 105 / 2.;
my $VETO_RING_Z = $O_Shell_Z1 - $VETO_RING_TN - 0.1; # position along z

my $VETO_SKIN_TN = 0.5;
my $PAINT_TN = 0.1;
my $TILE_WW = 15.0;

my $VETO_nplanes = 4;
my @VETO_iradius = ($VETO_RING_OR, $VETO_RING_OR, $VETO_IR, $VETO_IR);
my @VETO_oradius = ($VETO_OR, $VETO_OR, $VETO_OR, $VETO_OR);
my @VETO_zpos = ($VETO_Z - $VETO_TN, 1810.6, 1810.6, $VETO_Z + $VETO_TN);

#my $LS_TN=5./2.;
#
#my $p15_WW=15./2.;
#my $p15_WT=10./2.;
##
#my $p30_WW=30./2.;
#my $p30_WT=$p15_WT;
##
#my $p15_SW=$p15_WW-0.1;
#my $p15_ST=$p15_WT-0.1;
##
#my $p30_SW=$p30_WW-0.1;
#my $p30_ST=$p30_WT-0.1;
##
#my $p15_N = 11;
#my @p15_X = (  7.5,  22.5,  37.5,  52.5,  52.5,  67.5,  67.5,  67.5,  67.5,  97.5, 127.5);
#my @p15_Y = ( 67.5,  67.5,  67.5,  52.5,  67.5,   7.5,  22.5,  37.5,  52.5, 127.5,  97.5);
#
#my $p30_N = 18;
#my @p30_X = (  15.,  15.,  15.,  45.,  45.,  45.,  75.,  75.,  75.,  90.,  90., 105., 105., 120., 120., 135., 150., 150.);
#my @p30_Y = (  90., 120., 150.,  90., 120., 150.,  75., 105., 135.,  15.,  45.,  75., 105.,  15.,  45.,  75.,  15.,  45.);
my @q_X = (1., -1., -1., 1.);
my @q_Y = (1., 1., -1., -1.);

my $n_L = 2;
my @tn_L = (7.0, 15.0);
my $n_S1 = 9;
my @px_S1 = (3.25, 2.5, 4.25, 3.5, 2.5, 4.5, 3.5, 2.5, 1.75);
my @py_S1 = (4.25, 4.5, 3.25, 3.5, 3.5, 2.5, 2.5, 2.5, 1.75);
my @ww_S1 = (1.00, 2.0, 1.00, 2.0, 2.0, 2.0, 2.0, 2.0, 1.00);

my $n_S2 = 20;
my @px_S2 = (1.5, 0.5, -0.5, -1.5, 1.5, 0.5, -0.5, -1.5, 1.5, 0.5, -0.5, -1.5, 1.75, 1.25, 0.75, 0.25, -0.25, -0.75, -1.25, -1.75);
my @py_S2 = (5.0, 5.0, 5.0, 5.0, 4.0, 4.0, 4.0, 4.0, 3.0, 3.0, 3.0, 3.0, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25);
my @ww_S2 = (2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);

###########################################################################################
# Tracker Dimension and Parameters
#############   Gabriel Charles - 2014  #################
############# Michel Garçon - Jan. 2017 #################

# Tracker Dimension and Parameters
#my @starting_point =();

# Mother volume dimensions
my $MVftt_ir = 40;
my $MVftt_mr = 59.75;
my $MVftt_er = 50.;
my $MVftt_or = 170.0;
my $MVftt_z1 = 1760.0;   # includes support ring
my $MVftt_zmin = 1770.0; # should be <= 1774
my $MVftt_zmax = 1809.0; # should be >= 1806 and <= 1809.6
my $MVftt_z4 = 1810.6;   # includes support ring
my $MVftt_zctr = ($MVftt_zmax + $MVftt_zmin) / 2.0;
my $MVftt_dz = ($MVftt_zmax - $MVftt_zmin) / 2.0;

my $nlayer = 2;

# Detector inner and outer radii
my $InnerRadius = 60.0;
my $OuterRadius = 170.0;

# Half-thicknesses:
my $Epoxy_Dz = 0.5 * 0.1;
# 0.1 is half the 200 microns thickness (1/2 is attributed to each disk
# some detectors may have 500 microns glue instead of 200; check !
my $PCB_Dz = 0.5 * 0.2;
my $Strips_Dz = 0.5 * 0.012;
my $Kapton_Dz = 0.5 * 0.075;
my $ResistStrips_Dz = 0.5 * 0.020;
my $Gas1_Dz = 0.5 * 0.128;
my $Mesh_Dz = 0.5 * 0.018;
my $Photoresist_Dz = 0.5 * 0.064;
my $AluRings_Dz = 0.5 * 5.0;
my $DriftElectrode_Dz = 0.5 * 0.012;
#my $Gas2_Dz 		= $Photoresist_Dz + $AluRings_Dz - $DriftElectrode_Dz;
#above is the real thickness, but leads to overlaps -> neglect 64 microns of gas (replaced de facto by air since the positioning does not change)
my $Gas2_Dz = $AluRings_Dz - $DriftElectrode_Dz;
my $DriftPCB_Dz = 0.5 * 0.2;
my $DriftGround_Dz = 0.5 * 0.005;
my $Protection_Dz = 0.5 * 0.05;

my $AssemblyRing1_Dz = 0.5 * 7.8;
my $AssemblyRing2_Dz = 0.5 * 7.8;
my $AssemblyRing3_Dz = 0.5 * 9.0;

#my $zoffset            = 0.;    # may be adjusted
my @CenteringSupportRing_zmin = ($MVftt_z1, 1774., 1805.2, $MVftt_zmin);
my @CenteringSupportRing_zmax = (1774., 1805.2, $MVftt_z4, 1774.);
my @CenteringSupportRing_Rmin = ($MVftt_ir, $MVftt_ir, $MVftt_ir, $MVftt_mr);
my @CenteringSupportRing_Rmax = ($MVftt_mr, 50., $MVftt_er, 67.);

my $MVftt_nplanes = 6;
my @MVftt_iradius = ($MVftt_ir, $MVftt_ir, $MVftt_ir, $MVftt_ir, $MVftt_ir, $MVftt_ir);
my @MVftt_oradius = ($MVftt_mr, $MVftt_mr, $MVftt_or, $MVftt_or, $MVftt_er, $MVftt_er);
my @MVftt_zpos = ($MVftt_z1, $MVftt_zmin, $MVftt_zmin, $MVftt_zmax, $MVftt_zmax, $MVftt_z4);


#my $ftm_ring_z          = ( 1760 + 1809.6)/2.;
#my $ftm_ring_dz         = (-1760 + 1809.6)/2.;
#my $ftm_ring_ir         = 80./2.;

my @zrel = (); # $zrel[i] = zmax(i) of Table 1 of MG report, i= 1,12.
$zrel[0] = 0.;
$zrel[1] = $zrel[0] + 2. * $Epoxy_Dz;
$zrel[2] = $zrel[1] + 2. * $PCB_Dz;
$zrel[3] = $zrel[2] + 2. * $Strips_Dz;
$zrel[4] = $zrel[3] + 2. * $Kapton_Dz;
$zrel[5] = $zrel[4] + 2. * $ResistStrips_Dz;
$zrel[6] = $zrel[5] + 2. * $Gas1_Dz;
$zrel[7] = $zrel[6] + 2. * $Mesh_Dz;
$zrel[8] = $zrel[7] + 2. * ($Photoresist_Dz + $Gas2_Dz);
$zrel[9] = $zrel[8] + 2. * $DriftElectrode_Dz;
$zrel[10] = $zrel[9] + 2. * $DriftPCB_Dz;
$zrel[11] = $zrel[10] + 2. * $DriftGround_Dz;
$zrel[12] = $zrel[11] + 2. * $Protection_Dz;

my $z_abs = $CenteringSupportRing_zmax[3]; # entrance of detector1/disk1 = end of SupportRing4 = 1774.
my @z0 = ();                               # starting absolute z-coordinate for each disk
$z0[0] = $z_abs + $zrel[12];
$z0[1] = $z0[0] + 2. * $zrel[9] + 2. * $AssemblyRing3_Dz;


# G4 materials
my $epoxy_material = 'epoxy';
my $pcboard_material = 'myFR4';
my $strips_material = 'mmstrips';
my $kapton_material = 'G4_KAPTON';
my $resistive_material = 'ResistPaste';
my $gas_material = 'mmgas';
my $mesh_material = 'mmmesh';
my $photoresist_material = 'myPhRes';
my $drift_material = 'mmmylar';


# G4 colors
my $epoxy_color = 'e200e1';
my $pcboard_color = '0000ff';
my $strips_color = '353540';
my $gas_color = 'e10000';
my $mesh_color = '252020';
my $photoresist_color = 'd200d1';
my $drift_color = 'fff600';
my $alu_color = 'aaaaff';


#  FTM FEE Boxes
my $FEE_Disk_OR = 200.;
my $FEE_Disk_LN = 2.;
my $FEE_ARM_LN = 530. / 2. - 80;
my $FEE_ARM_WD = 90. / 2.;

# size of crate
my $FEE_WD = 91. / 2.;
my $FEE_HT = 265.5 / 2.;
my $FEE_LN = 242. / 2.;
my $FEE_TN = 1.5;

my $FEE_PVT_TN = 10.;

my $FEE_PVT_WD = $FEE_WD + $FEE_PVT_TN;
my $FEE_PVT_HT = $FEE_HT + $FEE_PVT_TN;
my $FEE_PVT_LN = $FEE_LN + $FEE_PVT_TN;

my $FEE_A_WD = $FEE_WD - $FEE_TN;
my $FEE_A_HT = $FEE_HT - $FEE_TN;
my $FEE_A_LN = $FEE_LN - $FEE_TN;
my @FEE_azimuthal_angle = (210., 270., 330.);
my $FEE_polar_angle = -22.;


# define crystals mother volume
my $nplanes_FT_CRY = 2;
my @z_plane_FT_CRY = ($Idisk_Z - $Idisk_LT, $Idisk_Z + $Idisk_LT);
my @iradius_FT_CRY = ($Idisk_IR, $Idisk_IR);
my @oradius_FT_CRY = ($Odisk_OR, $Odisk_OR);


###########################################################################################
# Build FT-CAL Mother Volume
###########################################################################################

sub make_ft_cal_mother_volume {

    my $nplanes_FT = 6;
    my @z_plane_FT = ($O_Shell_Z1, 2098., $TPlate_ZM, $BLine_Z4, $BLine_Z4, $BLine_Z5);
    my @oradius_FT = (700., 700., 238., 238., 238., 238.);
    my @iradius_FT = ($BLine_MR, $BLine_MR, $BLine_MR, $TPlate_MR, $BLine_OR, $BLine_OR);
    my %detector = init_det();
    $detector{"name"} = "ft_cal";
    $detector{"mother"} = "root";
    $detector{"description"} = "ft calorimeter";
    $detector{"color"} = "1437f4";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_FT*counts";
    for (my $i = 0; $i < $nplanes_FT; $i++) {$dimen = $dimen . " $iradius_FT[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FT; $i++) {$dimen = $dimen . " $oradius_FT[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FT; $i++) {$dimen = $dimen . " $z_plane_FT[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);

}


###########################################################################################
# Build Crystal Volume and Assemble calorimeter
###########################################################################################

sub make_ft_cal_crystals_volume {
    my %detector = init_det();
    $detector{"name"} = "ft_calCrystalsMother";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft calorimeter crystal volume";
    $detector{"color"} = "1437f4";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_FT_CRY*counts";
    for (my $i = 0; $i < $nplanes_FT_CRY; $i++) {$dimen = $dimen . " $iradius_FT_CRY[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FT_CRY; $i++) {$dimen = $dimen . " $oradius_FT_CRY[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FT_CRY; $i++) {$dimen = $dimen . " $z_plane_FT_CRY[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);

}

# Loop over all crystals and define their positions
sub make_ft_cal_crystals {
    my $centX = (int $Nx / 2) + 0.5;
    my $centY = (int $Ny / 2) + 0.5;
    my $locX = 0.;
    my $locY = 0.;
    my $locZ = 0.;
    my $dX = 0.;
    my $dY = 0.;
    my $dZ = 0.;
    for (my $iX = 1; $iX <= $Nx; $iX++) {
        for (my $iY = 1; $iY <= $Ny; $iY++) {
            $locX = ($iX - $centX) * $Vwidth;
            $locY = ($iY - $centY) * $Vwidth;
            my $locR = sqrt($locX * $locX + $locY * $locY);
            if ($locR > 60. && $locR < $Vwidth * 11) {
                # crystal mother volume
                my %detector = init_det();
                $detector{"name"} = "ft_cal_cr_motherVolume_h" . $iX . "_v" . $iY;
                $detector{"mother"} = "ft_calCrystalsMother";
                $detector{"description"} = "Mother Volume for crystal h:" . $iX . ", v:" . $iY;
                $locZ = $Vfront + $Vlength / 2.;
                $detector{"pos"} = "$locX*mm $locY*mm $locZ*mm";
                $detector{"color"} = "838EDE";
                $detector{"type"} = "Box";
                $dX = $Vwidth / 2.0;
                $dY = $Vwidth / 2.0;
                $dZ = $Vlength / 2.0;
                $detector{"dimensions"} = "$dX*mm $dY*mm $dZ*mm";
                $detector{"material"} = "G4_AIR";
                print_det(\%configuration, \%detector);

                # APD housing
                %detector = init_det();
                $detector{"name"} = "ft_cal_cr_apd_h" . $iX . "_v" . $iY;
                $detector{"mother"} = "ft_calCrystalsMother";
                $detector{"description"} = "apd for crystal h:" . $iX . ", v:" . $iY;
                $locZ = $Sfront + $Slength / 2.;
                $detector{"pos"} = "$locX*mm $locY*mm $locZ*mm";
                $detector{"color"} = "99CC66";
                $detector{"type"} = "Box";
                $dX = $Swidth / 2.0;
                $dY = $Swidth / 2.0;
                $dZ = $Slength / 2.0;
                $detector{"dimensions"} = "$dX*mm $dY*mm $dZ*mm";
                $detector{"material"} = "ft_peek";
                $detector{"style"} = "1";
                print_det(\%configuration, \%detector);

                # Wrapping Volume;
                %detector = init_det();
                $detector{"name"} = "ft_cal_cr_wrap_h" . $iX . "_v" . $iY;
                $detector{"mother"} = "ft_cal_cr_motherVolume_h" . $iX . "_v" . $iY;
                $detector{"description"} = "wrapping for crystal h:" . $iX . ", v:" . $iY;
                $locX = 0.;
                $locY = 0.;
                $locZ = 0.;
                $detector{"pos"} = "$locX*mm $locY*mm $locZ*mm";
                $detector{"color"} = "838EDE";
                $detector{"type"} = "Box";
                $dX = $Wwidth / 2.0;
                $dY = $Wwidth / 2.0;
                $dZ = $Vlength / 2.0;
                $detector{"dimensions"} = "$dX*mm $dY*mm $dZ*mm";
                $detector{"material"} = "G4_MYLAR";
                $detector{"style"} = "1";
                print_det(\%configuration, \%detector);

                # PbWO4 Crystal;
                %detector = init_det();
                $detector{"name"} = "ft_cal_cr_h" . $iX . "_v" . $iY;
                $detector{"mother"} = "ft_cal_cr_wrap_h" . $iX . "_v" . $iY;
                $detector{"description"} = "PbWO4 crystal h:" . $iX . ", v:" . $iY;
                $locX = 0.;
                $locY = 0.;
                $locZ = $Flength / 2.;
                $detector{"pos"} = "$locX*mm $locY*mm $locZ*mm";
                $detector{"color"} = "836FFF";
                $detector{"type"} = "Box";
                $dX = $Cwidth / 2.0;
                $dY = $Cwidth / 2.0;
                $dZ = $Clength / 2.0;
                $detector{"dimensions"} = "$dX*mm $dY*mm $dZ*mm";
                $detector{"material"} = "G4_PbWO4";
                $detector{"style"} = "1";
                $detector{"sensitivity"} = "ft_cal";
                $detector{"hit_type"} = "ft_cal";
                $detector{"identifiers"} = "ih manual $iX iv manual $iY";
                print_det(\%configuration, \%detector);

                # LED housing
                %detector = init_det();
                $detector{"name"} = "ft_cal_cr_ledHousing_h" . $iX . "_v" . $iY;
                $detector{"mother"} = "ft_cal_cr_wrap_h" . $iX . "_v" . $iY;
                $detector{"description"} = "Led Housing for crystal h:" . $iX . ", v:" . $iY;
                $locX = 0.;
                $locY = 0.;
                $locZ = -$Vlength / 2. + $Flength / 2.;
                $detector{"pos"} = "$locX*mm $locY*mm $locZ*mm";
                $detector{"color"} = "EEC900";
                $detector{"type"} = "Box";
                $dX = $Fwidth / 2.0;
                $dY = $Fwidth / 2.0;
                $dZ = $Flength / 2.0;
                $detector{"dimensions"} = "$dX*mm $dY*mm $dZ*mm";
                $detector{"material"} = "ft_peek";
                $detector{"style"} = "1";
                print_det(\%configuration, \%detector);
            }
        }
    }
}


###########################################################################################
# Define the Flux Detector on the back of the crystals
sub make_ft_cal_flux {
    # flux on the back of the crystals
    my $Flux_TN = $Sgap / 2; # flux detector half thickness defined as a function of the gap between sensor and crystals
    my $Flux_IR = $Bdisk_IR; # inner radius is defined equal to copper back disk
    my $Flux_OR = $Bdisk_OR; # outer radius is defined equal to copper front disk
    my $Flux_Z = $Vfront + $Vlength + $Flux_TN;
    my %detector = init_det();
    $detector{"name"} = "ft_cal_flux";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft flux";
    $detector{"pos"} = "0.0*mm 0.0*mm $Flux_Z*mm";
    $detector{"color"} = "aa0088";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Flux_IR*mm $Flux_OR*mm $Flux_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 1;
    $detector{"sensitivity"} = "flux";
    $detector{"hit_type"} = "flux";
    $detector{"identifiers"} = "id manual 3";
    print_det(\%configuration, \%detector);
}

# Define the Flux Detectors in front of the Tagger
sub make_ft_moellerdisk {
    # flux in front of tagger
    my @disk_zpos = (281.0, $O_Shell_Z1 - 0.05);
    my @disk_iradius = (2.0, 56.0);
    my @disk_oradius = (150.0, 150.0);

    for (my $n = 1; $n < 2; $n++) {
        my $idisk = $n + 1;
        my %detector = init_det();
        $detector{"name"} = "moller_disk_$n";
        $detector{"mother"} = "root";
        $detector{"description"} = "Moller Disk $n";
        $detector{"pos"} = "0*mm 0.0*mm $disk_zpos[$n]*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = "aa0088";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$disk_iradius[$n]*mm $disk_oradius[$n]*mm 0.05*mm 0.0*deg 360*deg";
        $detector{"material"} = "G4_Galactic";
        $detector{"visible"} = 0;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"} = "flux";
        $detector{"identifiers"} = "id manual $idisk";
        print_det(\%configuration, \%detector);
    }
}

###########################################################################################
# Define the Copper Disk in front of the Crystals
sub make_ft_cal_copper {
    # back
    my %detector = init_det();
    $detector{"name"} = "ft_cal_back_copper";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft back_copper";
    $detector{"pos"} = "0.0*mm 0.0*mm $Bdisk_Z*mm";
    $detector{"color"} = "CC6600";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Bdisk_IR*mm $Bdisk_OR*mm $Bdisk_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
    # front
    %detector = init_det();
    $detector{"name"} = "ft_cal_front_copper";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft front_copper";
    $detector{"pos"} = "0.0*mm 0.0*mm $Fdisk_Z*mm";
    $detector{"color"} = "CC6600";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Fdisk_IR*mm $Fdisk_OR*mm $Fdisk_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
    # inner
    %detector = init_det();
    $detector{"name"} = "ft_cal_inner_copper";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft inner_copper";
    $detector{"pos"} = "0.0*mm 0.0*mm $Idisk_Z*mm";
    $detector{"color"} = "CC6600";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Idisk_IR*mm $Idisk_OR*mm $Idisk_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
    # outer
    %detector = init_det();
    $detector{"name"} = "ft_cal_outer_copper";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft outer_copper";
    $detector{"pos"} = "0.0*mm 0.0*mm $Odisk_Z*mm";
    $detector{"color"} = "CC6600";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Odisk_IR*mm $Odisk_OR*mm $Odisk_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # Preamp Space
    %detector = init_det();
    $detector{"name"} = "ft_cal_back_plate";
    $detector{"mother"} = "ft_calCrystalsMother";
    $detector{"description"} = "ft back_plate";
    $detector{"pos"} = "0.0*mm 0.0*mm $BPlate_Z*mm";
    $detector{"color"} = "7F9A65";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$BPlate_IR*mm $BPlate_OR*mm $BPlate_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_AIR";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

}


###########################################################################################
# Define the Space for the Preamps  and the MotherBoard on the back
sub make_ft_cal_motherboard {
    # MotherBoard
    my %detector = init_det();
    $detector{"name"} = "ft_cal_back_mtb";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft back_mtb disk";
    $detector{"pos"} = "0.0*mm 0.0*mm $Bmtb_Z*mm";
    $detector{"color"} = "0B3B0B";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Bmtb_IR*mm $Bmtb_OR*mm $Bmtb_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "pcboard";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    for (my $i = 0; $i < 4; $i++) {
        my $Bmtb_hear_DX = ($Bmtb_OR + $Bmtb_hear_LN - $Bmtb_hear_D0) * cos($Bmtb_angle[$i] / $degrad);
        my $Bmtb_hear_DY = -($Bmtb_OR + $Bmtb_hear_LN - $Bmtb_hear_D0) * sin($Bmtb_angle[$i] / $degrad);
        %detector = init_det();
        $detector{"name"} = "ft_cal_back_mtb_h$i";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft back_mtb hear$i";
        $detector{"pos"} = "$Bmtb_hear_DX*mm $Bmtb_hear_DY*mm $Bmtb_Z*mm";
        $detector{"rotation"} = "0*deg 0*deg $Bmtb_angle[$i]*deg";
        $detector{"color"} = "0B3B0B";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Bmtb_hear_LN*mm $Bmtb_hear_WD*mm $Bmtb_TN*mm";
        $detector{"material"} = "pcboard";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}


###########################################################################################
# Define the LED assembly
sub make_ft_cal_led {
    my %detector = init_det();
    $detector{"name"} = "ft_cal_led";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft led";
    $detector{"pos"} = "0.0*mm 0.0*mm $LED_Z*mm";
    $detector{"color"} = "333333";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$LED_IR*mm $LED_OR*mm $LED_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "ft_peek";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}


###########################################################################################
# Define the Back Tungsten Cup

sub make_ft_cal_tcup {
    my $nplanes_TCup = 2;
    my @z_plane_TCup = ($BCup_Z1, $BCup_ZM);
    my @oradius_TCup = ($BCup_OR1, $BCup_ORM);
    my @iradius_TCup = ($BCup_IRM, $BCup_IRM);
    my %detector = init_det();
    $detector{"name"} = "ft_cal_tcup_back";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "tungsten cup and cone at the back of the ft, back part";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_TCup*counts";
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $iradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $oradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $z_plane_TCup[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "ft_W";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    $nplanes_TCup = 2;
    @z_plane_TCup = ($BCup_ZM, $BCup_ZE);
    @oradius_TCup = ($BCup_ORM, $BCup_ORE,);
    @iradius_TCup = ($I_Ins_OR, $I_Ins_OR);
    %detector = init_det();
    $detector{"name"} = "ft_cal_tcup_plate";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "stainless steel plate at the back of the ft";
    $detector{"color"} = "cccccc";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_TCup*counts";
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $iradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $oradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $z_plane_TCup[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    $nplanes_TCup = 2;
    @z_plane_TCup = ($BCup_ZB, $BCup_Z2);
    @oradius_TCup = ($BCup_ORB, $BCup_OR2);
    @iradius_TCup = ($BCup_IRM, $BCup_IRM);
    %detector = init_det();
    $detector{"name"} = "ft_cal_tcup_front";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "tungsten cup and cone at the back of the ft, front part";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_TCup*counts";
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $iradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $oradius_TCup[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $z_plane_TCup[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "ft_W";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    $nplanes_TCup = 2;
    @z_plane_TCup = ($BCup_Z1, $BCup_Z2);
    @oradius_TCup = ($BCup_OR1, $BCup_OR2);
    @iradius_TCup = ($BCup_IRM, $BCup_IRM);
    for (my $i = 0; $i < 4; $i++) {
        my $s = $i + 1;
        %detector = init_det();
        $detector{"name"} = "ft_cal_tcup_m$s";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "tungsten cup and cone at the back of the ft, medium part $s";
        $detector{"color"} = "ff0000";
        $detector{"type"} = "Polycone";
        my $biangle = $BCup_iangle[$i];
        my $bdangle = $BCup_dangle[$i];
        $dimen = "$biangle*deg $bdangle*deg $nplanes_TCup*counts";
        for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $iradius_TCup[$i]*mm";}
        for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $oradius_TCup[$i]*mm";}
        for (my $i = 0; $i < $nplanes_TCup; $i++) {$dimen = $dimen . " $z_plane_TCup[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"material"} = "ft_W";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

############################################################################################
## Define the Calorimeter Insulation
sub make_ft_cal_insulation {
    # inner
    my %detector = init_det();
    $detector{"name"} = "ft_cal_inner_ins";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft inner_ins";
    $detector{"pos"} = "0.0*mm 0.0*mm $I_Ins_Z*mm";
    $detector{"color"} = "F5F6CE";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$I_Ins_IR*mm $I_Ins_OR*mm $I_Ins_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "insfoam";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # outer f
    my $nplanes_O_Ins = 5;
    my @z_plane_O_Ins = ($O_Ins_Z1, $O_Ins_Z2, $O_Ins_Z2, $O_Ins_Z3, $O_Ins_Z4);
    my @iradius_O_Ins = ($O_Ins_I1, $O_Ins_I1, $O_Ins_I2, $O_Ins_I3, $O_Ins_I4);
    my @oradius_O_Ins = ($O_Ins_O1, $O_Ins_O2, $O_Ins_O2, $O_Ins_O3, $O_Ins_O4);
    %detector = init_det();
    $detector{"name"} = "ft_cal_outer_ins_f";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft outer_ins_f";
    $detector{"color"} = "F5F6CE";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_O_Ins*counts";
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $iradius_O_Ins[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $oradius_O_Ins[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $z_plane_O_Ins[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "insfoam";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # outer b
    $nplanes_O_Ins = 8;
    @z_plane_O_Ins = ($O_Ins_Z5, $O_Ins_Z6, $O_Ins_Z7, $O_Ins_Z8, $O_Ins_Z8, $O_Ins_Z9, $O_Ins_Z10, $O_Ins_Z11);
    @iradius_O_Ins = ($O_Ins_I5, $O_Ins_I6, $O_Ins_I7, $O_Ins_I8, $O_Ins_I9, $O_Ins_I9, $O_Ins_I10, $O_Ins_I11);
    @oradius_O_Ins = ($O_Ins_O5, $O_Ins_O6, $O_Ins_O7, $O_Ins_O8, $O_Ins_O8, $O_Ins_O9, $O_Ins_O10, $O_Ins_O11);
    %detector = init_det();
    $detector{"name"} = "ft_cal_outer_ins_b";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft outer_ins_b";
    $detector{"color"} = "F5F6CE";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_O_Ins*counts";
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $iradius_O_Ins[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $oradius_O_Ins[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $z_plane_O_Ins[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "insfoam";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # medium
    $nplanes_O_Ins = 2;
    @z_plane_O_Ins = ($O_Ins_Z5, $O_Ins_Z4);
    @iradius_O_Ins = ($O_Ins_I5, $O_Ins_I4);
    @oradius_O_Ins = ($O_Ins_O5, $O_Ins_O4);
    for (my $i = 0; $i < 4; $i++) {
        my $s = $i + 1;
        %detector = init_det();
        $detector{"name"} = "ft_cal_outer_ins_m$s";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft outer_ins_m$s";
        $detector{"color"} = "F5F6CE";
        $detector{"type"} = "Polycone";
        my $biangle = $BCup_iangle[$i];
        my $bdangle = $BCup_dangle[$i];
        $dimen = "$biangle*deg $bdangle*deg $nplanes_O_Ins*counts";
        for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $iradius_O_Ins[$i]*mm";}
        for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $oradius_O_Ins[$i]*mm";}
        for (my $i = 0; $i < $nplanes_O_Ins; $i++) {$dimen = $dimen . " $z_plane_O_Ins[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"material"} = "insfoam";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

###########################################################################################
# Define the Outer Shell
sub make_ft_cal_shell {
    # outer front
    my $nplanes_O_Shell = 5;
    my @z_plane_O_Shell = ($O_Shell_Z1, $O_Shell_Z2, $O_Shell_Z2, $O_Shell_Z3, $O_Shell_Z4);
    my @iradius_O_Shell = ($O_Shell_I1, $O_Shell_I1, $O_Shell_I2, $O_Shell_I3, $O_Shell_I4);
    my @oradius_O_Shell = ($O_Shell_O1, $O_Shell_O2, $O_Shell_O2, $O_Shell_O3, $O_Shell_O4);
    my %detector = init_det();
    $detector{"name"} = "ft_cal_outer_shell_f";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft outer_shell_f";
    $detector{"color"} = "F5DA81";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_O_Shell*counts";
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $iradius_O_Shell[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $oradius_O_Shell[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $z_plane_O_Shell[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "carbonFiber";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # outer back
    $nplanes_O_Shell = 9;
    @z_plane_O_Shell = ($O_Shell_Z5, $O_Shell_Z6, $O_Shell_Z7, $O_Shell_Z8, $O_Shell_Z9, $O_Shell_Z10, $O_Shell_Z11, $O_Shell_Z12, $O_Shell_Z13);
    @iradius_O_Shell = ($O_Shell_I5, $O_Shell_I6, $O_Shell_I7, $O_Shell_I8, $O_Shell_I9, $O_Shell_I10, $O_Shell_I11, $O_Shell_I12, $O_Shell_I13);
    @oradius_O_Shell = ($O_Shell_O5, $O_Shell_O6, $O_Shell_O7, $O_Shell_O8, $O_Shell_O9, $O_Shell_O10, $O_Shell_O11, $O_Shell_O12, $O_Shell_O13);
    %detector = init_det();
    $detector{"name"} = "ft_cal_outer_shell_b";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft outer_shell_b";
    $detector{"color"} = "F5DA81";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_O_Shell*counts";
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $iradius_O_Shell[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $oradius_O_Shell[$i]*mm";}
    for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $z_plane_O_Shell[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "carbonFiber";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # outer medium
    $nplanes_O_Shell = 2;
    @z_plane_O_Shell = ($O_Shell_Z5, $O_Shell_Z4);
    @iradius_O_Shell = ($O_Shell_I5, $O_Shell_I4);
    @oradius_O_Shell = ($O_Shell_O5, $O_Shell_O4);
    for (my $i = 0; $i < 4; $i++) {
        my $s = $i + 1;
        %detector = init_det();
        $detector{"name"} = "ft_cal_outer_shell_m$s";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft outer_shell $s";
        $detector{"color"} = "F5DA81";
        $detector{"type"} = "Polycone";
        my $biangle = $BCup_iangle[$i];
        my $bdangle = $BCup_dangle[$i];
        $dimen = "$biangle*deg $bdangle*deg $nplanes_O_Shell*counts";
        for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $iradius_O_Shell[$i]*mm";}
        for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $oradius_O_Shell[$i]*mm";}
        for (my $i = 0; $i < $nplanes_O_Shell; $i++) {$dimen = $dimen . " $z_plane_O_Shell[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"material"} = "carbonFiber";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

###########################################################################################
# Define the Calorimeter Beam line
sub make_ft_cal_beamline {
    my %detector = init_det();

    my $TPlate_IR = $BLine_IR + $BLine_TN;
    my $TPlate_OR = $TPlate_Z1 * $BCup_tang;

    my $nplanes_TPlate = 3;
    my @z_plane_TPlate = ($TPlate_Z1, $TPlate_ZM, $TPlate_Z2);
    my @oradius_TPlate = ($TPlate_OR, $TPlate_OR, $TPlate_OR);
    my @iradius_TPlate = ($TPlate_IR, $TPlate_IR, $TPlate_MR);

    # tungsten plate on the back of the calorimeter
    %detector = init_det();
    $detector{"name"} = "ft_cal_tplate";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft tungsten plate";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_TPlate*counts";
    for (my $i = 0; $i < $nplanes_TPlate; $i++) {$dimen = $dimen . " $iradius_TPlate[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TPlate; $i++) {$dimen = $dimen . " $oradius_TPlate[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TPlate; $i++) {$dimen = $dimen . " $z_plane_TPlate[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "ft_W";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    # steel collar on the front
    my $nplanes_TCollar = 2;
    my @z_plane_TCollar = ($BLine_Z2, $BLine_Z3);
    my @oradius_TCollar = ($BLine_FR, $BLine_FR);
    my @iradius_TCollar = ($BLine_MR, $BLine_MR);
    %detector = init_det();
    $detector{"name"} = "ft_cal_collar";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft beam collar";
    $detector{"color"} = "cccccc";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_TCollar*counts";
    for (my $i = 0; $i < $nplanes_TCollar; $i++) {$dimen = $dimen . " $iradius_TCollar[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCollar; $i++) {$dimen = $dimen . " $oradius_TCollar[$i]*mm";}
    for (my $i = 0; $i < $nplanes_TCollar; $i++) {$dimen = $dimen . " $z_plane_TCollar[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    #    print_det(\%configuration, \%detector);

    # Define the tube between Calorimeter and Torus Inner Ring
    my $Tube_IR = $BLine_IR;
    # define positions based on z of torus inner ring front face
    my $Tube_end = $torus_z - 0.1; # leave 0.1 mm to avoid overlaps
    my $Tube_beg = $BLine_Z5 + 0.1 + $FEE_Disk_LN + 0.1;
    my $Tube_z1 = $Tube_end - $flange_TN;
    my $Tube_z2 = $Tube_beg + $flange_TN;

    my $nplanes_Tube = 6;
    my @z_plane_Tube = ($Tube_beg, $Tube_z2, $Tube_z2, $Tube_z1, $Tube_z1, $Tube_end);
    my @oradius_Tube = ($front_flange_OR, $front_flange_OR, $Tube_OR, $Tube_OR, $back_flange_OR, $back_flange_OR);
    my @iradius_Tube = ($Tube_IR, $Tube_IR, $Tube_IR, $Tube_IR, $Tube_IR, $Tube_IR);

    %detector = init_det();
    $detector{"name"} = "ft_2_torus_tube";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "tube from ft to torus";
    $detector{"color"} = "99cc00";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_Tube*counts";
    for (my $i = 0; $i < $nplanes_Tube; $i++) {$dimen = $dimen . " $iradius_Tube[$i]*mm";}
    for (my $i = 0; $i < $nplanes_Tube; $i++) {$dimen = $dimen . " $oradius_Tube[$i]*mm";}
    for (my $i = 0; $i < $nplanes_Tube; $i++) {$dimen = $dimen . " $z_plane_Tube[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    #	print_det(\%configuration, \%detector);


    # Define Aluminum Beam Pipe and Vacuum
    my $AL_BLine_TN = 1.0;
    my $AL_BLine_IR = 25.4;
    my $AL_BLine_OR = $AL_BLine_IR + $AL_BLine_TN;
    my $AL_BLine_LT = ($Tube_end - $BLine_BG) / 2.;
    my $AL_BLine_Z = ($Tube_end + $BLine_BG) / 2.;

    %detector = init_det();
    $detector{"name"} = "ft_cal_al_bline";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft aluminum beam line";
    $detector{"pos"} = "0.0*mm 0.0*mm $AL_BLine_Z*mm";
    $detector{"color"} = "F2F2F2";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$AL_BLine_IR*mm $AL_BLine_OR*mm $AL_BLine_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    #	print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "ft_cal_al_bline_vacuum";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft aluminum beam line vacuum";
    $detector{"pos"} = "0.0*mm 0.0*mm $AL_BLine_Z*mm";
    $detector{"color"} = "F2F2F2";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0.0*mm $AL_BLine_IR*mm $AL_BLine_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"visible"} = 0;
    #	print_det(\%configuration, \%detector);
}

sub make_ft_cal {

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rgc_fall2022") {
        my %detector = init_det();
        $detector{"name"} = "ft_dummy";
        $detector{"mother"} = "root";
        $detector{"description"} = "Empty volume to represent FT Out";
        $detector{"pos"} = "5000.0*mm 0.0*mm 0.0*mm ";
        $detector{"color"} = "F2F2F2";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "0.1*mm 0.1*mm 0.1*mm";
        $detector{"material"} = "G4_AIR";
        $detector{"visible"} = 0;
        print_det(\%configuration, \%detector);
        return;
    }

    make_ft_cal_mother_volume();
    make_ft_cal_crystals_volume();
    make_ft_cal_crystals();

    make_ft_cal_flux();
    make_ft_moellerdisk();

    make_ft_cal_copper();
    make_ft_cal_motherboard();
    make_ft_cal_led();
    make_ft_cal_tcup();
    make_ft_cal_insulation();
    make_ft_cal_shell();
    make_ft_cal_beamline();
}

sub make_ft_hodo {

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rgc_fall2022") {
        return;
    }

    my %detector = init_det();
    $detector{"name"} = "ft_hodo";
    $detector{"mother"} = "root";
    $detector{"description"} = "ft scintillation hodoscope";
    $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
    $detector{"color"} = "3399FF";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $VETO_nplanes*counts";
    for (my $i = 0; $i < $VETO_nplanes; $i++) {$dimen = $dimen . " $VETO_iradius[$i]*mm";}
    for (my $i = 0; $i < $VETO_nplanes; $i++) {$dimen = $dimen . " $VETO_oradius[$i]*mm";}
    for (my $i = 0; $i < $VETO_nplanes; $i++) {$dimen = $dimen . " $VETO_zpos[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "ft_hodo_innervol";
    $detector{"mother"} = "ft_hodo";
    $detector{"description"} = "ft scintillation hodoscope inner volume";
    $detector{"pos"} = "0.0*mm 0.0*mm $VETO_Z*mm";
    $detector{"color"} = "3399FF";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$VETO_RING_OR*mm $VETO_OR*mm $VETO_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "ft_hodo_ring";
    $detector{"mother"} = "ft_hodo";
    $detector{"description"} = "ft hodoscope support ring";
    $detector{"pos"} = "0.0*mm 0.0*mm $VETO_RING_Z*mm";
    $detector{"color"} = "cccccc";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$VETO_RING_IR*mm $VETO_RING_OR*mm $VETO_RING_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "ft_peek";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    my $LS_Z = -$VETO_TN;
    for (my $l = 0; $l < $n_L; $l++) {
        # loop over layers

        my $L = $l + 1;
        my $LS_TN = $VETO_SKIN_TN / 2.;
        $LS_Z = $LS_Z + $LS_TN;
        %detector = init_det();
        $detector{"name"} = "ft_hodo_L$L";
        $detector{"mother"} = "ft_hodo_innervol";
        $detector{"description"} = "ft_hodo layer $L support";
        $detector{"pos"} = "0.0*mm 0.0*mm $LS_Z*mm";
        $detector{"color"} = "EFEFFB";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$VETO_RING_OR*mm $VETO_OR*mm $LS_TN*mm 0.*deg 360.*deg";
        $detector{"material"} = "carbonFiber";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

        $LS_Z = $LS_Z + $LS_TN;
        $LS_TN = $tn_L[$l] / 2. + $PAINT_TN;
        my $TILE_TN = $tn_L[$l] / 2;
        $LS_Z = $LS_Z + $LS_TN;
        my $p_X = 0.;
        my $p_Y = 0.;
        my $p_Z = $LS_Z;
        for (my $q = 0; $q < 4; $q++) {
            my $S = 1 + 2 * $q;
            for (my $i = 0; $i < $n_S1; $i++) {
                my $I = $i + 1;
                my $sp_X = $px_S1[$i] * 2. * ($TILE_WW + 2 * $PAINT_TN);
                my $sp_Y = $py_S1[$i] * 2. * ($TILE_WW + 2 * $PAINT_TN);
                if ($q == 0) {
                    $p_X = $sp_X;
                    $p_Y = $sp_Y;
                }
                elsif ($q == 1) {
                    $p_X = -$sp_Y;
                    $p_Y = $sp_X;
                }
                elsif ($q == 2) {
                    $p_X = -$sp_X;
                    $p_Y = -$sp_Y;
                }
                elsif ($q == 3) {
                    $p_X = $sp_Y;
                    $p_Y = -$sp_X;
                }
                my $WW_TILE = $ww_S1[$i] * $TILE_WW / 2.;
                my $WW_PAINT = $ww_S1[$i] * ($TILE_WW + 2 * $PAINT_TN) / 2.;
                my $TNAME = "ft_hodo_p30_";
                my $TTNAME = "ft_hodo_p30_tile_";
                my $TCOLOR = "0431B4";
                if ($ww_S1[$i] == 1) {
                    $TNAME = "ft_hodo_p15_";
                    $TTNAME = "ft_hodo_p15_tile_";
                    $TCOLOR = "3399FF";
                }
                # define tile mother volume
                %detector = init_det();
                $detector{"name"} = "$TNAME$S$L$I";
                $detector{"mother"} = "ft_hodo_innervol";
                $detector{"description"} = "$TNAME $S $L $I";
                $detector{"pos"} = "$p_X*mm $p_Y*mm $p_Z*mm";
                $detector{"rotation"} = "0*deg 0*deg 0*deg";
                $detector{"color"} = "$TCOLOR";
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$WW_PAINT*mm $WW_PAINT*mm $LS_TN*mm";
                $detector{"material"} = "G4_MYLAR";
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);

                %detector = init_det();
                $detector{"name"} = "$TTNAME$S$L$I";
                $detector{"mother"} = "$TNAME$S$L$I";
                $detector{"description"} = "$TTNAME $S $L $I";
                $detector{"color"} = "BCA9F5";
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$WW_TILE*mm $WW_TILE*mm $TILE_TN*mm";
                $detector{"material"} = "scintillator";
                $detector{"style"} = 1;
                $detector{"sensitivity"} = "ft_hodo";
                $detector{"hit_type"} = "ft_hodo";
                $detector{"identifiers"} = "sector manual $S layer manual $L component manual $I";
                print_det(\%configuration, \%detector);

            }
            $S = 2 + 2 * $q;
            for (my $i = 0; $i < $n_S2; $i++) {
                my $I = $i + 1;
                my $sp_X = $px_S2[$i] * 2. * ($TILE_WW + 2 * $PAINT_TN);
                my $sp_Y = $py_S2[$i] * 2. * ($TILE_WW + 2 * $PAINT_TN);
                if ($q == 0) {
                    $p_X = $sp_X;
                    $p_Y = $sp_Y;
                }
                elsif ($q == 1) {
                    $p_X = -$sp_Y;
                    $p_Y = $sp_X;
                }
                elsif ($q == 2) {
                    $p_X = -$sp_X;
                    $p_Y = -$sp_Y;
                }
                elsif ($q == 3) {
                    $p_X = $sp_Y;
                    $p_Y = -$sp_X;
                }
                my $WW_TILE = $ww_S2[$i] * $TILE_WW / 2.;
                my $WW_PAINT = $ww_S2[$i] * ($TILE_WW + 2 * $PAINT_TN) / 2.;
                my $TNAME = "ft_hodo_p30_";
                my $TTNAME = "ft_hodo_p30_tile_";
                my $TCOLOR = "0431B4";
                if ($ww_S2[$i] == 1) {
                    $TNAME = "ft_hodo_p15_";
                    $TTNAME = "ft_hodo_p15_tile_";
                    $TCOLOR = "3399FF";
                }
                # define tile mother volume
                %detector = init_det();
                $detector{"name"} = "$TNAME$S$L$I";
                $detector{"mother"} = "ft_hodo_innervol";
                $detector{"description"} = "$TNAME $S $L $I";
                $detector{"pos"} = "$p_X*mm $p_Y*mm $p_Z*mm";
                $detector{"rotation"} = "0*deg 0*deg 0*deg";
                $detector{"color"} = "$TCOLOR";
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$WW_PAINT*mm $WW_PAINT*mm $LS_TN*mm";
                $detector{"material"} = "G4_MYLAR";
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);

                %detector = init_det();
                $detector{"name"} = "$TTNAME$S$L$I";
                $detector{"mother"} = "$TNAME$S$L$I";
                $detector{"description"} = "$TTNAME $S $L $I";
                $detector{"color"} = "BCA9F5";
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$WW_TILE*mm $WW_TILE*mm $TILE_TN*mm";
                $detector{"material"} = "scintillator";
                $detector{"style"} = 1;
                $detector{"sensitivity"} = "ft_hodo";
                $detector{"hit_type"} = "ft_hodo";
                $detector{"identifiers"} = "sector manual $S layer manual $L component manual $I";
                print_det(\%configuration, \%detector);

            }
        }
        $LS_Z = $LS_Z + $LS_TN;
    }
}


###########################################################################################
# Define the FT Tracker Geometry Components
sub make_ft_trk_mother {
    my $zpos = $MVftt_zctr;
    my %detector = init_det();
    $detector{"name"} = "ft_trk";
    $detector{"mother"} = "root";
    $detector{"description"} = "ft tracker micromegas";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Polycone";
    #    $detector{"dimensions"}  = "$MVftt_ir*mm $MVftt_or*mm $MVftt_dz*mm 0*deg 360*deg";
    my $dimen = "0.0*deg 360*deg $MVftt_nplanes*counts";
    for (my $i = 0; $i < $MVftt_nplanes; $i++) {$dimen = $dimen . " $MVftt_iradius[$i]*mm";}
    for (my $i = 0; $i < $MVftt_nplanes; $i++) {$dimen = $dimen . " $MVftt_oradius[$i]*mm";}
    for (my $i = 0; $i < $MVftt_nplanes; $i++) {$dimen = $dimen . " $MVftt_zpos[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);

    my $vname = "ft_trk_support";
    my $descriptio = "ft tracker centering support";
    for (my $ring = 0; $ring < 4; $ring++) {
        %detector = init_det();
        my $ring_no = $ring + 1;
        my $zmin = $CenteringSupportRing_zmin[$ring];
        my $zmax = $CenteringSupportRing_zmax[$ring];
        my $PDz = 0.5 * ($zmax - $zmin);
        $zpos = 0.5 * ($zmax + $zmin);
        my $PRmin = $CenteringSupportRing_Rmin[$ring];
        my $PRmax = $CenteringSupportRing_Rmax[$ring];
        $detector{"mother"} = "ft_trk";
        $detector{"name"} = "$vname\_R$ring_no";
        $detector{"description"} = "$descriptio\, ring $ring_no";
        #        if($ring_no == 4){
        #            $detector{"mother"}  = "ft_trk";
        #            $zpos                = $zpos - $MVftt_zctr;
        #        }
        $detector{"color"} = $alu_color;
        $detector{"type"} = "Tube";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        $detector{"pos"} = "0*mm 0*mm $zpos*mm";
        $detector{"dimensions"} = "$PRmin*mm $PRmax*mm $PDz*mm 0*deg 360*deg";
        print_det(\%configuration, \%detector);
    }
}

sub place_epoxy {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    my $z = 0.0;
    my $PDz = $Epoxy_Dz;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[0] + $zrel[1]);
        $vname = "ft_trk_epoxy_X_L";
        $descriptio = "epoxy X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[0] + $zrel[1]);
        $vname = "ft_trk_epoxy_Y_L";
        $descriptio = "epoxy Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $epoxy_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$InnerRadius*mm $OuterRadius*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $epoxy_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_pcboard {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;
    my $z = 0;
    my $PDz = $PCB_Dz;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[1] + $zrel[2]);
        $vname = "ft_trk_pcboard_X_L";
        $descriptio = "pc board X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[1] + $zrel[2]);
        $vname = "ft_trk_pcboard_Y_L";
        $descriptio = "pc board Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcboard_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$InnerRadius*mm $OuterRadius*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $pcboard_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_strips {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;
    my $PDz = $Strips_Dz;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[2] + $zrel[3]);
        $vname = "ft_trk_strips_X_L";
        $descriptio = "strips X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[2] + $zrel[3]);
        $vname = "ft_trk_strips_Y_L";
        $descriptio = "strips Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $strips_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "70.43*mm 143.66*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $strips_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_kapton {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    my $z = 0.0;
    my @zmin = ($zrel[3], $zrel[11]);
    my @zmax = ($zrel[4], $zrel[12]);
    my @PRMin = ($InnerRadius, $InnerRadius);
    my @PRMax = ($OuterRadius, 158.5);
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    for (my $ring = 0; $ring < 2; $ring++) {
        my %detector = init_det();
        my $ring_no = $ring + 1;
        if ($type == 1) {
            $z = $z0[$l] - 0.5 * ($zmin[$ring] + $zmax[$ring]);
            $vname = "ft_trk_kapton_X_L";
            $descriptio = "kapton X, layer $layer_no";
        }

        if ($type == 2) {
            $z = $z0[$l] + 0.5 * ($zmin[$ring] + $zmax[$ring]);
            $vname = "ft_trk_kapton_Y_L";
            $descriptio = "kapton Y, layer $layer_no";
        }
        my $PDz = 0.5 * (-$zmin[$ring] + $zmax[$ring]);

        $detector{"name"} = "$vname$layer_no\_R$ring_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, ring $ring_no";
        $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $pcboard_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin[$ring]*mm $PRMax[$ring]*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $kapton_material;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_resiststrips {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;
    my $PDz = $ResistStrips_Dz;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[4] + $zrel[5]);
        $vname = "ft_trk_resiststrips_X_L";
        $descriptio = "resistive strips X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[4] + $zrel[5]);
        $vname = "ft_trk_resiststrips_Y_L";
        $descriptio = "resistive strips Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $strips_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "70.43*mm 143.66*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $resistive_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_gas1 {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;
    my $PDz = $Gas1_Dz;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[5] + $zrel[6]);
        $vname = "ft_trk_gas1_X_L";
        $descriptio = "gas1 X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[5] + $zrel[6]);
        $vname = "ft_trk_gas1_Y_L";
        $descriptio = "gas1 Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $gas_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "71.43*mm 143.16*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $gas_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_photoresist {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    my $z = 0.0;
    my @zmin = ($zrel[5], $zrel[5], $zrel[7], $zrel[7]);
    my @zmax = ($zrel[6], $zrel[6], $zrel[9] - 2. * $AluRings_Dz, $zrel[9] - 2. * $AluRings_Dz);
    my @PRMin = ($InnerRadius, 143.16, $InnerRadius, 143.16);
    my @PRMax = (71.43, $OuterRadius, 71.43, $OuterRadius);
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    for (my $ring = 0; $ring < 4; $ring++) {
        my %detector = init_det();
        my $ring_no = $ring + 1;
        if ($type == 1) {
            $z = $z0[$l] - 0.5 * ($zmin[$ring] + $zmax[$ring]);
            $vname = "ft_trk_phrst_X_L";
            $descriptio = "photoresist X, layer $layer_no";
        }

        if ($type == 2) {
            $z = $z0[$l] + 0.5 * ($zmin[$ring] + $zmax[$ring]);
            $vname = "ft_trk_phrst_Y_L";
            $descriptio = "photoresist Y, layer $layer_no";
        }
        my $PDz = 0.5 * (-$zmin[$ring] + $zmax[$ring]);

        $detector{"name"} = "$vname$layer_no\_R$ring_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, ring $ring_no";
        $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $photoresist_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin[$ring]*mm $PRMax[$ring]*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $photoresist_material;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_mesh {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $PDz = $Mesh_Dz;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[6] + $zrel[7]);
        $vname = "ft_trk_mesh_X_L";
        $descriptio = "mesh X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[6] + $zrel[7]);
        $vname = "ft_trk_mesh_Y_L";
        $descriptio = "mesh Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $mesh_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$InnerRadius*mm $OuterRadius*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $mesh_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_gas2 {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $PDz = $Gas2_Dz;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[7] + 2. * $Photoresist_Dz + $zrel[8]);
        $vname = "ft_trk_gas2_X_L";
        $descriptio = "gas2 X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[7] + 2. * $Photoresist_Dz + $zrel[8]);
        $vname = "ft_trk_gas2_Y_L";
        $descriptio = "gas2 Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $gas_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "67.0*mm 151.5*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $gas_material;
    $detector{"style"} = 1;
    $detector{"sensitivity"} = "ft_trk";
    $detector{"hit_type"} = "ft_trk";
    $detector{"identifiers"} = "superlayer manual $layer_no type manual $type segment manual $detector{'ncopy'} strip manual 1";
    print_det(\%configuration, \%detector);
}

sub place_driftelectrode {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $PDz = $DriftElectrode_Dz;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[8] + $zrel[9]);
        $vname = "ft_trk_driftel_X_L";
        $descriptio = "drift electrode X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[8] + $zrel[9]);
        $vname = "ft_trk_driftel_Y_L";
        $descriptio = "drift electrode Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $strips_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "70.43*mm 143.66*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_drift {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $z = 0;
    my $PDz = $DriftPCB_Dz;
    my $vname = 0;
    my $descriptio = 0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zrel[9] + $zrel[10]);
        $vname = "ft_trk_drift_X_L";
        $descriptio = "drift X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zrel[9] + $zrel[10]);
        $vname = "ft_trk_drift_Y_L";
        $descriptio = "drift Y, layer $layer_no";
    }

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = "ft_trk";
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcboard_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$InnerRadius*mm 158.5*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $pcboard_material;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_rings {
    my $l = shift;
    my $type = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    my $z = 0.0;
    my $zmin = $zrel[7] + 2.0 * $Photoresist_Dz;
    my $zmax = $zrel[9];
    my @PRMin = ();
    my @PRMax = ();
    $PRMin[0] = 60.0;
    $PRMax[0] = 67.0;
    $PRMin[1] = 151.5;
    $PRMax[1] = 158.5;
    my $PDz = 0.5 * 5.0;
    my $PSPhi = 0.0;
    my $PDPhi = 360.000;

    if ($type == 1) {
        $z = $z0[$l] - 0.5 * ($zmin + $zmax);
        $vname = "ft_trk_ring_X_L";
        $descriptio = "ring X, layer $layer_no";
    }

    if ($type == 2) {
        $z = $z0[$l] + 0.5 * ($zmin + $zmax);
        $vname = "ft_trk_ring_Y_L";
        $descriptio = "ring Y, layer $layer_no";
    }

    for (my $ring = 0; $ring < 2; $ring++) {
        my %detector = init_det();
        my $ring_no = $ring + 1;
        $detector{"name"} = "$vname$layer_no\_R$ring_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, ring $ring_no";
        $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $alu_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin[$ring]*mm $PRMax[$ring]*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }

    my $ang_offset = 0.;
    # an overall rotation will have to be added to position correctly extensions 24 and 25 which break cylindrical symmetry
    for (my $ext = 0; $ext < 25; $ext++) {
        my %detector = init_det();
        my $ext_no = $ext + 1;
        $PSPhi = -0.5 * 4.9 + $ext * 15.0 + $ang_offset;
        $PDPhi = 4.9;
        if ($ext_no == 24) {$PSPhi = $PSPhi - 5.0;}
        if ($ext_no == 25) {$PSPhi = $PSPhi - 15.0 + 5.0;}
        $detector{"name"} = "$vname$layer_no\_E$ext_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, ext $ext_no";
        $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0.*deg";
        $detector{"color"} = $alu_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMax[1]*mm $OuterRadius*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_assembly {
    my $vname = "ft_trk_assembly";
    my $descriptio = "assembly";

    my @PRMin = (60., 158.7, 163.5);
    my @PRMax = (67., 163.5, 170.0);
    my @PDz = ($AssemblyRing1_Dz, $AssemblyRing2_Dz, $AssemblyRing3_Dz);
    my $zmin = $zrel[9];
    my $zmax = $zmin + 2. * $PDz[2];
    my $z = $z0[0] + 0.5 * ($zmin + $zmax);
    my $PSPhi = 0.0;
    my $PDPhi = 360.0;

    for (my $ring = 0; $ring < 3; $ring++) {
        my %detector = init_det();
        my $ring_no = $ring + 1;

        $detector{"name"} = "$vname\_R$ring_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, ring $ring_no";
        $detector{"pos"} = "0.000*mm 0.000*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $alu_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin[$ring]*mm $PRMax[$ring]*mm $PDz[$ring]*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
    my $Px = 0.5 * (158.69 - 67.0);
    my $Py = 0.5 * 3.0;
    my $Pz = $PDz[0];
    my $ang_offset = 0.;
    # an overall rotation will have to be added to position correctly the 3 branches
    for (my $branch = 0; $branch < 3; $branch++) {
        my %detector = init_det();
        my $branch_no = $branch + 1;
        my $rot = $branch * 120.0 + $ang_offset;
        my $x = (67.0 + $Px) * cos($rot * $pi / 180.0);
        my $y = (67.0 + $Px) * sin($rot * $pi / 180.0);

        $detector{"name"} = "$vname\_B$branch_no";
        $detector{"mother"} = "ft_trk";
        $detector{"description"} = "$descriptio\, branch $branch_no";
        $detector{"pos"} = "$x*mm $y*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg -$rot*deg";
        $detector{"color"} = $alu_color;
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}


###########################################################################################
# Define the FTM Electronic Boxes and Support Structure
sub make_ft_trk_fee_boxes {
    # create disk
    my $nplanes_FEE_Disk = 2;
    my @z_FEE_Disk = ($BLine_Z5 + 0.1, $BLine_Z5 + 0.1 + $FEE_Disk_LN);
    my @oradius_FEE_Disk = ($FEE_Disk_OR, $FEE_Disk_OR);
    my @iradius_FEE_Disk = ($BLine_OR + 0.1, $BLine_OR + 0.1);
    my %detector = init_det();
    $detector{"name"} = "ft_trk_fee_disk";
    $detector{"mother"} = "ft_cal";
    $detector{"description"} = "ft-trk fee support disk";
    $detector{"color"} = "999999";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes_FEE_Disk*counts";
    for (my $i = 0; $i < $nplanes_FEE_Disk; $i++) {$dimen = $dimen . " $iradius_FEE_Disk[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FEE_Disk; $i++) {$dimen = $dimen . " $oradius_FEE_Disk[$i]*mm";}
    for (my $i = 0; $i < $nplanes_FEE_Disk; $i++) {$dimen = $dimen . " $z_FEE_Disk[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    #	print_det(\%configuration, \%detector);

    # create arms
    for (my $i = 0; $i < 3; $i++) {
        my $FEE_ARM_X = ($FEE_Disk_OR + 2. + $FEE_ARM_LN * cos($FEE_polar_angle / $degrad)) * cos($FEE_azimuthal_angle[$i] / $degrad);
        my $FEE_ARM_Y = -($FEE_Disk_OR + 2. + $FEE_ARM_LN * cos($FEE_polar_angle / $degrad)) * sin($FEE_azimuthal_angle[$i] / $degrad);
        my $FEE_ARM_Z = $z_FEE_Disk[0] + $FEE_Disk_LN / 2. + $FEE_ARM_LN * sin($FEE_polar_angle / $degrad);
        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_arm_$i";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft-trk arm $i";
        $detector{"color"} = "999999";
        $detector{"type"} = "Box";
        $detector{"pos"} = "$FEE_ARM_X*mm $FEE_ARM_Y*mm $FEE_ARM_Z*mm";
        $detector{"rotation"} = "ordered: zyx $FEE_azimuthal_angle[$i]*deg $FEE_polar_angle*deg 0*deg ";
        $detector{"dimensions"} = "$FEE_ARM_LN*mm $FEE_ARM_WD*mm $FEE_Disk_LN*mm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        #		print_det(\%configuration, \%detector);


        my $FEE_R = ($FEE_ARM_LN - $FEE_PVT_HT) * cos($FEE_polar_angle / $degrad) + ($FEE_PVT_LN + $FEE_Disk_LN + 0.2) * sin($FEE_polar_angle / $degrad);
        my $FEE_X = $FEE_ARM_X + $FEE_R * cos($FEE_azimuthal_angle[$i] / $degrad);
        my $FEE_Y = $FEE_ARM_Y - $FEE_R * sin($FEE_azimuthal_angle[$i] / $degrad);
        my $FEE_Z = $FEE_ARM_Z + ($FEE_ARM_LN - $FEE_PVT_HT) * sin($FEE_polar_angle / $degrad) - ($FEE_PVT_LN + $FEE_Disk_LN + 0.2) * cos($FEE_polar_angle / $degrad);
        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_pvt_box_$i";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft-trk fee pvt box $i";
        $detector{"color"} = "EFFBFB";
        $detector{"type"} = "Box";
        $detector{"pos"} = "$FEE_X*mm $FEE_Y*mm $FEE_Z*mm";
        $detector{"rotation"} = "ordered: zyx $FEE_azimuthal_angle[$i]*deg $FEE_polar_angle*deg 0*deg ";
        $detector{"dimensions"} = "$FEE_PVT_HT*mm $FEE_PVT_WD*mm $FEE_PVT_LN*mm";
        $detector{"material"} = "G4_WATER";
        $detector{"style"} = 1;
        #		print_det(\%configuration, \%detector);


        $FEE_R = ($FEE_ARM_LN - $FEE_HT) * cos($FEE_polar_angle / $degrad) + ($FEE_LN + $FEE_Disk_LN + 0.2) * sin($FEE_polar_angle / $degrad);
        $FEE_X = $FEE_ARM_X + $FEE_R * cos($FEE_azimuthal_angle[$i] / $degrad);
        $FEE_Y = $FEE_ARM_Y - $FEE_R * sin($FEE_azimuthal_angle[$i] / $degrad);
        $FEE_Z = $FEE_ARM_Z + ($FEE_ARM_LN - $FEE_HT) * sin($FEE_polar_angle / $degrad) - ($FEE_LN + $FEE_Disk_LN + 0.2) * cos($FEE_polar_angle / $degrad) - 50.;
        my %detector = init_det();
        $detector{"name"} = "ft_trk_fee_box_$i";
        #    $detector{"mother"}      = "ft_trk_fee_pvt_box_$i";
        $detector{"mother"} = "ft_cal";
        $detector{"description"} = "ft-trk fee box $i";
        $detector{"color"} = "999999";
        $detector{"type"} = "Box";
        $detector{"pos"} = "$FEE_X*mm $FEE_Y*mm $FEE_Z*mm";
        #    $detector{"pos"}         = "0.0*mm 0.0*mm 0.0*mm";
        #		$detector{"rotation"}    = "ordered: zyx $FEE_azimuthal_angle[$i]*deg $FEE_polar_angle*deg 0*deg ";
        $detector{"rotation"} = "ordered: zyx $FEE_azimuthal_angle[$i]*deg 0*deg 0*deg ";
        #    $detector{"rotation"}    = "0*deg 0*deg 0*deg";
        $detector{"dimensions"} = "$FEE_HT*mm $FEE_WD*mm $FEE_LN*mm";
        $detector{"material"} = "G4_Al";
        #    $detector{"material"}    = "Gadolinium";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_air_$i";
        $detector{"mother"} = "ft_trk_fee_box_$i";
        $detector{"description"} = "ft-trk fee air $i";
        $detector{"pos"} = "0.*mm 0.*mm 0.*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = "CCFFFF";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$FEE_A_HT*mm $FEE_A_WD*mm $FEE_A_LN*mm";
        $detector{"material"} = "G4_AIR";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

        my $flux_FEE_TN = 0.5;
        my $flux_FEE_HT = $FEE_A_HT - 2. * $flux_FEE_TN;
        my $flux_FEE_WD = $FEE_A_WD - 2. * $flux_FEE_TN;
        my $flux_FEE_LN = $flux_FEE_TN;
        my $flux_FEE_Z = -$FEE_A_LN + $flux_FEE_TN;
        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_flux_1_$i";
        $detector{"mother"} = "ft_trk_fee_air_$i";
        $detector{"description"} = "ft-trk fee flux 1";
        $detector{"pos"} = "0.*mm 0.*mm $flux_FEE_Z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = "aa0088";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$flux_FEE_HT*mm $flux_FEE_WD*mm $flux_FEE_LN*mm";
        $detector{"material"} = "G4_Galactic";
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"} = "flux";
        $detector{"identifiers"} = "id manual 4";
        print_det(\%configuration, \%detector);

        $flux_FEE_HT = $FEE_A_HT - 2. * $flux_FEE_TN;
        $flux_FEE_WD = $flux_FEE_TN;
        $flux_FEE_LN = $FEE_A_LN - 2. * $flux_FEE_TN;
        my $flux_FEE_Y = -$FEE_WD * 0.6;
        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_flux_2_$i";
        $detector{"mother"} = "ft_trk_fee_air_$i";
        $detector{"description"} = "ft-trk fee flux 2";
        $detector{"pos"} = "0.*mm $flux_FEE_Y*mm 0.*mm";
        $detector{"rotation"} = "0*deg 0.*deg 0*deg";
        $detector{"color"} = "aa0088";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$flux_FEE_HT*mm $flux_FEE_WD*mm $flux_FEE_LN*mm";
        $detector{"material"} = "G4_Galactic";
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"} = "flux";
        $detector{"identifiers"} = "id manual 5";
        print_det(\%configuration, \%detector);

        my $dose_FEE_TN = 5.;
        my $dose_FEE_HT = $FEE_A_HT - $dose_FEE_TN;
        my $dose_FEE_WD = $dose_FEE_TN;
        my $dose_FEE_LN = $FEE_A_LN - $dose_FEE_TN;
        my $dose_FEE_Y = 0.;
        %detector = init_det();
        $detector{"name"} = "ft_trk_fee_dose_$i";
        $detector{"mother"} = "ft_trk_fee_air_$i";
        $detector{"description"} = "ft-trk fee dose";
        $detector{"pos"} = "0.*mm $dose_FEE_Y*mm 0.*mm";
        $detector{"rotation"} = "0*deg 0.*deg 0*deg";
        $detector{"color"} = "003300";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$dose_FEE_HT*mm $dose_FEE_WD*mm $dose_FEE_LN*mm";
        $detector{"material"} = "scintillator";
        $detector{"mfield"} = "no";
        $detector{"style"} = 1;
        #		$detector{"sensitivity"} = "ft_hodo";
        #		$detector{"hit_type"}    = "ft_hodo";
        #		$detector{"identifiers"} = "id manual 5000";
        print_det(\%configuration, \%detector);

    }
}

sub make_ft_trk {
    my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "rgk_winter2018"
        || $configuration_string eq "rgf_spring2020"
        || $configuration_string eq "rgd_fall2023"
        || $configuration_string eq "rgc_summer2022") {
        return;
    }
    make_ft_trk_mother();
    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        for (my $t = 0; $t < 2; $t++) {
            my $type = $t + 1;
            # type 1: X layer type ? beam enters disk on drift side
            # type 2: Y layer type ? beam enters disk on bulk side
            place_epoxy($l, $type);
            place_pcboard($l, $type);
            place_strips($l, $type);
            place_kapton($l, $type);
            place_resiststrips($l, $type);
            place_gas1($l, $type);
            place_photoresist($l, $type);
            place_mesh($l, $type);
            place_gas2($l, $type);
            place_driftelectrode($l, $type);
            place_drift($l, $type);
            place_rings($l, $type);
        }
    }
    place_assembly();
    make_ft_trk_fee_boxes();
}


# Tungsten Cone
my $nplanes_cone = 4;
my @zplane_cone = (750.0, 1750.0, 1750.0, 1809.2);
my @oradius_cone = (32.0, 76.0, 59.0, 59.0);
my @mradius_cone = (31.0, 40.0, 40.0, 40.0);
my @iradius_cone = (30.0, 30.0, 30.0, 30.0);


# Aluminum Beam Pipe
my $al_tube_TN = 1.0;
my $al_tube_IR = 25.4;
my $al_tube_OR = $al_tube_IR + $al_tube_TN;
my $al_tube_LT = ($zplane_cone[3] - ($zplane_cone[0] + 300.)) / 2.;
my $al_tube_Z = ($zplane_cone[3] + ($zplane_cone[0] + 300.)) / 2.;

# Aluminum Beam Pipe Window
my $al_window_TN = 0.05;
my $al_window_OR = $al_tube_OR;
my $al_window_Z = $al_tube_Z - $al_tube_LT - $al_window_TN;

# HTCC Moller Cup
my $nplanes_cup = 4;
my @zplane_cup = (350.0, 1318.4, 1415.2, 1724.1);
my @oradius_cup = (30.0, 114.8, 114.8, 139.0);
my @iradius_cup = (29.0, 113.8, 113.8, 138.0);


# Mother Volume
#my $nplanes_mv = 7;
#my @zplane_mv   = ( $zplane_cup[0],  $zplane_cup[1],  $zplane_cup[2],  $zplane_cup[3], $zplane_cone[1], $zplane_cone[2], $zplane_cone[3]);
#my @oradius_mv  = ($oradius_cup[0], $oradius_cup[1], $oradius_cup[2], $oradius_cup[3], $oradius_cup[3],$oradius_cone[2],$oradius_cone[2]);
#my @iradius_mv  = (            0.0,             0.0,             0.0,             0.0,             0.0,             0.0,             0.0);
my $nplanes_mv = 4;
my @zplane_mv = ($zplane_cone[0], $zplane_cone[1], $zplane_cone[2], $zplane_cone[3]);
my @oradius_mv = ($oradius_cone[0], $oradius_cone[1], $oradius_cone[2], $oradius_cone[3]);
my @iradius_mv = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

sub make_ft_shield {
    #############################
    #       Mother Volume
    #############################
    my %detector = init_det();
    $detector{"name"} = "ft_shield";
    $detector{"mother"} = "root";
    $detector{"description"} = "ft shield mother volume";
    $detector{"color"} = "ff8000";
    $detector{"type"} = "Polycone";

    my $dimen = "0.0*deg 360*deg $nplanes_mv*counts";
    for (my $i = 0; $i < $nplanes_mv; $i++) {
        $dimen = $dimen . " $iradius_mv[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_mv; $i++) {
        $dimen = $dimen . " $oradius_mv[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_mv; $i++) {
        $dimen = $dimen . " $zplane_mv[$i]*mm";
    }

    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;

    print_det(\%configuration, \%detector);


    #############################
    # Carbon Fiber Moller Cup
    #############################
    %detector = init_det();
    $detector{"name"} = "htcc_moeller_cup";
    $detector{"mother"} = "ft_shield";
    $detector{"description"} = "htcc moeller cup";
    $detector{"color"} = "575757";
    $detector{"type"} = "Polycone";

    $dimen = "0.0*deg 360*deg $nplanes_cup*counts";
    for (my $i = 0; $i < $nplanes_cup; $i++) {
        $dimen = $dimen . " $iradius_cup[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_cup; $i++) {
        $dimen = $dimen . " $oradius_cup[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_cup; $i++) {
        $dimen = $dimen . " $zplane_cup[$i]*mm";
    }
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = 1;

    #	print_det(\%configuration, \%detector);


    #############################
    # Tungsten Cone
    #############################
    %detector = init_det();
    $detector{"name"} = "ft_w_cone";
    $detector{"mother"} = "ft_shield";
    $detector{"description"} = "ft tungsten cone";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes_cone*counts";
    for (my $i = 0; $i < $nplanes_cone; $i++) {
        $dimen = $dimen . " $iradius_cone[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_cone; $i++) {
        $dimen = $dimen . " $oradius_cone[$i]*mm";
    }
    for (my $i = 0; $i < $nplanes_cone; $i++) {
        $dimen = $dimen . " $zplane_cone[$i]*mm";
    }
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "ft_W";
    $detector{"style"} = 1;

    print_det(\%configuration, \%detector);


    #############################
    #       Aluminum Tube
    #############################
    %detector = init_det();
    $detector{"name"} = "ft_al_tube";
    $detector{"mother"} = "ft_shield";
    $detector{"description"} = "ft aluminum beam pipe";
    $detector{"pos"} = "0*mm 0.0*mm $al_tube_Z*mm";
    $detector{"color"} = "F2F2F2";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$al_tube_IR*mm $al_tube_OR*mm $al_tube_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #############################
    # Aluminum Window
    #############################
    %detector = init_det();
    $detector{"name"} = "ft_al_window";
    $detector{"mother"} = "ft_shield";
    $detector{"description"} = "ft aluminum beam pipe window";
    $detector{"pos"} = "0*mm 0.0*mm $al_window_Z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "F2F2F2";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0.0*mm $al_window_OR*mm $al_window_TN*mm 0.*deg 360.*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #############################
    # Vacuum inside the cone
    #############################
    %detector = init_det();
    $detector{"name"} = "ft_albpipe_vacuum";
    $detector{"mother"} = "ft_shield";
    $detector{"description"} = "ft aluminum beam pipe vacuum";
    $detector{"pos"} = "0*mm 0.0*mm $al_tube_Z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0.0*mm $al_tube_IR*mm $al_tube_LT*mm 0.*deg 360.*deg";
    $detector{"material"} = "Vacuum";
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);

}
