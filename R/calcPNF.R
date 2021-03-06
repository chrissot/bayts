#' @title Calculating conditional non-forest probabilities
#' 
#' @description Calculating conditional non-forest probability (PNF). Probabilities are calculated based on pdfs for F and NF (derived from F and NF distributions). (Guassian and Weibull pdf types are supported) 

#' @author Johannes Reiche (Wageningen University)

#' @references \href{http://www.mdpi.com/2072-4292/7/5/4973}{Reiche et al. (2015): A Bayesian Approach to Combine Landsat and ALOS PALSAR Time Series for Near Real-Time Deforestation Detection. Remote Sensing. 7(5), 4973-4996; doi:10.3390/rs70504973}

#' @param ts single value, vector or time series object of class "ts"
#' @param pdf "pdf" object describing F and NF distributions. 
#' "pdf" object: pdf[1] = pdf type F, pdf[2] = pdf type NF, pdf[3] and pdf[4] = pdf parameter describing F, pdf[5] and pdf[6] = pdf parameter describing NF. pdf types supported: Gaussian or Weibull. 
#' See Example for details on how to create a "pdf" object.

#' @param bwf block weighting function to truncate the NF probability (default = c(0,1) = no truncation) 

#' @return single value, vector or time series object of class "ts"

#' @examples 
#' # NDVI time series
#' ndvi <- c(0.5,0.7)
#' 
#' # create pdf (Probability density functions) object for forest and non-forest 
#' pdfType <- c("gaussian","gaussian")
#' pdfF <-  c(0.85, 0.1) #mean and sd
#' pdfNF <- c(0.3, 0.2)  #mean and sd
#' pdf <- c(pdfType,pdfF,pdfNF)
#' 
#' # calculate conditional non-forest probabilities
#' calcPNF(ndvi,pdf)

#' @export 


calcPNF <- function (ts, pdf, bwf = c(0, 1)) 
{
  if (length(ts) > 0) {
    #Gaussian pdfribusion (mean and sd)
    if (pdf[1] == "gaussian") {PF <- dnorm(ts, as.double(pdf[3]), as.double(pdf[4]))}
    if (pdf[2] == "gaussian") {PNF <- dnorm(ts, as.double(pdf[5]), as.double(pdf[6]))}
    #Weibull pdfribusion (shape and scale) 
    if (pdf[1] == "weibull") {PF <- dweibull(ts, as.double(pdf[3]), as.double(pdf[4]))}
    if (pdf[2] == "weibull") {PNF <- dweibull(ts, as.double(pdf[5]), as.double(pdf[6]))}
    
    #calculate conditinal NF
    PNF[PNF<1e-10000] <- 0
    PNF[PNF>0] <- (PNF[PNF>0]/(PF[PNF>0] + PNF[PNF>0]))
    ## apply block weighting function 
    PNF[PNF<bwf[1]]<-bwf[1]
    PNF[PNF>bwf[2]]<-bwf[2]
  }
  return(PNF)
}