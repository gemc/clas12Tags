use strict;
use warnings;

our %configuration;

# Variable Type is two chars.
# The first char:
#  R for raw integrated variables
#  D for dgt integrated variables
#  S for raw step by step variables
#  M for digitized multi-hit variables
#  V for voltage(time) variables
#
# The second char:
# i for integers
# l for longs
# d for doubles

my $bankId   = 1000;
my $bankname = "ftof";

sub define_bank {

	# uploading the hit definition
	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector (1-6)");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer (1: 1A, 2: 1B, 3: 2B)");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "paddle");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "side: 0 - ADCL , 1 - ADCR");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC integral from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "time from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "pedestal from pulse analysis");
	insert_bank_variable(\%configuration, $bankname, "TDC_order",    8, "Di", "side: 2 - TDCL , 3 - TDCR");
	insert_bank_variable(\%configuration, $bankname, "TDC_TDC",      9, "Di", "TDC value");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}


