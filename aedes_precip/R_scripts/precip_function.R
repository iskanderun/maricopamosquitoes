# newmane@berkeley.edu and fengxiao@email.arizona.edu
# match trap data with precipitation data
# R software script
# last updated: 2021.08.31

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

# Kriged layers of precipition data used in this study available for download at 
# figshare.com at 
## Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily 
# precipitation rasters. 
## figshare. Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 
# Note: these files are 12.5 MB as a .zip file, but will be larger than 9 GB 
# once unzipped 

# data for trap location information ("blurred" to protect currently operating 
# machinery and personal addresses), and counts of male and female
# Aedes aegypti collected at those traps, with collection dates
# are available in the github repository.

# The file structure used for these analyses follow that of the "aedes_precip" 
# folder in this github repository.

# The code below should automatically choose to run the code and get data from the correct folders,
# however, the user may want to manually point the code to wherever the data are stored, either locally 
# or online. Navigating to RStudio menu: Session > Set Working Directory > Choose Directory, 
# and then selecting "Open" for the downloaded folder "maricopamosquitoes-master" will run
# a line of code that sets the correct local directory once the github directory is downloaded.
# Note that the data from Figshare will have to be downloaded and unzipped into the "rainfall_maricopa"
# folder (see below), and the .dbf file in "R_data" will need to be unzipped after download.

# A file structure that can be used if all of the data files are stored locally (i.e. 
# on a user's computer, github account, Dropbox folder or other cloud-based folder,
# or other pathway that can be accessed by the user directly)
# is the following:

# Project: Maricopa mosquitoes
# > aedes_precip
#    >> R_scripts
#      ## precip_function.R (this script)
#    >> model
#         >>> rainfall_maricopa (complete files available on github)
#             >>>> raw
#               ## (files in this folder are named "5400_FOPR_17.xlsx", etc., 
#                 and follow structure of the github folder)
#             >>>> 3_station_raster
#               ## (files in this folder are named "X20150319_ped.tif", etc., 
#                   and follow structure of the github folder)
#         >>> R_data
#            ## occ_SPATIAL_proj.shp & associated files (see readme about unzipping large .dbf file)
#            ## Ae_aegypti_mosqcounts_blurred.csv for direct inquiry
#            ## df.csv used in Part 3 of this code as an output of Part 2

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

occ <- shapefile("/R_data/occ_SPATIAL_proj.shp")

occ$trapDay <- as.Date(occ$labdate, "%m/%d/%Y")    #change date to better format

#occ$spp <- occ$A_gyp_M + occ$A_gyp_F      #in this example, 
    # male and female Aedes aegypti mosquito counts are grouped

occ$spp <- occ$A_gyp_F    # however, this line can be used instead 
    # to model only the female Ae. aegypti, as in the manuscript

#############################
# load PPT layers (these are available on FigShare)
setwd("~/.../aedes_precip/")
#setwd("~/Dropbox/aedes_precip/") #or set pathway to a user-created Dropbox folder, for example

layers <- list.files("rainfall_maricopa/3_station_raster/",full.names = T,
                     pattern="_ped.tif$")
layers
one_ly <- raster(layers[2]) # view second layer loaded in list, as example
plot(one_ly)

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

# Note: these may take an hour or more to run
# find precipitation data associated with locations for (examples):
# 1 day, starting 1 day ago
ppt_1_1 <- calPPT(daysAgo = 1,dayRange = 1,ooo=occ) 
# 1 day, starting 2 days ago
ppt_2_1 <- calPPT(daysAgo = 2,dayRange = 1,ooo=occ) 
# 1 day, starting 15 days ago
ppt_15_1 <- calPPT(daysAgo = 15,dayRange = 1,ooo=occ) 

# or cumulative precipitation (example):
# for 5 days, starting 10 days ago
ppt_10_5 <- calPPT(daysAgo = 10,dayRange = 5,ooo=occ) 

# example
ppt_data <- cbind(ppt_1_1,
                  ppt_2_1,
                  ppt_15_1)

setwd()
# write.csv(ppt_data,"model/ppt_data.csv")

# bind mosquito abundance information to precipiation information
df <- data.frame(cbind(occ$spp,occ$trapDay,
                       ppt_data))


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

setwd("aedes_precip")
df <- read.csv("model/R_data/df.csv")
head(df)
df <- reshape::melt(df,id=c("spp","trapDay"))
head(df)
#############################

# subset data by abundance if applicable
test <- subset(df,spp<1500)

#graph results
ggplot(test,aes(value,spp)) +
  geom_point() +
  facet_grid (variable~.)

## save figure in png format
ggsave("model/ppt_makefemaleCount.png",device="png")

dev.off()
