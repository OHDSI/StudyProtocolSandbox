#' Decile classification
#' @description uses exponential decay function with standard deviation of classification score
#' to evalute consistency. If consistency is < 36, then there are at least a few deciles that have a trend
#' strongly counter to the general trend of the medical event.
#'
#' @export

decile_classification2 <- function(x)
{
  #Put consistency score on a -100ish to 100 scale
  #end = (sign(min(x)) == 0 | sign(max(x)) == 0)
  std <- sd(x)
  if(is.na(std)|is.nan(std)) return(0)
  else if(std <= 1)
  {
    if(sign(mean(x)) != -sign(Mode(x))) return(trunc(exp(-sd(x)) * 100))
    else return(trunc(exp(-sd(x)) * -100))
  }
  else if(T)
  {
    if(sign(mean(x)) != -sign(Mode(x))) return(trunc(exp(1-sd(x)) * 36))
    else  return(trunc(exp(1-sd(x)) * -36))
  }
}

#'  @description Qualitative consistency. This calculates the percent difference between
#' the number of deciles that are rising and sinking. 100 means all deciles are rising or sinking.
#' 0 means there as equal numbers of rising and sinking deciles.
#' @param x score
#' @param n number of deciles
#' @export

qualitative_consistency <- function(x, n)
{
  ris <- sum(x > 0)
  sin <- sum(x < 0)
  return(trunc(abs(ris-sin)/n * 100))
}

#'
#' @description Determines consistency based on whether n deciles are rising or sinking. Returns 1
#' if n deciles are rising/sinking; 0 otherwise
#' @param x  score
#' @param n user-specified minimum number of deciles that are rising or sinking
#' @export

user_consistency <- function(x, n)
{
  ris <- sum(x > 0)
  sin <- sum(x < 0)
  return(ifelse( ris >= n |sin >= n, 1, 0))
}

#' @description  Mode function
#' @export

Mode <- function(x, na.rm = T) {
  if(na.rm){
    x = x[!is.na(x)]
  }

  ux <- unique(x)
  return(ux[which.max(tabulate(match(x, ux)))])
}
