# newmane@berkeley.edu and fengxiao.sci@gmail.com
# match mosquito trap data with precipitation data
# R software script
# last updated: 2021.09.02

# PART 1: Introduction
# PART 2: Matching mosquito counts to local precipitation data
# PART 3: graphing the data


##########
# PART 1: Introduction
##########

# This code is used in the project:
# Newman, E.A.=, X. Feng=, K.R. Walker, S. Young, K. Smith, J. Townsend, 
# D. Damian, J. Soto, K. Ernst. 
# Precipitation’s complicated role in driving the abundance of an 
# emerging disease vector in an urban, arid landscape

# The function provided in part 2 (and example data files) provide a method for linking organismal data
# with georeferenced information and dates to kriged precipitation data from the same area. The 
# date range of the kriged data to be associated with each individual observation of organismal data 
# can be specified by the user by modifying the code. Notes below.

# Examples of kriged layers of precipition data used in this study are available
# in folder "rainfall_maricopa". These are for visualization only, as the 
# code will only run if all trapping events can be associated with previous days' 
# precipitation at that exact location. The full set of rasters will be required
# to run analyses, and should go in the "aedes_precip > model" folder.
# Data are available for download at figshare.com at
## Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily 
# precipitation rasters. 
## figshare. Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 
# (permanent repository)
# Currently, these files *may* be unusable because of embedded Dropbox permissions.
# We are investigating this and will make changes to that repository soon.
#
# As a workaround, please use the .tar.gz file in Dropbox:
# https://www.dropbox.com/sh/9vnj7xx8znxpd8b/AAC0sWDQuas5Q34QD89i_i6ua?dl=0
# and download the tar.gz file manually. Extraction instructions are in the
# code below and in the README file for the folder aedes > model.

# Note: the tar.gz file is >9 GB and will be larger than that 
# once extracted.

# Users may need to manage working memory of their computers in order to run
# these analyses with these data; however, similar analyses with smaller 
# rasters should run comfortably on a 8GB memory computer.

# Data for trap location information ("blurred" to protect currently operating 
# machinery and personal addresses), and counts of male and female adults
# Aedes aegypti collected at those traps, with associated collection dates
# are available in the github repository as "Ae_aegypti_mosqcounts_blurred.csv"
# in the aedes_precip > model > R_data folder. Blurred data are provided as  
# location information rounded to 3 decimal places. 

# The file structure used for these analyses follow that of the "aedes_precip" 
# folder in this github repository.

# The code below should automatically choose to run the code and get data from the correct folders,
# however, the user may want to manually point the code to wherever the data are stored, either locally 
# or online. Navigating to RStudio menu: Session > Set Working Directory > Choose Directory, 
# and then selecting "Open" for the downloaded folder "maricopamosquitoes-master" will run
# a line of code that sets the correct local directory once the github directory is downloaded.
# Note that if the data from FigShare is used, it will have to be downloaded and unzipped into the 
# "aedes_precip > model" folder if used (see below), and the .dbf file in "R_data" 
# will need to be unzipped after the download of the github repository.

# A file structure that can be used if all of the data files are stored locally (i.e. 
# on a user's computer, github account, Dropbox folder or other cloud-based folder,
# or other pathway that can be accessed by the user directly)
# is the following:

# Project: Maricopa mosquitoes
# > aedes_precip
#    >> R_scripts
#      ## precip_function.R (this script)
#    >> model
#         >>> rainfall_maricopa_vis (for example and visualization purposes)
#             >>>> raw
#               ## (files in this folder are named "5400_FOPR_17.xlsx", etc., 
#                 and follow structure of the github folder)
#             >>>> 3_station_raster
#               ## (files in this folder are named "X20150319_ped.tif", etc., 
#                   and follow structure of the github folder)
#         ## rainfall_maricopa.zip (complete set of rasters that must be unzipped by user)
#         >>> R_data
#            ## occ_SPATIAL_proj.shp & associated files (large .dbf file must be unzipped by user)
#            ## Ae_aegypti_mosqcounts_blurred.csv for direct inquiry
#            ## df.csv used in Part 3 of this code (result of running code in Part 2)

##########
# PART 2: Matching mosquito counts to local precipitation data
##########

#loading packages; uncomment the installation code below if necessary

# install.packages('raster')
# install.packages('ggplot2')
# install.packages('rstudioapi')
library(raster)
library(ggplot2)
library(rstudioapi)

# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))
print( getwd() )
# set path to aedes_precip
setwd('../')
print( getwd() )

#############################
# load mosquito data
# make sure to unzip the .dbf file in this folder before running the next line

occ <- shapefile("model/R_data/occ_SPATIAL_proj.shp")

occ$trapDay <- as.Date(occ$labdate, "%m/%d/%Y")    #change date to readable format

#occ$spp <- occ$A_gyp_M + occ$A_gyp_F      #in this example, 
            # male and female Aedes aegypti mosquito counts are grouped

occ$spp <- occ$A_gyp_F    # however, this line can be used instead 
            # to model only the female Ae. aegypti, as in the manuscript

hist(log(occ$spp))


######################################
# Run the code below for visualization of inches precipitation in Maricopa County region

layers1 <- list.files("model/rainfall_maricopa_vis/3_station_raster/",full.names = T,
                     pattern="_ped.tif$")
layers1
one_ly <- raster(layers1[1]) # view first layer loaded in list, as example
plot(one_ly)
one_ly <- raster(layers1[2]) # view second layer loaded in list, as example
plot(one_ly)
one_ly <- raster(layers1[3]) # view third layer loaded in list, as example
plot(one_ly)
rm(layers1)

######################################
# Run the code below for use in function calPPT

# ***TEMPORARY INSTRUCTIONS****

# We intend to place the data in a permanent repository, however, because of data limitations and 
# "big data" issues, we believe the FigShare repository does not currently contain working raster files.

# As a temporary workaround, please go to Dropbox folder:
# https://www.dropbox.com/sh/9vnj7xx8znxpd8b/AAC0sWDQuas5Q34QD89i_i6ua?dl=0
# and manually download the file rainfall_maricopa.tar.gz
# This file is 7.7 GB and will be 9GB or larger once extracted.

# Extract the file in this folder (aedes_precip > model), either by clicking on it
# or by using the Terminal on Mac (or other Linux terminal). Change the working 
#directory to the folder "model" and execute the command:

# tar -xzf rainfall_maricopa.tar.gz
#
# ***END TEMPORARY INSTRUCTIONS****


layers <- list.files("model/rainfall_maricopa/3_station_raster/",full.names = T,
                     pattern="_ped.tif$")
head(layers)


#############################
# Define the function calPPT
# calPPT is a function to find PPT for a user-defined temporal window

calPPT <- function(daysAgo, dayRange,ooo){
  varName <- paste0("ppt_",daysAgo,"_",dayRange)
  #ooo[varName] <- 0
  varData <- rep(0,nrow(ooo))
  i=1
  trapDay_all <- unique(ooo$trapDay)
  
  for(i in 1:length(trapDay_all)){
    print(i)
    #i=nrow(trapDay_all)
    startDay <- trapDay_all[i] - daysAgo +1
    endDay <- startDay + dayRange -1
    #today <- trapDay_all[i]
    
    selDays <- seq.Date (from= startDay, to= endDay, by=1)
    
    selDays_string <- gsub("-","",selDays)
    selLayers <- layers[(grepl(paste(selDays_string,collapse = "|"),layers))]
    selLayers <- stack(selLayers)
    
    # change <0 ppt to 0
    for(j in 1: nlayers(selLayers) ){
      selLayers[[j]] [values(selLayers[[j]])<0] <- 0
    }
    
    if(dayRange==1){
      selLayers_sum <- selLayers
    } else {
      selLayers_sum <- calc(selLayers, sum)
    }
    
    ppt_one <- extract(selLayers_sum,subset(occ,trapDay==trapDay_all[i]) )
    
    varData[which(occ$trapDay == trapDay_all[i])] <- ppt_one
  }
  return(varData)
}

###############################################
# Note: the following code may take an hour or more to run
# *****If desired, skip to PART 3 and use the pre-made file "df.csv" for graphing*****

# The next line is a test to see if the code is working before committing to 
# a big data extraction
test_ppt_1_1 <- calPPT(daysAgo = 1,dayRange = 1,ooo=occ[1:4,])
# if test_ppt_1_1 contains values other than NA, then it is extracting correctly
rm(test_ppt_1_1)

# Find precipitation data associated with locations for (examples):
# 1 day, starting 1 day ago
ppt_1_1 <- calPPT(daysAgo = 1,dayRange = 1,ooo=occ) 
# 1 day, starting 2 days ago
ppt_2_1 <- calPPT(daysAgo = 2,dayRange = 1,ooo=occ) 
# 1 day, starting 15 days ago
ppt_15_1 <- calPPT(daysAgo = 15,dayRange = 1,ooo=occ) 

# bind precipitation data together, for days 1, 2, and 15.
# Example:
ppt_data_1day <- cbind(ppt_1_1,
                  ppt_2_1,
                  ppt_15_1)

# not run:
# write.csv(ppt_data,"model/ppt_data_1day.csv")

# bind mosquito abundance information to precipitation information
ppt_data_1day_full <- data.frame(cbind(occ$spp,
                       occ$trapDay,
                       ppt_data_1day))

write.csv(ppt_data_1day_full, "model/R_data/ppt_data_1day_full.csv")


# Or do this with cumulative precipitation
# for 5 days, starting 10 days ago
# not run (example):
# ppt_10_5 <- calPPT(daysAgo = 10,dayRange = 5,ooo=occ) 


##########
# PART 3: graphing the data
##########

# for the purposes of running this code, the code above can be regarded as a 
# customizeable function, however, we provide the dataframe that comes out of 
# the above analysis as an example that can be graphed 
# with the code below this line, or analysed with user-created code

#############################
# "df.csv" can be created above; or you can load "df.csv" directly by uncommenting 
# the code below and running it

#    df <- read.csv("model/R_data/df.csv")

# or use the .csv file created in PART 2

df <- read.csv("model/R_data/ppt_data_1day_full.csv")
rm(ppt_data_1day_full)
names(df)[1:2] <- c("num_fem","trapDay")
df$num_fem <- as.numeric(df$num_fem)

# "ppt_X_X" represents precipitation in inches for each trapping event

head(df)
df <- reshape::melt(df,id=c("spp","trapDay"))
head(df)
#############################

# subset data by abundance if applicable (not done in associated manuscript)
test <- subset(df,spp<1500)

#graph results
ggplot(test,aes(value,spp)) +
  geom_point() +
  facet_grid (variable~.) +
  xlab("Preceding days' precipitation in inches") +
  ylab("Female Ae. aegypti counts")
  

## save figure in png format
ggsave("model/ppt_makefemaleCount.png",device="png")

dev.off()
