# Coatjava installation

The script `install_coatjava.sh` installs the CLAS12 software package coatjava.

### Prerequisites

* A Linux or Mac computer
* Java Development Kit 11 or newer
* maven

### Usage:

```
Usage: install_coatjava.sh [-d] [-t tag]
  -d: use coatjava development version
  -t tag: use coatjava tag version
  -g github_url: use a custom github url
  ```

### Coatjava environment:

After installation, set the environment accordingly. For example:

```
export COATJAVA=/opt/projects/gemc/detectors/clas12/coatjava
export PATH=$PATH:$COATJAVA/bin
```

### Versions:

- Clas12Tags 5.10 -> Coatjava 10.0.2
- Clas12Tags 5.11 -> Coatjava 11.0.4

### SQLite initialization

$GEMC/api/perl/sqlite.py -n clas12.sqlite

### CLAS12 Run numbers vs Run groups

Source: [calcom run groups](https://clasweb.jlab.org/wiki/index.php/CLAS12_Calibration_and_Commissioning/clas12-run-ranges)

|                    |               | 
|--------------------|---------------|
| rga_spring2018     | 3029 - 4326   |
| rga_fall2018       | 4763-5666     |
| rga_spring2019     | 6608-6783     |
|                    |               |
| rgb_spring2019     | 6150 – 6603   |
| rgb_fall2019       | 11093 – 11301 |
| rgb_winter20       | 11323 - 11571 |
|                    |               |
| rgc_summer2022     | 16043-16772   |
| rgc_fall2022       | 16843-17408   |
| rgc_winter23       | 17471-17811   |
|                    |               |
| rgd_fall2023       | 18305 - 19131 |
|                    |               |
| rgf_spring2020     | 11620 - 12282 |
| rgf_summer2020     | 12389 - 12951 |
|                    |               |
| rgk_fall2018_FTOn  | 5674 - 5870   |
| rgk_fall2018_FTOff | 5874-6000     |
| rgk_winter23       | 19200 - 19260 |
| rgk_spring24       | 19300 - 19893 |
|                    |               |
| rgm_fall2021       | 15016 - 15884 |
|                    |               |
| rge_spring2024     |               |

