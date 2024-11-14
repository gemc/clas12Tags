# commands to generate text files for alert.gcard
# copy and paste in your terminal all lines that do not start with:
# this should be done from the directory where this file is located 
cd ../targets
./targets.pl config.dat
cd ../alert/ahdc
run-groovy factory.groovy --variation default --runnumber 11
run-groovy factory.groovy --variation rga_fall2018 --runnumber 11
./ahdc.pl config.dat
cd ../atof
run-groovy factory.groovy --variation default --runnumber 11
run-groovy factory.groovy --variation rga_fall2018 --runnumber 11
./atof.pl config.dat
cd ../external_shell_nonActif
./alertshell.pl config.dat
cd ../He_bag
./hebag.pl config.dat
cd ../
