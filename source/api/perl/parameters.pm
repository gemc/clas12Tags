package parameters;
require Exporter;

use lib ("$ENV{GEMC}/io");
use utils;

@ISA = qw(Exporter);
@EXPORT = qw(upload_parameters print_parameters get_parameters get_volumes);


# Utility to upload the parameters from the file "parameters.txt"
sub upload_parameters
{
	my (%configuration)   = @_;
	my $dbh = open_db(%configuration);
	
	my $table   = $configuration{"detector_name"}."__parameters";
	my $varia   = $configuration{"variation"};
	my $rmin    = $configuration{"rmin"};
	my $rmax    = $configuration{"rmax"};
	my $next_id = get_last_id($dbh, $table, $varia) + 1;
	
	# Insert parameters into table for the variation, run min, run max. Increment id for this set.
	$dbh->do("LOAD DATA LOCAL INFILE '$table\_$varia.txt' \
		INTO TABLE $table                               \
		FIELDS TERMINATED BY '|'                        \
		LINES TERMINATED BY '\n'                        \
		(name, value, units, description, author, author_email, pdf_drawing_link, drawing_varname, drawing_authors, drawing_date) \
		SET variation = '$varia', rmin = $rmin , rmax = $rmax , id = $next_id ");
		
		if($configuration{"verbosity"} > 1)
	{
		print " * Parameters uploaded in database: \n";
		print_parameters(%configuration);
		print " \n";
	}
	print "   > This Parameter ID: ", $next_id,    "\n";
	
	$dbh->disconnect();
}


# utility to print out the parameters
sub print_parameters
{
	my (%configuration)   = @_;
	my $dbh = open_db(%configuration);
	
	my $table = $configuration{"detector_name"}."__parameters";
	my $varia = $configuration{"variation"};
	my $rmin  = $configuration{"rmin"};
	my $rmax  = $configuration{"rmax"};
	
	# get the last ID for this table and variation
	my $last_id = get_last_id($dbh, $table, $varia);
	
	# Get the correct run ranges and the latest version
	my $query = $dbh->prepare("SELECT * from $table where variation = '$varia' and rmin<=$rmin and rmax >=$rmax and id = '$last_id' ");
	$query->execute();
	
	while (my @data = $query->fetchrow_array())
	{
		my $pnam = $data[0];
		my $pval = $data[1];
		my $puni = $data[2];
		my $pdes = $data[3];
		my $paut = $data[4];
		my $pema = $data[5];
		my $plin = $data[6];
		my $pdna = $data[7];
		my $pdau = $data[8];
		my $pdda = $data[9];
		print "  - Parameter name: $pnam \n";
		print "  - Value: $pval $puni \n";
		print "  - Description: $pdes \n";
		print "  - Author: $paut   email:  $pema \n";
		print "  - Link to Drawing or Document: $plin \n";
		print "  - Variable name on the drawing: $pdna \n";
		print "  - Drawing Author: $pdau.  \n\n";
	}
	
	$dbh->disconnect();
}


# Utility to get a hash map with the parameters
sub get_parameters
{
	my (%configuration)   = @_;
	my $varia = $configuration{"variation"};
	my %parameters = ();
	
	# Text Factory. The parameter file is assumed to be present
	# and named "parameters.txt"
	if($configuration{"factory"} eq "TEXT")
	{
		my  $file = $configuration{"detector_name"}."__parameters_".$varia.".txt";
		open(FILE, $file) or die("Open failed on file $file: $!");
		my @lines = <FILE>;
		close(FILE);
 		foreach my $line (@lines)
		{
			my @numbers = split(/[|]+/,$line);
			my ($pnam, $pval) = @numbers;
			$parameters{trim($pnam)} = trim($pval);
		}
	}
	
	if($configuration{"factory"} eq "MYSQL")
	{
		my $dbh = open_db(%configuration);
		
		my $table   = $configuration{"detector_name"}."__parameters";
		my $varia   = $configuration{"variation"};
		my $rmin    = $configuration{"rmin"};
		my $rmax    = $configuration{"rmax"};
		my $this_id = get_last_id($dbh, $table, $varia)  ;
		
        
		# Get the correct run ranges and the latest version
		my $query = $dbh->prepare("SELECT * from $table where variation = '$varia' and rmin<=$rmin and rmax >=$rmax  and id = '$this_id' ");
		$query->execute();
		
		while (my @data = $query->fetchrow_array())
		{
			my $pnam = trim($data[0]);
			my $pval = trim($data[1]);
			my $puni = trim($data[2]);
			
			$parameters{$pnam} = $pval;
		}
		$dbh->disconnect();
		
	}
	
	
	if($configuration{"verbosity"} > 0)
	{
		foreach my $key ( keys %parameters )
		{
			print " * Parameter \"$key\" loaded with value: $parameters{$key} \n";
		}
	}
	
	
	print "\n";
	return %parameters;
}

# Utility to get a hash maps with the volumes
# Subroutine to read txt file with volumes from COATJAVA FTOF factory
sub get_volumes
{
	my (%configuration) = @_;
	my $varia = $configuration{"variation"};

	# Hash maps to populate from volumes files
	my %mothers = ();
	my %positions = ();
	my %rotations = ();
	my %types = ();
	my %dimensions = ();
	my %ids= ();
	
	# Text Factory. The volumes file is assumed to be present
	# and named "volumes.txt"
	# If it is not present run COATJAVA Detector Factory to create it
	my  $file = $configuration{"detector_name"}."__volumes_".$varia.".txt";
	open(FILE, $file) or die("Open failed on file $file: $! (Run factory.groovy to create this file)");
	my @lines = <FILE>;
	close(FILE);
 	foreach my $line (@lines)
	{
		my @vvalues = split('[|]+',$line);

		# Assign fields to corresponding hash maps
		$vnam = trim($vvalues[0]);
		$mothers{$vnam} = trim($vvalues[1]);
		$positions{$vnam} = trim($vvalues[2]);
		$rotations{$vnam} = trim($vvalues[3]);
		$types{$vnam} = trim($vvalues[4]);
		$dimensions{$vnam} = trim($vvalues[5]);
		$ids{$vnam} = trim($vvalues[6]);
	}

	if($configuration{"verbosity"} > 0)
	{
		foreach my $key ( keys %dimensions)
		{
			print " * Parameter \"$key\" loaded with dimenstions: $mothers{$key} \n";
			print " * Parameter \"$key\" loaded with dimenstions: $positions{$key} \n";
			print " * Parameter \"$key\" loaded with dimenstions: $rotations{$key} \n";
			print " * Parameter \"$key\" loaded with dimenstions: $types{$key} \n";
			print " * Parameter \"$key\" loaded with dimenstions: $dimensions{$key} \n";
		}
	}

	print "\n";
	return (\%mothers, \%positions, \%rotations, \%types, \%dimensions, \%ids);
}

