
class GeoArgParse {
    static String defaultVariation="default";
    static int defaultRunNumber=11;
    static String getVariation(String[] args) {
        for (int ii=0; ii<args.length-1; ii++) {
            if (args[ii].equals("--variation")) return args[ii+1];
        }
        throw new RuntimeException("GeoArgParse:  '--variation variationName' is required.");
    }
    static int getRunNumber(String[] args) {
        for (int ii=0; ii<args.length-1; ii++) {
            if (args[ii].equals("--runnumber")) return Integer.parseInt(args[ii+1]);
        }
        throw new RuntimeException("GeoArgParse:  '--runnumber runNumber' is required.");
    }
        
}

