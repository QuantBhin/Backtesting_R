library(zoo) 
library(PerformanceAnalytics)
library(quantmod)

price_m = read.csv("price_m.csv", row.names=1, header=TRUE)
price_m[is.na(price_m)] = 0
price_kospi = read.csv("kospi.csv", row.names = 1, header = TRUE)

ro = dim(price_m)[1]
co = dim(price_m)[2] 

ret_kospi = matrix(0, dim(price_kospi)[1], dim(price_kospi)[2])
for (i in 1: dim(ret_kospi)[2]){
  ret_kospi[,i] = Delt((price_kospi)[,i])
}

ret_1m = matrix(0,ro,co)
for (i in 1:dim(ret_1m)[2]) {
  ret_1m[, i] = Delt((price_m)[, i])
}

std = rbind( matrix(0,59,dim(ret_1m)[2]),rollapply(ret_1m,60,sd) ) 
std[std == 0] = NA

ret_lowvol_quan = matrix(0,ro,5)
ret_lowvol = matrix(0,ro,1)

rownames(ret_lowvol_quan) = rownames(price_m)
rownames(ret_lowvol) = rownames(price_m)

for (i in (which(rownames(price_m) == "1999-12-31")) : (ro-1)) {
  
  con = matrix(0,2,co)
  con[1,] = std[i, ]
  
  con[, which(price_m[i,] == 0)] = NA
  
  qt = matrix(0,1,5)
  for (q in 1 : 5) {
    qt[, q] = quantile(con[1,], (q-1)*2/10, na.rm=TRUE) 
    
    for (w in 1 : co) {
      if ( ( con[1, w] > qt[, q] ) & (!is.na(con[1,w])) ) { 
        con[2, w] = q }
    }
  }
  
  for (q in 1 : 5) { 
    ret_lowvol_quan[i+1,q] = mean(ret_1m[i+1, which ((con[2, ] == q) ) ])
  }
  
  ret_lowvol[i+1] = mean(ret_1m[i+1, which(rank(con[1, ]) <= 20 ) ])
}

ret_lowvol_quan = ret_lowvol_quan[ which(rownames(ret_lowvol_quan) == "2000-01-31") : ro, ]
ret_lowvol = as.matrix(ret_lowvol[ which(rownames(ret_lowvol) == "2000-01-31") : ro, ])
ret_kospi = as.matrix(ret_kospi[ which(rownames(ret_kospi) == "2000-01-31") : ro, ])

chart.CumReturns(ret_lowvol_quan)   
legend('topleft', c("1st","2nd","3rd","4th","5th"),col=1:5, lty=1, horiz = TRUE, cex = 0.5, bty="n")

chart.CumReturns(ret_lowvol)   
legend('topleft',c("Lowvol Index"),col=1:2, lty=1, horiz = TRUE, bty="n")

chart.Drawdown(ret_lowvol_quan)
legend('bottom', c("1st","2nd","3rd","4th","5th"),col=1:5, lty=1, horiz = TRUE, cex = 0.5, bty="n")


table.AnnualizedReturns(ret_lowvol_quan)