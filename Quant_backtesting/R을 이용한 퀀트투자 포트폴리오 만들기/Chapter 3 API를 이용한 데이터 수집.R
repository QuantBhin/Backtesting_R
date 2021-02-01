## 3.1 API를 이용한 Quandl 데이터 다운로드

url.aapl = "https://www.quandl.com/api/v3/datasets/WIKI/AAPL/data.csv?api_key=xw3NU3xLUZ7vZgrz5QnG"
data.aapl = read.csv(url.aapl)
head(data.aapl)


## 3.2 getSymbols() 함수를 이용한 API 다운로드
### 3.2.1 주가 다운로드
library(quantmod)
getSymbols('AAPL')
head(AAPL)
chart_Series(Ad(AAPL))

data = getSymbols('AAPL', 
                  from = "2000-01-01", to = "2018-12-31",
                  auto.assign = FALSE)
head(data)

ticker = c('FB', 'NVDA')
getSymbols(ticker)

### 3.2.2 국내 종목 주가 다운로드
getSymbols("005930.KS",
           from = "2000-01-01", to = "2018-12-31")
tail(Ad(`005930.KS`))
tail(Cl(`005930.KS`))
getSymbols("068760.KQ",
           from = '2000-01-01', to = '2018-12-31')
tail(Cl(`068760.KQ`))


### 3.2.3 FRED 데이터 다운로드
getSymbols("DGS10", src = "FRED")
chart_Series(DGS10)

getSymbols("DEXKOUS", src = "FRED")
DEXKOUS["2016::"]

library(quantmod)
getSymbols("192090.KS")
tail(Ad(`192090.KS`))