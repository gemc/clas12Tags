
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

my $bankID   = 2300;
my $bankname = "urwell";

sub define_bank
{
    # uploading the hit definition
    insert_bank_variable(\%configuration, $bankname, "bankid",   $bankID, "Di", "$bankname bank ID");
    insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "sector number");
    insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "layer number");
    insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "strip number");
    insert_bank_variable(\%configuration, $bankname, "ADC_order",    4, "Di", "always 0");
    insert_bank_variable(\%configuration, $bankname, "ADC_ADC",      5, "Di", "ADC");
    insert_bank_variable(\%configuration, $bankname, "ADC_time" ,    6, "Dd", "always 0");
    insert_bank_variable(\%configuration, $bankname, "ADC_ped" ,     7, "Di", "always 0");
    insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}


