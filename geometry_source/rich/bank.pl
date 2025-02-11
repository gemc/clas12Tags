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

my $bankId = 1800;
my $bankname = "rich";

sub define_bank {

    # uploading the hit definition
    insert_bank_variable(\%configuration, $bankname, "bankid", $bankId, "Di", "$bankname bank ID");
    insert_bank_variable(\%configuration, $bankname, "sector",       1, "Di", "clas12 sector");
    insert_bank_variable(\%configuration, $bankname, "layer",        2, "Di", "tile id");
    insert_bank_variable(\%configuration, $bankname, "component",    3, "Di", "maroc channel id");
    insert_bank_variable(\%configuration, $bankname, "TDC_order",    4, "Di", "order: 2 - TDCL , 3 - TDCR");
    insert_bank_variable(\%configuration, $bankname, "TDC_TDC",      5, "Di", "TDC value");
    insert_bank_variable(\%configuration, $bankname, "hitn",        99, "Di", "hit number");
}

define_bank();

1;
