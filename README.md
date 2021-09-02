# maricopamosquitoes
A repository for functions, analyses, and graphing scripts related to Maricopa County, Arizona mosquito data.

To access code and data for "Precipitation's complicated role...", the "maricopamosquitoes" repository can be 
dowloaded by pressing the green "Code" button on the upper right of this page. This will download the entire
repository as a .zip file, which should then be and unzipped locally.

Warning: the kriged precipiation files (in rainfall_maricopa) are large and numerous! Because of data limitations, 
we have provided a zipped data file in aedes_recip > model called "rainfall_maricopa.zip". 
These layers will be over 9GB once unzipped.

These data are also available from figshare, with permanent citation and DOI link:
(https://figshare.com/articles/dataset/Maricopa_County_AZ_interpolated_daily_precipitation_rasters/14068988; 
or permanent DOI: https://doi.org/10.6084/m9.figshare.14068988.v1). 
Use most current version available if multiple versions.

Citation: Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily precipitation rasters. figshare. 
Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 

To run the function used in "Precipitation's complicated role...", please unzip "rainfall_maricopa.zip" in place.
Similarly, a zipped .dbf file in file aedes_precip > model > R_data must be unzipped in place. Then go
to aedes_precip > R_scripts and run "precip_function.R".
