package hit;
require Exporter;

use lib ("$ENV{GEMC}/io");
use utils;
use 5.010;

@ISA = qw(Exporter);
@EXPORT = qw(init_hit print_hit);


# Initialize hash maps
sub init_hit
{
	my %hit = ();
	
	# The default value for identifier is "id"
	$hit{"identifiers"} = "id";
	return %hit;
}


# Print hit to TEXT file or upload it onto the DB
sub print_hit
{
	my %configuration = %{+shift};
	my %hit           = %{+shift};
	
	my $table   = $configuration{"detector_name"}."__hit";
	my $varia   = $configuration{"variation"};
	my $rmin    = $configuration{"rmin"};
	my $rmax    = $configuration{"rmax"};
	
	
	# converting the hash maps in local variables
	# (this is necessary to parse the MYSQL command)
	
	my $lname             = trim($hit{"name"});
	my $ldescription      = trim($hit{"description"});
	my $lidentifiers      = trim($hit{"identifiers"});
	my $lSignalThreshold  = trim($hit{"signalThreshold"});
	my $lTimeWindow       = trim($hit{"timeWindow"});
	my $lProdThreshold    = trim($hit{"prodThreshold"});
	my $lMaxStep          = trim($hit{"maxStep"});
	my $lriseTime         = trim($hit{"riseTime"});
	my $lfallTime         = trim($hit{"fallTime"});
	my $lmvToMeV          = trim($hit{"mvToMeV"});
	my $lpedestal         = trim($hit{"pedestal"});
	my $ldelay            = trim($hit{"delay"});
	
	# after 5.10 once can use "state" to use a static variable`
	state $counter = 0;
	state $this_variation = "";

	# TEXT Factory
	if($configuration{"factory"} eq "TEXT")
	{
		my $file = $configuration{"detector_name"}."__hit_".$varia.".txt";
		if($counter == 0 || $this_variation ne  $varia)
		{
			`rm -f $file`;
			print "Overwriting if existing: ",  $file, "\n";
			$counter = 1;
			$this_variation = $varia;
		}
		
		open(INFO, ">>$file");
		printf INFO ("%20s  |", $lname);
		printf INFO ("%30s  |", $ldescription);
		printf INFO ("%40s  |", $lidentifiers);
		printf INFO ("%8s   |", $lSignalThreshold);
		printf INFO ("%8s   |", $lTimeWindow);
		printf INFO ("%8s   |", $lProdThreshold);
		printf INFO ("%8s   |", $lMaxStep);
		printf INFO ("%8s   |", $lriseTime);
		printf INFO ("%8s   |", $lfallTime);
		printf INFO ("%8s   |", $lmvToMeV);
		printf INFO ("%8s   |", $lpedestal);
		printf INFO ("%8s  \n", $ldelay);
		close(INFO);
	}
	
	# MYSQL Factory
	my $err;
	if($configuration{"factory"} eq "MYSQL")
	{
		my $dbh = open_db(%configuration);
		
		$dbh->do("insert into $table( \
			         name,    description,    identifiers,    signalThreshold,    timeWindow,    prodThreshold,    maxStep,    riseTime,     fallTime,    mvToMeV,    pedestal,    delay,   variation) \
			values(     ?,              ?,              ?,                  ?,             ?,                ?,          ?,           ?,            ?,          ?,           ?,        ?,           ?) ON DUPLICATE KEY UPDATE \
			       name=?,  description=?,  identifiers=?,  signalThreshold=?,  timeWindow=?,  prodThreshold=?,  maxStep=?,  riseTime=?,   fallTime=?,  mvToMeV=?,  pedestal=?,  delay=?, variation=?, \
			       time=CURRENT_TIMESTAMP",  undef,
		           $lname,  $ldescription,  $lidentifiers,  $lSignalThreshold,  $lTimeWindow,  $lProdThreshold,  $lMaxStep,  $lriseTime,   $lfallTime,  $lmvToMeV,  $lpedestal,  $ldelay,      $varia,
		           $lname,  $ldescription,  $lidentifiers,  $lSignalThreshold,  $lTimeWindow,  $lProdThreshold,  $lMaxStep,  $lriseTime,   $lfallTime,  $lmvToMeV,  $lpedestal,  $ldelay,      $varia)
		
		or die "SQL Error: $DBI::errstr\n";
		
		$dbh->disconnect();
	}
	
	if($configuration{"verbosity"} > 0)
	{
		print "  + Hit $lname uploaded successfully for variation \"$varia\" \n";
	}
}


1;





