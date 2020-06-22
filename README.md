Untitled
================

## Installation

Install from GitHub:

``` r
remotes::install_github("davidsbutcher/batchFLASH")
```

## Usage

### Arguments

  - `inputDir` Can be an mzML file or a directory containing mzML files.

  - `outputDir` Output directory for tab-delimited text files generated
    by FLASHDeconv.

  - `FDargs` Arguments to FLASHDeconv. Defaults to `c("-RTwindow 20",
    "-minRTspan 3")`.

## Licensing and attribution

The FLASHDeconv binary is part of the [OpenMS software
library](dx.doi.org/10.1038/nmeth.3959) and is licensed under the
three-clause BSD license (see bin/license/OpenMS/LICENSE.txt).

Qt Core is licensed under [LGPL-3](https://doc.qt.io/qt-5/lgpl.html).
Third-party modules included in Qt Core and their respective licenses
are listed at the [Qt Core
website](https://doc.qt.io/qt-5/qtcore-index.html).

All other components are written by David S. Butcher and available under
Creative Commons CC0.
