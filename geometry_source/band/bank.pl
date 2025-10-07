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
# d for doubles

my $bankId   = 2100;
my $bankname = "band";

sub define_bank
{
	
	# uploading the hit definition
	insert_bank_variable(\%configuration, $bankname, "bankid",   $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",         1, "Di", "sector number");
	insert_bank_variable(\%configuration, $bankname, "layer",          2, "Di", "layer number");
	insert_bank_variable(\%configuration, $bankname, "component",      3, "Di", "component number");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",      4, "Di", "side of PMT L or R");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",        5, "Di", "ADC value");
	insert_bank_variable(\%configuration, $bankname, "ADC_amplitude",  6, "Di", "amplitude");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,      7, "Dd", "flash adc time");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,       8, "Di", "pedestal");
	insert_bank_variable(\%configuration, $bankname, "TDC_order",      9, "Di", "side of PMT + 2");
	insert_bank_variable(\%configuration, $bankname, "TDC_TDC",       10, "Di", "TDC value");
	insert_bank_variable(\%configuration, $bankname, "hitn",          99, "Di", "hit number");
}
