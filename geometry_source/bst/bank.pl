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
# Notice: for hit process routines, only D is allowed.
#
# The second char:
# i for integers
# d for doubles

my $bankId   = 100;
my $bankname = "bst";

sub define_bank
{
	# uploading the hit definition
	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector number");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer number");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "strip number");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "3 bit ADC");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "8 bit time info (bco)");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}
