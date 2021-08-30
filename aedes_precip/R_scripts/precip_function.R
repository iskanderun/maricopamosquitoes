# newmane@berkeley.edu and fengxiao@email.arizona.edu
# match trap data with precipitation data
# R software script
# last updated: 2021.08.26

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


# Kriged layers of precipition data used in this study available for download at 
# figshare.com at 
## Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily 
# precipitation rasters. 
## figshare. Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 
# Note: these files are 12.5 MB as a .zip file, but will be larger than 9 GB 
# once unzipped 

# Where the code below indicates setting the directory to "~/.../", this indicates
# that the user should point the code to wherever the data are stored, either locally 
# or online. In some cases, both options are given and the user must choose which source to use. 
# The file structure should follow that of "aedes_precip" in this github folder.

# A file structure that can be used if all of the data files are stored locally (i.e. 
# on a user's computer,
# github account, Dropbox folder or other cloud-based folder, or other pathway that 
# can be accessed by the user directly)
# is the following:

# > aedes_precip
#    >> R_scripts
#    >> model
#         >>> rainfall_maricopa
#             >>>> raw
#               ## (files in this folder are named "5400_FOPR_17.xlsx", etc., 
#                 and follow structure of the github folder)
#             >>>> 3_station_raster
#               ## (files in this folder are named "X20150319_ped.tif", etc., 
#                   and follow structure of the github folder)
#         >>> R_data
#            ## mos_info_prj.shp 
#            ## df.csv

##########
# PART 2: Matching mosquito counts to local precipitation data
##########

#loading packages

# install.packages('raster')
# install.packages('ggplot2')
library(raster)
library(ggplot2)


# load mosquito data
#occ <- shapefile("/.../mos_info.shp")
occ <- shapefile("https://raw.githubusercontent.com/iskanderun/maricopamosquitoes/aedes_precip/data1/mos_info_prj.shp")

occ$trapDay <- as.Date(occ$labdate, "%m/%d/%Y")    #change date to better format

#occ$spp <- occ$A_gyp_M + occ$A_gyp_F      #in this example, 
    # male and female Aedes aegypti mosquito counts are grouped

occ$spp <- occ$A_gyp_F    # however, this line can be used instead 
    # to model only the female Ae. aegypti, as in the manuscript


# load PPT layers (these are available on FigShare)
setwd("~/.../aedes_precip/")
#setwd("~/Dropbox/aedes_precip/") #or set pathway to a user-created Dropbox folder, 
#for example

layers <- list.files("rainfall_maricopa/3_station_raster/",full.names = T,
                     pattern="_ped.tif$")

layers

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


# "df.csv" can be created above; or you can load "df.csv" directly by uncommenting 
# the code below and running it

setwd("aedes_precip")
df <- read.csv("model/R_data/df.csv")

head(df)
names(df)[1:2] <- c("spp","trapDay")
df <- reshape::melt(df,id=c("spp","trapDay"))
head(df)

# subset data by abundance if applicable
# test <- subset(df,spp<1500)

#graph results
ggplot(test,aes(value,spp)) +
  geom_point() +
  facet_grid (variable~.)

## save figure in png format
ggsave("model/ppt_makefemaleCount.png",device="png")

dev.off()
