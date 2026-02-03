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
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "recoil tof sector");
	insert_bank_variable(\%configuration, $bankname, "row",        2, "Di", "recoil tof row");
	insert_bank_variable(\%configuration, $bankname, "column",    3, "Di", "recoil tof column");
	insert_bank_variable(\%configuration, $bankname, "TDC_order",    4, "Di", "order 0/1 for up/downstream");
	insert_bank_variable(\%configuration, $bankname, "TDC_TDC",      5, "Di", "TDC");
	insert_bank_variable(\%configuration, $bankname, "TDC_ToT" ,     6, "Di", "ToT");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

sub define_banks {
	define_bank("recoil_tof", 22700);
}

