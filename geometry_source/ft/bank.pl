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

# The ft banks id are:
#
# Tracker (cal): 900
# Tracker (trk): 800
# Tracker (hodo): 700


sub define_cal_bank
{
	# uploading the hit definition
	my $bankId = 900;
	my $bankname = "ft_cal";

	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector (=1)");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer (=1)");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "crystal");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC integral from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "time from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "pedestal from pulse analysis");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

sub define_hodo_bank
{
	# uploading the hit definition
	my $bankId = 800;
	my $bankname = "ft_hodo";

	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector (1-8)");
	insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer (1-2)");
	insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "component number");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC integral from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "time from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "pedestal from pulse analysis");
	insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

sub define_trk_bank
{
	# uploading the hit definition
	my $bankId   = 700;
	my $bankname = "ft_trk";
	
	insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
	insert_bank_variable(\%configuration, $bankname, "sector",         1, "Di", "sector (=1)");
	insert_bank_variable(\%configuration, $bankname, "layer",          2, "Di", "layer (1-4)");
	insert_bank_variable(\%configuration, $bankname, "component",      3, "Di", "strips");
	insert_bank_variable(\%configuration, $bankname, "ADC_order",      4, "Di", "always 0");
	insert_bank_variable(\%configuration, $bankname, "ADC_ADC",        5, "Di", "ADC maximum");
	insert_bank_variable(\%configuration, $bankname, "ADC_time" ,      6, "Dd", "time from pulse fit");
	insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,       7, "Di", "pedestal from pulse analysis");
	insert_bank_variable(\%configuration, $bankname, "ADC_integral" ,  8, "Di", "ADC integral (sum over the pulse)");
	insert_bank_variable(\%configuration, $bankname, "ADC_timestamp" , 9, "Di", "timestamp");
	insert_bank_variable(\%configuration, $bankname, "hitn",          99, "Di", "hit number");
}




sub define_banks
{
	define_trk_bank();
	define_hodo_bank();
	define_cal_bank();
}

1;










