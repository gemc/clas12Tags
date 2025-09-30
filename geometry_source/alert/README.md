# Alert 

The geometry version uses the Coatjava geometry

## AHDC 

```java
from import org.jlab.geom.detector.alert.AHDC.*;
/common-tools/clas-geometry/src/main/java/org/jlab/geom/detector/alert/AHDC/
MYFactory_ALERTDCWire.java
```

Inside factory_ahdc.groovy: 

```java
MYFactory_ALERTDCWire factory = new MYFactory_ALERTDCWire();
Detector ahdc = factory.createDetectorCLAS(cp);
```

All AHDC is enclosed into mother volume (tube with a hole for target) ahdc_mother

1. AHDC cell = 2 sub-cells, 2 generic trapezoides.
Identifiers of each sub-cell = superlayer, layer, wire number.
sector is always =1.

2. sub-cells belonging to the same cell have exactly the same identifier!

- superlayers numbering from #0 to #4
- layers numbering from #0 to #1
- cells numbering from #1 to #number_of_cells_in_superlayer





# ATOF

Coatjava geometry:

```java
from import org.jlab.geom.detector.alert.ATOF.*;
/common-tools/clas-geometry/src/main/java/org/jlab/geom/detector/alert/ATOF/
MYFactory_ATOF_NewV2.java
```

Inside factory_atof.groovy, the class is used

```java
MYFactory_ATOF_NewV2 factory = new MYFactory_ATOF_NewV2();
Detector atof = factory.(cp);
```

All ATOF is enclosed into mother volume (tube with a hole for AHDC) atof_mother

Identifiers of each cell = sector, superlayer, layer, paddle.
Paddle is a regular trapezoid.

- sectors numbering from #0 to #14
- superlayers numbering from #0 to #1
- layers numbering from #0 to #9
- paddles numbering from (\$sector · 4 + 1) to (\$sector · 4 + \$npaddles)
- \$npaddle = 4



