#newmane@berkeley.edu and fengxiao@email.arizona.edu
#match trap data with precipitation data
# R software script
#2021.08.26

# This code is used in the project:
# Newman, E.A.=, X. Feng=, K.R. Walker, S. Young, K. Smith, J. Townsend, D. Damien, J. Soto, K. Ernst. 
# Precipitation’s complicated role in driving the abundance of an emerging disease vector in an urban, 
# arid landscape 
# (current status: submitted to Ecology Letters)

# Kriged layers of precipition data used in this study available for download at figshare.com at 
# https://doi.org/10.6084/m9.figshare.14068988.v1
# Note: these files are 12.5 MB as a .zip file, but will be larger than 9 GB once unzipped 
# Citation information:
## Newman, Erica; Feng, Xiao (2021): Maricopa County, AZ interpolated daily precipitation rasters. 
## figshare. Dataset. https://doi.org/10.6084/m9.figshare.14068988.v1 


#loading packages
library(raster)
library(ggplot2)

# load mosquito data
occ <- shapefile("/.../new_mosqcounts14to16_prj.shp")

occ$trapDay <- as.Date(occ$labdate, "%m/%d/%Y")    #change date to better format
occ$spp <- occ$A_gyp_M + occ$A_gyp_F      #in this example, male and female Aedes aegypti mosquito counts are grouped
# occ$spp <- occ$A_gyp_F    # however, this line can be used instead to model only the female Ae. aegypti, as in the manuscript


# load PPT layers (these are available on FigShare)
setwd("~/.../aedes_precip/")
layers <- list.files("rainfall_maricopa/3_station_raster/",full.names = T,pattern="_ped.tif$")


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

# or cumulative precipitation:
# for 5 days, starting 10 days ago
ppt_10_5 <- calPPT(daysAgo = 10,dayRange = 5,ooo=occ) 


ppt_data <- cbind(ppt_1_1,
         ppt_2_1,
         ppt_15_1)
#write.csv(ppt_data,"model/ppt_data1.csv")

#bind mosquito abundance information to precipiation information
df <- data.frame(cbind(occ$spp,occ$trapDay,
                       ppt_data) )

# for the purposes of running this code, the code above can be regarded as a customizeable function
# however, we provide the dataframe that comes out of the above analysis as an example that can be 
# graphed with the code below this line, or analysed with user-created code


head(df)
names(df)[1:2] <- c("spp","trapDay")
#write.csv(df,"df.csv")
#df <- read.csv("df.csv")

df <- reshape::melt(df,id=c("spp","trapDay"))
head(df)

#subset data by abundance if applicable
# test <- subset(df,spp<1500)

#graph results
ggplot(test,aes(value,spp)  ) +
  geom_point() +
  facet_grid (variable~.)

## save figure in png format
ggsave("model/ppt_makefemaleCount.png",device="png")

dev.off()


