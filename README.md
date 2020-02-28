# OpennessDataR

This packages complements Gräbner *et al.* (2018) by providing the full openness 
data set and the means to update it automatically.

More information about the data summarized in the package and links to the 
original sources can be found in the `data-description` vignette.

## Using the data

The package gets regularly updated to make sure that the current data set
is the most recent one. 
If you feel that an update is necessary - or you have any other query -
please use the issue tracker of the 
[Github page](https://github.com/graebnerc/OpennessDataR) of the package.

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

> Graebner, C., Heimberger, P., Kapeller, J. and F. Springholz (2018): Measuring
  Economic Openness: A review of existing measures and empirical practices, ICAE
  Working Paper 84. Available online:
  [https://www.jku.at/fileadmin/gruppen/108/ICAE_Working_Papers/wp84.pdf](https://www.jku.at/fileadmin/gruppen/108/ICAE_Working_Papers/wp84.pdf)

It is also nice to cite the original sources for the following data:

* TBA
