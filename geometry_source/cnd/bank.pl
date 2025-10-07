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

my $bankId = 300;
my $bankname = "cnd";

sub define_bank {

    # uploading the hit definition
    insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
    insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "CND sector (paddle id");
    insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "CND layer");
    insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "always 1");
    insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "0 = left side, 1 = right side");
    insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC value");
    insert_bank_variable(\%configuration, $bankname, "ADC_time",     6, "Dd", "same as TDC");
    insert_bank_variable(\%configuration, $bankname, "ADC_ped",      7, "Di", "pedestal");
    insert_bank_variable(\%configuration, $bankname, "TDC_order",    8, "Di", "2 = direct, 3 = indirect hit");
    insert_bank_variable(\%configuration, $bankname, "TDC_TDC",      9, "Di", "TDC value");
    insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

