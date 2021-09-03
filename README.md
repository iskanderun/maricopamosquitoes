# maricopamosquitoes
A repository for functions, analyses, and graphing scripts related to Maricopa County, Arizona mosquito data.

To access code and data for "Precipitation's complicated role...", the "maricopamosquitoes" repository can be 
dowloaded by pressing the green "Code" button on the upper right of this page. This will download the entire
repository as a .zip file, which should then be and unzipped locally.

Warning: the kriged precipiation files (in rainfall_maricopa) are large and numerous! Because of data limitations, 
we have provided a .targz data file offsite, that needs to be downloaded and extracted in 
aedes_recip > model. The link to those data are temporarily in a Dropbox folder, here: 
XXXXX
and we will find a permanent home these layers soon. 

These layers will be over 9GB once extracted. We have also provided the outputs of 
the function as a file called "df.csv" that can be used instead of going through the steps of the analysis,
and these provide mosquito count information linked to precipiation in inches at that location on
previous days. The code in precip_function.R explains where this can be used.


These data should also available from figshare, with permanent citation and DOI link: 
https://doi.org/10.6084/m9.figshare.14068988.v1). Use most current version available if multiple versions.
HOWEVER -- We are currently troubleshooting the FigShare files to see if they contain hidden Dropbox links that
prevent them from being used properly. This README will be updated once that is resolved.

Citation: Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily precipitation rasters. figshare. 
Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 

To run the function used in "Precipitation's complicated role...", please unzip "rainfall_maricopa.zip" in place.
Similarly, a zipped .dbf file in file aedes_precip > model > R_data must be unzipped in place. Then go
to aedes_precip > R_scripts and run "precip_function.R".
