# bayts 

Set of tools to apply the probabilistic approach of Reiche et al. (2015, under review) to combine multiple optical and/or Radar satellite time series and to detect deforestation in near real-time. The package includes functions to apply the approach to both, single pixel time series and raster time series. Examples and test data are provided below.

### Research version
The package includes the research version of the tools, which have a limited perforamce when applied to raster time series. The reserach version allows (i) to visualise and analyse the entire time series history and (ii) it stepwise applies the probablistic approach consecutively on each observation in the time series to emulate a near real-time scenario. 

## Probablistic approach 
The basic version of the probabilistic approach has been published in Reiche et al., (2015). An improved version was published in Reiche et al. (under review). In Reiche et al., (under review), the probabilistic approach was used for the multi-sensor combination of Radar and optical data from Sentinel-1 and PALSAR-2 HV, together with Landsat for near-real time forest change detection in tropical dry forests in Bolivia. A brief description of the approach is provided below:

Figure 1 gives an schematic overview the probabilistic approach. We considered a near real-time scenario with past (t-1), current (t) and future observations (t+1), with multiple observations possible at the same observation date. First, once a new observation of either of the input time series was available (t = current) it was converted to the conditional NF probability (s<sup>NF</sup>) using the sensor specific forest (F) and non-forest (NF) probability density functions (pdf) (The sensor specific F and NF pdfs were derived using training data).
The derived conditional NF probability was added to the combined time series of conditional NF probabilities derived from the previous LNDVIn, S1VVn and P2HVn time series observations (t–i). Second, we flagged a potential deforestation event in the case that the conditional NF probability was larger than 0.5. We calculated the probability of deforestation using iterative Bayesian updating. Future observation (t+i) were used to update the probability of deforestation in order to confirm or reject the flagged deforestation event.

![fig](/examples/method_overview.jpg)
<sub>Figure 1. Probabilistic approach used to combine time series of Landsat NDVI (LNDVIn), Sentinel-1 VV (S1VVn) and ALOS-2 PALSAR-2 HV (P2HVn) observations and to detect deforestation in near real-time. (Reiche et al., under review) </sub>


## Install

The package can be installed directly from github using devtools
```r
library(devtools)
install_github('jreiche/bayts')
```

## References
Reiche, J., de Bruin, S., Hoekman, D. H., Verbesselt, J. & Herold, M. (2015): A Bayesian Approach to Combine Landsat and ALOS PALSAR Time Series for Near Real-Time Deforestation Detection. Remote Sensing, 7, 4973-4996. DOI:10.3390/rs70504973. (http://www.mdpi.com/2072-4292/7/5/4973)

Reiche, J., Hamunyela, E., Verbesselt, J., Hoekman, D. & Herold, M. (under review): Improving near-real time deforestation monitoring in tropical dry forests by combining dense Sentinel-1 time series with Landsat and ALOS-2 PALSAR-2. Remote Sensing of Environment. 

Hamunyela, E., Verbesselt, J., & Herold, M. (2016). Using spatial context to improve early detection of deforestation from Landsat time series. Remote Sensing of Environment, 172, 126–138. http://doi.org/10.1016/j.rse.2015.11.006

## Citation

```r
@software{bayts,
  author = {Reiche, Johannes},
  title = {{bayts}},
  url = {https://github.com/jreiche/bayts},
  version = {1.0},
  date = {2017-04-12},
  doi = {10.5281/zenodo.545792}
}
```

## For external contributors

External contributions are welcome. If you would like to contribute additional features and improvements to the package; fork the repository on gitHub, commit your changes and make a pull request. Always use the develop branch as a starting point for your work. Your contribution will be reviewed for quality, relevance and consistency with the rest of the package before being merged.


# Examples 

Two examples are provided. Example 1 shows how to apply the functions on singel-pixel time series (Sentinel-1 VV and Landsat NDVI). Example 2 shows how to apply the functions to raster time series.

## Example 1: Single-pixel example (Deforestation)

Single-pixel example using a Sentinel-1 VV and Landsat NDVI time series, covering a deforestation event in 2016. (Source code: examples/bayts_pixel_example_v01.R)

```r
require(bayts)

##############################################
######### load data, create & plot time series

# load example data
# single pixel Sentinel-1 VV and Landsat NDVI time series (09/2014 - 05/2016); deforestation event in early 2016
data(s1vv_lndvi_pixel)

# create time series using bfastts (bfast package)
ts1vv <- bfastts(s1vv_obs,as.Date(s1vv_date),type=c("irregular"))
tlndvi <- bfastts(lndvi_obs,as.Date(lndvi_date),type=c("irregular"))

# plot time series
plotts(tsL=list(tlndvi,ts1vv),labL=list("Sentinel-1 VV [dB]","Landsat NDVI"))
plotts(tsL=list(tlndvi,ts1vv),labL=list("Sentinel-1 VV [dB]","Landsat NDVI"),ylimL=list(c(0,1),c(-13,-6)))
```
![fig](/examples/example1_fig1.JPG)<br />
<sub>Figure 2. Landsat NDVI and Sentinel-1 VV time series covering a deforestation event in early 2016.</sub> 

```r
######################################
######### apply bayts and plot results

# (1) Define parameters 
# (1a) Sensor specific pdfs of forest (F) and non-foerst (NF). Used to calculate the conditional NF probability of each observation. Gaussian distribution of F and NF distribution. Distributions are described using mean and sd.
s1vv_pdf <- c(c("gaussian","gaussian"),c(-7,0.75),c(-11.5,1))    
lndvi_pdf <- c(c("gaussian","gaussian"),c(0.85,0.075),c(0.4,0.125))

# (1b) Theshold of deforestation probability at which flagged change is confirmed (chi)
chi = 0.9
# (1c) Start date of monitoring
start = 2015

# (2) apply bayts (combine original time series into a time series of NF probabilities and detect deforestation)
# (2a) apply bayts
bts <- bayts(tsL=list(tlndvi,ts1vv),pdfL=list(lndvi_pdf,s1vv_pdf),chi=chi,start=start)

# (2b) plot original time series; including flagged and detected changes
plotBayts(bts$bayts,labL=list("Landsat NDVI","Sentinel-1 VV [dB]"),ylimL=list(c(0,1),c(-13,-6)),start=start)
```

![fig](/examples/example1_fig2.JPG)<br />
<sub> Figure 3. Landsat NDVI and Sentinel-1 VV time series and detected deforestation events. black line = start of monitoring; dotted black line = flagged deforestation event that was not confirmed; red dotted line = flagged deforestation event; red line = confirmed deforestation event.</sub> 

```r
# (2c) plot time series of NF probabilities, including flagged and detected changes
plotBaytsPNF(bts$bayts,start=start)
```

![fig](/examples/example1_fig3.JPG)<br />
<sub>Figure 4. Time series of NF probabilities derived from the two original time series. black line = start of monitoring; dotted black line = flagged deforestation event that was not confirmed; red dotted line = flagged deforestation event; red line = confirmed deforestation event. </sub> 

```r
# (2d) get time of change
bts$change.flagged    # time at which change is flagged
bts$change.confirmed  # time at which change is confirmed
```


## Example 2: Area example (Deforestation over dry forest)

Raster example using Sentinel-1 VV and Landsat NDVI time series data for a dry forest site in Bolivia. The data is taken from Reiche et al. (under review) (Source code: examples/bayts_raster_example_v01.R)

```r
require(bayts)

##############################################
######### load data, create & plot time series

# load raster bricks; Sentinel-1 VV (s1vv, 2014-10-07 - 2016-05-17) and Landsat NDVI (lndvi, 2005-01-03 - 2016-05-25) 
data(s1vv_lndvi_raster)

# get observation dates from raster brick
lndvi_date <- as.Date(substr(names(lndvi),10,16), format="%Y%j")
lndvi_date
s1vv_date <- as.Date(substr(names(s1vv),2,11), format="%Y.%m.%d")
s1vv_date

# plot raster
plot(s1vv,3)    # all areas are covered with forest
plot(s1vv,85)   # deforestation in the top right part is visible
plot(lndvi,290) # deforestation in the top right part is visible
```

Next, the original raster time series are spatially normalised to reduce dry froest seasonality. The spatial normalisation is done image wise. The method is described in Reiche et al., (under review) and is based on the spatial normalisation method published in Hamunyela et al. (2016).

```r
###################################################################################
######### Spatial normalisation to reduce dry forest seasonality in the time series

# "Deseasonalised pixel value" = "original pixel value" - "95% Percentile of the distribution of the raster"
s1vvD <- deseasonalizeRaster(s1vv,p=0.95)
lndviD <- deseasonalizeRaster(lndvi,p=0.95)

######################################################
######### plot original and deseasonalised time series

plot(s1vv,85)

```
![fig](/examples/example2_fig3.JPG)<br />
<sub>Figure 5. Sentinel-1 VV image aquired at 17-05-2016. The top right part of the images shows the deforested areas. </sub> 

```r
cell <- click(s1vv, n=1, cell=TRUE)[,1]
#cell <- 3974

# create time series using bfastts (bfast package)
tlndvi <- bfastts(as.vector(lndvi[cell]),lndvi_date,type=c("irregular"))   # original Landsat NDVI
tlndviD <- bfastts(as.vector(lndviD[cell]),lndvi_date,type=c("irregular")) # deseasonalised Landsat NDVI
ts1vv <- bfastts(as.vector(s1vv[cell]),s1vv_date,type=c("irregular"))      # original Sentinel-1 VV
ts1vvD <- bfastts(as.vector(s1vvD[cell]),s1vv_date,type=c("irregular"))    # deseasonalised Sentinel-1 VV

# plot time series
# strong dry forest seasonality visible in the Landsat NDVI time series
plotts(tsL=list(tlndvi,tlndviD),labL=list("LNDVI","LNDVI_deseasonalised"))
# weaker dry forest seasonality in the Sentinel-1 VV time series
plotts(list(ts1vv,ts1vvD),labL = list("S1VV [dB]","S1VV_deseasonalised [dB]"))
```
![fig](/examples/example2_fig1.JPG)<br />
<sub>Figure 6. Original (black) and spatialy normalised (blue) Landsat NDVI time series. </sub> 

```r

#############################################
######### apply baytsSpatial and plot results

# (0) subset Landsat NDVI time series to length of Sentinel-1 VV time series (start in 2014)
lndviD <- subset(lndviD, 241:291, drop=FALSE)
lndvi_date <- lndvi_date[241:291]

# (1) Define parameters 
# (1a) Sensor specific pdfs of forest (F) and non-foerst (NF). Used to calculate the conditional NF probability of each observation. Gaussian distribution of F and NF distribution. Distributions are described using mean and sd.
s1vvD_pdf <- c(c("gaussian","gaussian"),c(-1,0.75),c(-4,1))  
lndviD_pdf <- c(c("gaussian","gaussian"),c(0,0.075),c(-0.5,0.125))

# (1b) Theshold of deforestation probability at which flagged change is confirmed (chi)
chi = 0.9
# (1c) Start date of monitoring
start = 2016

# (2) Apply baytsSpatial (it takes a long time; try parallel computing at next step)
out <- baytsSpatial(list(s1vvD,lndviD),list(s1vv_date,lndvi_date),list(s1vvD_pdf,lndviD_pdf),chi=chi,start=start)
# plot confirmed changes
plot(out,3)

# (3) Apply baytsSpatial using parallel computing; using mc.calc function from bfastSpatial package 
require(bfastSpatial)
out2 <- baytsSpatial(list(s1vvD,lndviD),list(s1vv_date,lndvi_date),list(s1vvD_pdf,lndviD_pdf),chi=chi,start=start,mc.cores = 10)
# plot confirmed changes
plot(out2,3)
```
![fig](/examples/example2_fig2.JPG)<br />
<sub>Figure 7. Detected deforestation. </sub> 
