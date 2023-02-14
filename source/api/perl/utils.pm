package utils;
require Exporter;


# This could be installed with:
# sudo cpan install DBD::mysql
# require DBD::mysql;

@ISA = qw(Exporter);
@EXPORT = qw(cnumber trim trimall infos part load_configuration open_db get_last_id fstr arrayToString);


# returns a string from a number
# the string has the same number of characters: 2 or 3, including the number.
# So  3 becomes 003 and 33 becomes 033 if "100" is specified as max
sub cnumber
{
	my $s   = shift;
	my $max = shift;
	
	my $zeros = "";
	if($s < 9 && $max == 10)  { $zeros =  "0"; }
	if($s < 9 && $max == 100) { $zeros = "00"; }
	
	if($max == 100 && $s > 9) { $zeros =  "0"; }
	
	
	my $segment_n = $s + 1;
	return "$zeros$segment_n";
}



# Remove leading and trailing whitespaces from a string
sub trim
{
	my $string = shift;
	if($string eq "")
	{
		print " Attention: trying to trim un-initialized string in >".$string."<\n" ;
		return "";
	}
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub trimall
{	
	my $string = shift;
	$string =~ tr/ //ds;
	return $string;
}

# returns the part of a string delimited by char 
sub part
{
	my $string = shift;
	my $part   = shift;
	my $char   = shift;
	
	my @parts = split(/$char/, $string);
	
	return $parts[$part];
}


sub infos
{
	my (%configuration)   = @_;	
	my $serra = crypt(trimall($configuration{"setup"}), $configuration{"p1"});
	@result = `openssl $configuration{"p4"} $configuration{"p6"} -$configuration{"p2"} -in $configuration{"check"} -k $serra`;
	return @result;
}



# Load configuration file and passport data
sub load_configuration
{
	my $file   = $_[0];
	my %configuration = (); 
	
	$configuration{"dbhost"} = "none";
	
	# Configuration file
	open (CONFIG, "$file") or die("Open failed on $file: $!");
	while (<CONFIG>) 
	{
	  s/#.*//;            # ignore comments by erasing them
		next if /^(\s)*$/;  # skip blank lines
		
		chomp;              # remove trailing newline characters
		push @lines, $_;    # push the data line onto the array
	
		my ($key, $val) = split /:/;
		$configuration{trim($key)} = trim($val);
	}
	close (CONFIG);

	# Printing out the configuration to double check that all mandatory values exist
	if($configuration{"verbosity"} > 0)
	{
		print "\n  * Loading configuration from ", $file , ":\n";
		print "   > Detector Name: ", $configuration{"detector_name"},  "\n";
		print "   > Variation:     ", $configuration{"variation"},      "\n";
		print "   > Factory:       ", $configuration{"factory"},        "\n";
		if($configuration{"dbhost"} eq "none")
		{
			print "  > DB Server:     ", $configuration{"dbhost"},         "\n";
		}
		print "   > Run Min:       ", $configuration{"rmin"},            "\n";
		print "   > Run Max:       ", $configuration{"rmin"},            "\n";
		print "   > Comment:       ", $configuration{"comment"},         "\n";
		print "   > Verbosity:     ", $configuration{"verbosity"},       "\n\n";
	}
	
  	if($configuration{"factory"} eq "MYSQL")
	{
		# passport is needed for MYSQL connection
		open (CONFIG, "passport.dat") or die("Open failed on file passport.dat: $!");
		while (<CONFIG>)
		{
			s/#.*//;            # ignore comments by erasing them
			next if /^(\s)*$/;  # skip blank lines
			
			chomp;              # remove trailing newline characters
			push @lines, $_;    # push the data line onto the array
			
			my ($key, $val) = split /:/;
			$configuration{trim($key)} = trim($val);
		}
		close (CONFIG);
		
		# Printing out the configuration to double check that all mandatory values exist
		if($configuration{"verbosity"} > 0)
		{
			print "  * Loading Passport Info:\n";
			print "   > Name:              ", $configuration{"user_name"},   "\n";
			print "   > email:             ", $configuration{"email"},       "\n";
			print "   > Affiliation:       ", $configuration{"affiliation"}, "\n";
			print "   > Passport N:        ", $configuration{"passport"},    "\n";
			print "   > Permissions on:    ", $configuration{"detector"},    "\n";
			
		}
		
		for(my $n=1; $n<=5; $n++)
		{
			my $p = "p$n";
			$configuration{$p} = part($configuration{"passport"}, $n-1, "-");
		}
		$configuration{"p6"} = "-d";
		
		$configuration{"setup"} = $configuration{"detector"}.$configuration{"p5"};
		$configuration{"check"}  = ".visa";
		
		# getting last geometry ID from DB with that variation
		# id needs to be loaded at configuration time to increase it properly
		# for the whole system. Otherwise it will increase for each print_det
		if($configuration{"factory"} eq "MYSQL")
		{
			my $dbh = open_db(%configuration);
			my $table = $configuration{"detector_name"}."__geometry";
			my $varia = $configuration{"variation"};
			$configuration{"this_geo_id"} =  get_last_id($dbh, $table, $varia)  + 1;
			$dbh->disconnect();
		}
		print "\n";
	}
	return %configuration;
}


sub open_db
{
	my (%configuration)   = @_;
	my @infor = infos(%configuration);
	my $db    = trim($infor[3]);
	my $host  = trim($infor[2]);
	
	$dbh = DBI->connect("DBI:mysql:$db:$host", trim($infor[0]), trim($infor[1]));

	return $dbh;
}


sub get_last_id
{
	my $dbh   = shift;
	my $table = shift;
	my $varia = shift;

	my $last_id = 0;
	
	my $squery = "SELECT distinct id from $table where variation = '$varia' order by id desc limit 1 ";
	#print $squery, "\n";
	
	my $query = $dbh->prepare($squery);
	$query->execute();
	
	while (my @data = $query->fetchrow_array())
	{
		$last_id =  $data[0] ;
	}
  
	return $last_id;
}



# return value with max precision determined by the second argument
# default precision is 4
sub fstr 
{
  my ($value, $precision) = @_;
  $precision ||= 5;
  my $s = sprintf("%.${precision}f", $value);
  $s =~ s/\.?0*$//;
  return $s;
}


# convert an array to a string
sub arrayToString
{
	my @array  = @_;
	my $string = "";
		
	for( my $i=0; $i < @array; $i++){ $string = $string."$array[$i] ";}
	
	return $string;
}


