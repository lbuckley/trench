
#===========================
# CLIMATE DATASET OPTIONS

#Read DCP data
# http://gdo-dcp.ucllnl.org/downscaled_cmip_projections/dcpInterface.html
# Daily, 1970-1999 to 2040-2069

# Each BCCA climate projection has the following attributes:
#   
#   Variables:
#   precipitation, mm
# minimum surface air temperature, °C
# maximum surface air temperature, °C
# missing value flag: 1E+20
# Time:
#   CMIP3 coverage: 1961-2000, 2046-2065, 2081-2100
# CMIP5 coverage: 1950-2099
# resolution: daily
# Space:
#   coverage: North American Land-Data Assimilation System domain (i.e. contiguous U.S. plus portions of southern Canada and northern Mexico, spanning 25.125° N to 52.875° N and - 124.625° E to -67.000° E)
#   resolution: 1/8° latitude-longitude (~ 12km by 12 km)

#/thredds/dodsC/cmip5_bcca/future

#----------------------------
#' #USE WORLD CLIM PROJECTIONS
#' #5 Minutes
#' # BIO6 = Min Temperature of Coldest Month
#' # 2100 RCP6
#' 
#' #current data
#' clim.p= getData('worldclim', var='bio', res=5)
#' clim.pmax= clim.p$bio5/10
#' clim.pmin= clim.p$bio6/10
#' 
#' #future data
#' clim.f=getData('CMIP5', var='bio', res=5, rcp=60, model='BC', year=70)
#' clim.fmax= clim.f$bc60bi705/10
#' clim.fmin= clim.f$bc60bi706/10
#' #'model' should be one of "AC", "BC", "CC", "CE", "CN", "GF", "GD", "GS", "HD", "HG", "HE", "IN", "IP", "MI", "MR", "MC", "MP", "MG", or "NO".
#' #'rcp' should be one of 26, 45, 60, or 85.
#' #'year' should be 50 or 70
#' # models: http://worldclim.org/CMIP5_30s

#--------------------------
#MICROCLIM
#gridded hourly estimates of typical microclimatic conditions (air temperature, wind speed, relative humidity, solar radiation, sky radiation and substrate temperatures from the surface to 1 m depth) at high resolution (~15 km) for all terrestrial landmasses except Antarctica. The estimates are for the middle day of each month, based on long-term average macroclimates, and include six shade levels and three generic substrates (soil, rock and sand) per pixel.
#https://figshare.com/collections/microclim_Global_estimates_of_hourly_microclimate_based_on_long_term_monthly_climate_averages/878253

#===========================

library(raster)
library(proj4)
library(ncdf4)

#GridMet
#Adapted from NicheMapR, micro_USA 

#aggregated thread server
#/thredds/dodsC/agg_met_tmmx_1979_CurrentYear_CONUS.nc

#non aggregated
#/thredds/dodsC/MET/tmmx/tmmx_2018.nc

#-------------
#elevation data

baseurl <- "http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/"
nc <- nc_open(paste0(baseurl, "/elev/metdata_elevationdata.nc"))
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")
elev <- ncvar_get(nc, "elevation")

elev<- ncvar_get(nc, varid = "elevation")
nc_close(nc)

r <- raster(t(elev), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
plot(r)

#------------
#Tmax

baseurl <- "http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_"
nc <- nc_open(paste0(baseurl, "tmmx_1979_CurrentYear_CONUS.nc"))
day<- ncvar_get(nc, varid = "day")
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")

start <- c(1,1,1)
count <- c(length(lon), length(lat), 1)
tmmx= ncvar_get(nc, "daily_maximum_temperature", start=start, count=count)
nc_close(nc)

r <- raster(t(tmmx), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
r <- flip(r, direction='y')
plot(r)

#===========================
#NicheMapR

install.packages("~/Downloads/NicheMapR_1.1.4.tgz", repos = NULL, type = .Platform$pkgType)
install.packages("~/Downloads/NicheMapR_1.1.3.tgz", repos = NULL, type = .Platform$pkgType)

library(NicheMapR) # load the package

#get.global.climate(folder="type the folder you want to install to here")

vignette("microclimate-model-tutorial", package = "NicheMapR")
vignette("microclimate-model-theory-equations", package = "NicheMapR")
vignette("microclimate-model-inputs", package = "NicheMapR")
vignette("microclimate-model-IO", package = "NicheMapR")
vignette("ectotherm-model-tutorial", package = "NicheMapR")

#===========================