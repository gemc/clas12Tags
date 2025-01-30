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

sub define_bank
{
	my $bankname = shift;
	my $bankId   = shift;	
	
	insert_bank_variable(\%configuration, $bankname, "bankid",   $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "atof sector");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "wedge+bar (quarter of sector)");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "z slice 0 to 9 for wedge, 10 for bar");
	insert_bank_variable(\%configuration, $bankname, "TDC_order",    4, "Di", "order 0/1 for up/downstream bar, 0 for wedge");
	insert_bank_variable(\%configuration, $bankname, "TDC_TDC",      5, "Di", "TDC");
	insert_bank_variable(\%configuration, $bankname, "TDC_ToT" ,     6, "Di", "ToT");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

sub define_banks {
	define_bank("atof", 22500);
}

