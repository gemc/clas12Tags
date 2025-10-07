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



sub define_mucal_bank
{
	# uploading the hit definition
	my $bankId = 2100;
	my $bankname = "ft_cal";
	
	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "idx",          1, "Di", "idx number");
	insert_bank_variable(\%configuration, $bankname, "idy",          2, "Di", "idy number");
	insert_bank_variable(\%configuration, $bankname, "adc",          3, "Di", "adc");
	insert_bank_variable(\%configuration, $bankname, "tdc",          4, "Di", "tdc");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}


1;










