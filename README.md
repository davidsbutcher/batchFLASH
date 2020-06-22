batchFLASH
================

## Installation

Install from GitHub:

``` r
remotes::install_github("davidsbutcher/batchFLASH")
```

## Usage

To run all raw files in a directory:

``` r
run_batch_FD(
   "C:/Users/Scientist/Documents/raw_file_directory",
   "C:/Users/Scientist/Documents/batchFLASH_output/good_data"
)
```

To run a single raw file:

``` r
run_batch_FD(
   "C:/Users/Scientist/Documents/raw_file_directory/good_raw_file.raw",
   "C:/Users/Scientist/Documents/batchFLASH_output/good_data"
)
```

### Arguments

  - `inputDir` Can be an mzML file or a directory containing mzML files.

  - `outputDir` Output directory for tab-delimited text files generated
    by FLASHDeconv.

  - `FDargs` Arguments to FLASHDeconv. Defaults to `c("-RTwindow 20",
    "-minRTspan 3")`.

## License and attribution

The FLASHDeconv binary is part of the [OpenMS software
library](dx.doi.org/10.1038/nmeth.3959) and is licensed under the
three-clause BSD license (see bin/license/OpenMS/LICENSE.txt).

Qt Core is licensed under [LGPL-3](https://doc.qt.io/qt-5/lgpl.html).
Third-party modules included in Qt Core and their respective licenses
are listed at the [Qt Core
website](https://doc.qt.io/qt-5/qtcore-index.html).

All other components are written by David S. Butcher and available under
Creative Commons CC0.
