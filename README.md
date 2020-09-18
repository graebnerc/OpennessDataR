# Data on economic openness

[To the data homepage](https://graebnerc.github.io/OpennessDataR/)

This packages complements Gräbner *et al.* (2020) by providing the full openness 
data set and the means to update it automatically.

More information about the data summarized in the package and links to the 
original sources can be found on the
[official data homepage](https://graebnerc.github.io/OpennessDataR/),
where we also provide further information about the corresponding paper.

## Using the data

The package gets regularly updated to make sure that the current data set
is the most recent one. 
We suggest visiting the [official data homepage](https://graebnerc.github.io/OpennessDataR/)
to download the data directly.
If you feel that an update is necessary - or you have any other query -
please use the issue tracker of the 
[Github page](https://github.com/graebnerc/OpennessDataR) of the package
or contact Claudius [directly](https://claudius-graebner.com/contact-1.html).

The package contains two data sets: one with yearly data and one with 
5-year averages. After installing the package you can use them via one of
the following ways (with no need to attach the package):
first, use `data()`:

```
data("openness_1y", package = "OpennessDataR")
data("openness_5y", package = "OpennessDataR")
```

The second option is to reference the data directly:

```
openness_1y = OpennessDataR::openness_1y
openness_5y = OpennessDataR::openness_5y
```

In both cases you can immediately use the data without needing to attach the
actual package.


## Updating the data manually

Do update the data you have to download the source code of the package and
run the file `openness_1-csv.R`.
On top of the file you can set some parameters to specify the versions of
several data sets to use and whether you want to download the most recent 
version of the data from the web.

Note that some of the data cannot be downloaded automatically. 
The warning messages shown when runing `openness_1-csv.R` inform you about this
data and how to obtain it.
Note that the current version of the package contains the most recent version
that has been available when the current version of the package has been
released.

## Reference

If you use the package, please cite the following paper 
(you can also use `citation("OpennessDataR")`):

> Graebner, C., Heimberger, P., Kapeller, J. and F. Springholz (2020): Understanding
 economic openness: a review of existing measures, *Review of World Economics*, 
 forthcoming. 
 DOI: [10.1007/s10290-020-00391-1](https://doi.org/10.1007/s10290-020-00391-1)

It is also desirable to cite the original sources.
Your find more information about how to do this 
[here](https://graebnerc.github.io/OpennessDataR/).
