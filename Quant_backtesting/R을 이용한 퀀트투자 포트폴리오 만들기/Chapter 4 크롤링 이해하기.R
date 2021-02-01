# Chapter 4 크롤링 이해하기
## 4.1 GET과 POST 방식 이해하기
### 4.1.1 GET 방식

## 4.2 크롤링 예제
### 4.2.1 금융 속보 크롤링
library(rvest)
library(httr)

url = "https://finance.naver.com/news/news_list.nhn?mode=LSS2D&section_id=101&section_id2=258"
data = GET(url)

print(data)

data_title = data %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes('dl') %>%
  html_nodes('.articleSubject') %>% ## 클래스 속성인 경우 앞에 마침표(.)
  html_nodes('a') %>%
  html_attr("title")

print(data_title)


### 4.2.2 기업공시채널에서 오늘의 공시 불러오기
Sys.setlocale("LC_ALL", "English")
url = "https://kind.krx.co.kr/disclosure/todaydisclosure.do"
data = POST(url, body = 
              list(
                method = 'searchTodayDisclosureSub',
                currentPageSize = '15',
                pageIndex = '1',
                orderMode = '0',
                orderStat = 'D',
                forward = 'todaydisclosure_sub',
                chose = 'S',
                todayFlag = 'N',
                selDate = '2021-01-28'
              ))

data = read_html(data) %>%
  html_table(fill = TRUE) %>%
  .[[1]]

Sys.setlocale("LC_ALL", "Korean")

print(head(data))


### 4.2.3 네이버 금융에서 주식티커 크롤링
i = 0
ticker = list()
url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=", i, "&page=1")
down_table = GET(url)

navi.final = read_html(down_table, encoding = 'EUC-KR') %>%
  html_nodes(., '.pgRR') %>%
  html_nodes(., 'a') %>%
  html_attr(., 'href')
print(navi.final)

navi.final = navi.final %>%
  strsplit(., '=') %>%
  unlist() %>%
  tail(., 1) %>%
  as.numeric()

print(navi.final)

i = 0 # 코스피
j = 1 # 첫 페이지
url = paste0("https://finance.naver.com/sise/sise_market_sum.nhn?sosok=", i, "&page=", j)
down_table = GET(url)

Sys.setlocale("LC_ALL", "English")

table = read_html(down_table, encoding = "EUC-KR") %>%
  html_table(fill = TRUE)
table = table[[2]]

Sys.setlocale("LC_ALL", "Korean")

print(head(table))

table[, ncol(table)] = NULL
table = na.omit(table)
print(head(table))

symbol = read_html(down_table, encoding = "EUC-KR") %>%
  html_nodes(., 'tbody') %>%
  html_nodes(., 'td') %>%
  html_nodes(., 'a') %>%
  html_attr(., 'href')

print(head(symbol, 10))

library(stringr)

symbol = sapply(symbol, function(x) {
  str_sub(x, -6, -1)
  })

print(head(symbol, 10))

symbol = unique(symbol)
print(head(symbol, 10))

table$N = symbol
colnames(table)[1] = '종목코드'

rownames(table) = NULL
ticker[[j]] = table


data = list()

# i = 0 은 코스피, i = 1은 코스닥 종목
for (i in 0 : 1) { 
  ticker = list()
  url = 
    paste0('https://finance.naver.com/sise/', 'sise_market_sum.nhn?sosok=', i, '&page=1')
  
  down_table = GET(url)
  
  # 최종 페이지 번호 찾아주기
  navi.final = read_html(down_table, encoding = "EUC-KR") %>%
    html_nodes(., ".pgRR") %>%
    html_nodes(., "a") %>%
    html_attr(., "href") %>%
    strsplit(., "=") %>%
    unlist() %>%
    tail(., 1) %>%
    as.numeric()
  
  # 첫번째 부터 마지막 페이지까지 for loop를 이용하여 테이블 추출하기
  for (j in 1: navi.final) {
    
    # 각 페이지에 해당하는 url 생성
    url = paste0(
      'https://finance.naver.com/sise/',
      'sise_market_sum.nhn?sosok=',i,"&page=",j)
    down_table = GET(url)
    
    Sys.setlocale("LC_ALL", "English")
    # 한글 오류 방지를 위해 영어로 로케일 변경
    
    table = read_html(down_table, encoding = "EUC-KR") %>%
      html_table(fill = TRUE)
    table = table[[2]]
    
    Sys.setlocale("LC_ALL", "Korean")
    # 한글을 읽기 위해 로케일 언어 재변경
    
    table[, ncol(table)] = NULL   # 종목 토론 삭제
    table = na.omit(table)  # 빈 행 삭제
    
    # 6자리 티커만 추출
    symbol = read_html(down_table, encoding = "EUC-KR") %>%
      html_nodes(., 'tbody') %>%
      html_nodes(., 'td') %>%
      html_nodes(., "a") %>%
      html_attr(., "href")
    
    symbol = sapply(symbol, function(x) {
      str_sub(x, -6, -1)
    })
    
    symbol = unique(symbol)
    
    # 테이블에 티커 넣은 후 테이블 정리
    table$N = symbol
    colnames(table)[1] = '종목코드'
    
    rownames(table) = NULL
    ticker[[j]] = table
    
    Sys.sleep(0.5)
  }
  
  # do.call을 통해 리스트를 데이터 프레임으로 묶기
  ticker = do.call(rbind, ticker)
  data[[i+1]] = ticker
}

# 코스피와 코스닥 테이블 묶기
data = do.call(rbind, data)

write.csv(data, "C:/Users/user/Documents/Quant_backtesting/R을 이용한 퀀트투자 포트폴리오 만들기/KOR_ticker.csv")