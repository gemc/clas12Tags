use strict;
use warnings;
use bank;

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


sub define_BMT_bank
{
	my $bankname = shift;
	my $bankID   = shift;
	
	# uploading the hit definition
	insert_bank_variable(\%configuration, $bankname, "bankid",   $bankID, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector number");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer number");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "strip number");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "time");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}


sub define_bank
{
	define_BMT_bank("bmt", 200);
}
