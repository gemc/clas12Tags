package bank;
require Exporter;

use lib ("$ENV{GEMC}/io");
use utils;
use 5.010;

@ISA = qw(Exporter);
@EXPORT = qw(insert_bank_variable);


# Print bank to TEXT file or upload it onto the DB
sub insert_bank_variable
{
	
	if (@_ != 6)
	{
		print " ERROR: To define a bank variable 4 arguments should be passed to <insert_bank_variable> \n";
	}
	
	my %configuration = %{+shift};
	
	my $table   = $configuration{"detector_name"}."__bank";
	my $varia   = $configuration{"variation"};
	
	my $bname        = shift;  # bank name
	my $lname        = shift;  # variable name
	my $lnum         = shift;  # variable int (unique id)
	my $ltype        = shift;  # variable type
	my $ldescription = shift;  # description
	
	# after 5.10 once can use "state" to use a static variable`
	state $counter = 0;

	# TEXT Factory
	if($configuration{"factory"} eq "TEXT")
	{
		my $file = $configuration{"detector_name"}."__bank.txt";
		if($counter == 0)
		{
			`rm -f $file`;
			print "Overwriting if existing: ",  $file, "\n";
			$counter = 1;
		}
		
		open(INFO, ">>$file");
		printf INFO ("%20s  |",  $bname);
		printf INFO ("%20s  |",  $lname);
		printf INFO ("%50s  |",  $ldescription);
		printf INFO ("%5s   |",  $lnum);
		printf INFO ("%20s  \n", $ltype);
		close(INFO);
	}
	
	# MYSQL Factory
	if($configuration{"factory"} eq "MYSQL")
	{
		my $dbh = open_db(%configuration);
		
		
		$dbh->do("insert into $table ( \
			         bankname,    name,    description,     num,    type,   variation) \
			values(         ?,       ?,              ?,       ?,       ?,           ?) ON DUPLICATE KEY UPDATE \
			       bankname=?,  name=?,  description=?,   num=?,  type=?, variation=?, \
			       time=CURRENT_TIMESTAMP",  undef,
			           $bname,  $lname,  $ldescription,   $lnum,  $ltype,       $varia,
			           $bname,  $lname,  $ldescription,   $lnum,  $ltype,       $varia)
			
			or die "SQL Error: $DBI::errstr\n";
		
		
		$dbh->disconnect();
	}
	
	
	if($configuration{"verbosity"} > 0)
	{
		print "  + variable $lname uploaded successfully for variation \"$varia\" \n";
	}
	
	
}


1;





