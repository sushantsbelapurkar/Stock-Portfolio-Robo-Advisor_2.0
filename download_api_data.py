#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import json
import csv
import urllib.request
import pandas as pd
import numpy as np
import pymysql
from io import BufferedReader

# THIS CODE NEEDS TO BE RUN BEFORE MAKING THE SQL CONNECTION

pymysql.converters.encoders[np.float64] = pymysql.converters.escape_float
pymysql.converters.conversions = pymysql.converters.encoders.copy()
pymysql.converters.conversions.update(pymysql.converters.decoders)

# In[ ]:


from IPython.core.interactiveshell import InteractiveShell

InteractiveShell.ast_node_interactivity = "all"


# In[ ]:


# METHOD 1 FOR SQL CONNECTION
# import mysql.connector as msc
# mydb1 = msc.connect(host='127.0.0.1',user='root',passwd='Sushant#1485abcd',database='mysql_portfolio',auth_plugin='mysql_native_password')
# print('Connection Successfull')
# If error occures: Authentication plugin 'caching_sha2_password' is not supported
# Run below command in Mysql:
# ALTER USER 'your_username'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password';


# In[ ]:


def saveToSQL(dataframe, tablename, todo):
    # METHOD 2 FOR SQL CONNECTION
    from sqlalchemy import create_engine
    engine = create_engine('mysql+pymysql://root:Sushant#1485abcd@localhost/mysql_portfolio')
    print("connection established Method 1")
    #     print(dataframe)
    # Start index from 1 instead of 0 (default)
    dataframe.index = dataframe.index + 1
    dataframe.to_sql(tablename, con=engine, schema='mysql_portfolio', if_exists=todo, index=True, index_label='id',
                     method=None)
    print('Data has been loaded to', tablename, 'table')


# In[ ]:


# # Calling MySQL stored procedure
# import mysql.connector as msc
# from mysql.connector import Error

# def call_proc(procedure,table):
# # METHOD 2 FOR SQL CONNECTION
#     try:
#         conn = msc.connect(host='127.0.0.1',user='root',passwd='Sushant#1485abcd',database='mysql_portfolio')
#         print('Connection Successfull Method 2')
#         cursor = conn.cursor()
#         cursor.execute(""""
#         CREATE PROCEDURE""" procedure
#         """"
#         BEGIN
#         ALTER TABLE""" table
#         """"
#         DROP COLUMN id,
#         ADD COLUMN id bigint not null auto_increment primary key FIRST;
#         END
#         """)
#         cursor.callproc(procedure)
#         print(procedure, 'executed successfully')
#     except msc.Error as error:
#         print("Failed to execute stored procedure: {}".format(error))
#     finally:
#         if (conn.is_connected()):
#             cursor.close()
#             conn.close()
#             print("MySQL connection is closed")


# In[ ]:


# !/usr/bin/env python
# list of symbols having financial ratios available:
# try:
#     # For Python 3.0 and later
#     from urllib.request import urlopen
# except ImportError:
#     # Fall back to Python 2's urllib2
#     from urllib2 import urlopen

# import certifi

########## METHOD 1 TO READ DATA
# def get_symbol_data(url):
#     response = urlopen(url, cafile=certifi.where())
#     data_symbol_list = response.read().decode("utf-8")
#     return json.loads(data_symbol_list)

# url = ("https://financialmodelingprep.com/api/v3/stock/list?apikey=96d0bbfe61e1cad96d3a497d880cdd2f")
# symbol_list = (get_symbol_data(url))
# print(symbol_list)


# In[ ]:


#### METHOD 2 TO READ DATA
#### Reading all symbols
url = ("https://financialmodelingprep.com/api/v3/stock/list?apikey=96d0bbfe61e1cad96d3a497d880cdd2f")
df_symbol_list = pd.read_json(url)
# df_symbol_list.head(10)
saveToSQL(df_symbol_list, "symbol_list", 'replace')
print('Entire Data loaded in table')
# call_proc('insert_datetime_income_statemnent')


# In[ ]:


# # limit API call
# from ratelimit import limits, RateLimitException
# import requests
# from backoff import on_exception, expo
# # ratelimits use to limit the API calls; more on ratelimit : https://pypi.org/project/ratelimit/
# # backoff can be used to wrap a function such that it will be retried until some condition is met ;
# # more on backoff : https://pypi.org/project/backoff/

# limit_apicall_period = 500
# @on_exception(expo, RateLimitException, max_tries=8)
# @limits (calls = 10, period = limit_apicall_period)

# def call_api(url):
#     response = requests.get(url)
#     if response.status_code != 200:
#         raise Exception('API response: {}'.format(response.status_code))
#     return response


# In[ ]:


# Code to load shares float/shares data
import urllib.request, json
import pandas as pd

# rowcount = 0
url = 'https://financialmodelingprep.com/api/v4/shares_float?symbol=stock_name&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS', 'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS',
          'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS', 'NAVINFLUOR.NS']
for x in symbol:
    newurl = url.replace('stock_name', x)
    df_shares_float = pd.read_json(newurl)
    saveToSQL(df_shares_float, "shares_float", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


import json
import requests

data = json.loads(requests.get(
    'https://financialmodelingprep.com/api/v4/company-outlook?symbol=AAPL&apikey=96d0bbfe61e1cad96d3a497d880cdd2f').text)
# list(d.keys())

df_comp = pd.DataFrame({'profile': data})
saveToSQL(df_comp, "company_outlook", 'append')

# In[ ]:


import json

with open('people_wiki_map_index_to_word.json', 'r') as f:
    data = json.load(f)
    df = pd.DataFrame({'count': data})

# In[ ]:


# Code to load company outlook data
import urllib.request, json
import pandas as pd
from pandas.io.json import json_normalize

# rowcount = 0
url = 'https://financialmodelingprep.com/api/v4/company-outlook?symbol=stock_name&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS', 'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS',
          'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS', 'NAVINFLUOR.NS']
for x in symbol:
    newurl = url.replace('stock_name', x)
    print(newurl)
    df_company_outlook = pd.json_normalize(newurl)
    print(df_company_outlook)
#     data = json.load(newurl)
#     df_company_outlook = pd.DataFrame(data['profile'])
#     saveToSQL(df_company_outlook,"company_outlook",'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


import requests
import pandas as pd
import json
from pandas.io.json import json_normalize

url = "https://financialmodelingprep.com/api/v4/company-outlook?symbol=AAPL&apikey=96d0bbfe61e1cad96d3a497d880cdd2f"
df = pd.read_json(url)
# data = pd.DataFrame.from_dict(requests.get(url).json()['profile'])

# print(data)


# In[ ]:


# Code to load income statement  - 1
import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/income-statement/symbol?limit=120&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS', 'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS',
          'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS', 'NAVINFLUOR.NS']
for x in symbol:
    newurl = url.replace('symbol', x)
    df_income_statement = pd.read_json(newurl)
    saveToSQL(df_income_statement, "income_statement", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# # Code to load income statement  - 2
# # we can use function if internet connectivity issue occurs
# import urllib.request, json
# import pandas as pd

# symbol = df_symbol_list['symbol']
# print(symbol)
# url = 'https://financialmodelingprep.com/api/v3/income-statement/symbol?limit=120&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

# def fetch_income_statement(url) :
#     try:
#         for x in symbol:
#             newurl = url.replace('symbol',x)
#             df_income_statement = pd.read_json(newurl)
#             df_income_statement.append(df_income_statement)
#             return df_income_statement
#     except:
#         print('Failed loading...trying again')
#         return fetch_income_statement(url)

# saveToSQL(df_income_statement,"income_statement",'append')


# In[ ]:


# # Code to load income statement growth
# import urllib.request, json
# import pandas as pd

# rowcount = 0
# url = 'https://financialmodelingprep.com/api/v3/income-statement-growth/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']

# # symbol = ['AAPL','MSFT','F','AMD','FB']
# for x in symbol:
#     newurl = url.replace('symbol',x)
#     df_income_statement_g = pd.read_json(newurl)
#     saveToSQL(df_income_statement_g,"income_statement_growth",'append')
# #     df_income_statement.append(df_income_statement)
# #     call_api(newurl)


# In[ ]:


# Code to load balance sheet
import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/balance-sheet-statement/symbol?limit=120&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']
for x in symbol:
    newurl = url.replace('symbol', x)
    df_balance_sheet = pd.read_json(newurl)
    saveToSQL(df_balance_sheet, "balance_sheet", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# # Code to load balance sheet growth
# import urllib.request, json
# import pandas as pd

# rowcount = 0
# url = 'https://financialmodelingprep.com/api/v3/balance-sheet-statement-growth/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']

# # symbol = ['AAPL','MSFT','F','AMD','FB']
# for x in symbol:
#     newurl = url.replace('symbol',x)
#     df_balance_sheet_g = pd.read_json(newurl)
#     saveToSQL(df_balance_sheet_g,"balance_sheet_growth",'append')
# #     df_income_statement.append(df_income_statement)
# #     call_api(newurl)


# In[ ]:


# Code to load cash flow shtatement
import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/cash-flow-statement/symbol?limit=120&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']

for x in symbol:
    newurl = url.replace('symbol', x)
    df_cash_flow = pd.read_json(newurl)
    saveToSQL(df_cash_flow, "cash_flow_statement", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# # Code to load cash flow shtatement growth
# import urllib.request, json
# import pandas as pd

# rowcount = 0
# url = 'https://financialmodelingprep.com/api/v3/cash-flow-statement-growth/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']

# # symbol = ['AAPL','MSFT','F','AMD','FB']
# for x in symbol:
#     newurl = url.replace('symbol',x)
#     df_cash_flow_g = pd.read_json(newurl)
#     saveToSQL(df_cash_flow_g,"cash_flow_statement_growth",'append')
# #     df_income_statement.append(df_income_statement)
# #     call_api(newurl)


# In[ ]:


# Code to load overall financial growth
# Financial Statement Growth of a company based on its financial statement,
# it compares previous financial statement to get growth of all its statement.

import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/financial-growth/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']

for x in symbol:
    newurl = url.replace('symbol', x)
    df_financial_growth = pd.read_json(newurl)
    saveToSQL(df_financial_growth, "financial_growth", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# Code to load financial_ratios
import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/ratios/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
# symbol = ['AAPL','MSFT','F','AMD','FB']
symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']
for x in symbol:
    newurl = url.replace('symbol', x)
    df_fin_ratios = pd.read_json(newurl)
    saveToSQL(df_fin_ratios, "financial_ratios", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# Code to load key_metrics
import urllib.request, json
import pandas as pd

rowcount = 0
url = 'https://financialmodelingprep.com/api/v3/key-metrics/symbol?limit=60&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# symbol = df_symbol_list['symbol']
symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']

for x in symbol:
    newurl = url.replace('symbol', x)
    df_key_metrics = pd.read_json(newurl)
    saveToSQL(df_key_metrics, "key_metrics", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)
print('Entire Data loaded in table')

# In[ ]:


# Stock screener NYSE,NASDAQ
# UPDATE DAILY
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v3/stock-screener?marketCapLowerThan=10000000000000&betaMoreThan=0.0&volumeMoreThan=100&exchange=NYSE,NASDAQ&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
df_stock_screener_usa = pd.read_json(url)
saveToSQL(df_stock_screener_usa, "stock_screener", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)


# In[ ]:


# Stock screener NSE
# UPDATE DAILY
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v3/stock-screener?marketCapLowerThan=10000000000000&betaMoreThan=0.0&volumeMoreThan=100&exchange=NSE&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_stock_screener_nse = pd.read_json(url)
saveToSQL(df_stock_screener_nse, "stock_screener", 'append')
#     df_income_statement.append(df_income_statement)


# In[ ]:


# Sector p/e NYSE
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/sector_price_earning_ratio?date=2021-11-12&exchange=NYSE&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_sectorpe_usa = pd.read_json(url)
saveToSQL(df_sectorpe_usa, "sector_pe", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)


# In[ ]:


# Sector p/e NASDAQ
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/sector_price_earning_ratio?date=2021-05-07&exchange=NASDAQ&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_sectorpe_usa = pd.read_json(url)
saveToSQL(df_sectorpe_usa, "sector_pe", 'append')
#     df_income_statement.append(df_income_statement)
#     call_api(newurl)


# In[ ]:


# Sector p/e NSE
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/sector_price_earning_ratio?date=2021-11-12&exchange=NSE&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_sectorpe_nse = pd.read_json(url)
saveToSQL(df_sectorpe_nse, "sector_pe", 'append')
#     df_income_statement.append(df_income_statement)


# In[ ]:


# Industry p/e NYSE
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/industry_price_earning_ratio?date=2021-11-12&exchange=NYSE&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_industrype_usa = pd.read_json(url)
saveToSQL(df_industrype_usa, "industry_pe", 'append')
#     df_income_statement.append(df_income_statement)


# In[ ]:


# Industry p/e NASDAQ
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/industry_price_earning_ratio?date=2021-11-12&exchange=NASDAQ&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_industrype_usa = pd.read_json(url)
saveToSQL(df_industrype_usa, "industry_pe", 'append')
#     df_income_statement.append(df_income_statement)


# In[ ]:


# Industry p/e NSE
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

url = 'https://financialmodelingprep.com/api/v4/industry_price_earning_ratio?date=2021-07-07&exchange=NSE&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'

df_industrype_nse = pd.read_json(url)
saveToSQL(df_industrype_nse, "industry_pe", 'append')
#     df_income_statement.append(df_income_statement)


# In[ ]:


# Historical Prices
# UPDATE BY PROVIDING MANUAL DATE
import urllib.request, json
import pandas as pd

# This API contails multilevel json file which cannot handled by read_json()
# so we will use jason.loads() AND json_normalize()
# more info:https://towardsdatascience.com/all-pandas-json-normalize-you-should-know-for-flattening-json-13eae1dfb7dd

symbol = ['AAPL', 'MSFT', 'F', 'AMD', 'FB', 'MRF.NS', 'SHAKTIPUMP.NS', 'OAL.NS', 'KSCL.NS', 'MARKSANS.NS',
          'LICHSGFIN.NS', 'CANFINHOME.NS', 'SASKEN.NS', 'HINDPETRO.NS', 'TIDEWATER.NS', 'HIL.NS', 'BALKRISIND.NS',
          'NAVINFLUOR.NS']
url = 'https://financialmodelingprep.com/api/v3/historical-price-full/symbol?apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
idx = 0
for x in symbol:
    newurl = url.replace('symbol', x)
    with urllib.request.urlopen(newurl) as newurl:
        data = json.loads(newurl.read().decode())
        #         print(data)
        df_hist_price = pd.json_normalize(data['historical'])
        #         df_hist_price ['symbol'] = x   # This will add a new column to dataframe at last position by default
        df_hist_price.insert(loc=idx, column='symbol',
                             value=x)  # This will add a new column at specific/required location
        #         dt = pd.DataFrame(data =[{'symbol':x,}])
        #         df_hist_price.head(10)
        saveToSQL(df_hist_price, "historical_prices", 'append')
print('Entire data is loaded')

# In[ ]:


import urllib.request, json
import pandas as pd
import requests

symbol = ['AAPL']
url = 'https://financialmodelingprep.com/api/v3/historical-price-full/symbol?apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
for x in symbol:
    newurl = url.replace('symbol', x)
    jsonfile = requests.get(
        'https://financialmodelingprep.com/api/v3/historical-price-full/symbol?apikey=96d0bbfe61e1cad96d3a497d880cdd2f')
    print(jsonfile)
#     fin_dict = jsonfile.json()
#     fin_history_dict = fin_dict['historical']
#     historic_data = list(fin_history_dict.values())
#     df=pd.DataFrame(data = historic_data,index=fin_dict['history'])


# In[ ]:


# #JUST FOR AN EXERCISE
# #ADDING COLUMN IN A DATAFRAME FROM ANOTHER DATAFRAME TO SAVE IN DATABASE

# # in below API link we do not have 'symbol' in json file. So we will
# # 1 Read symbol table from database in dataframe.
# # 2 we will retrieve API data from symbol and will insert in new dataframe
# # 3 then we will append symbol to new dataframe.

# #1 Read symbol
# from sqlalchemy import create_engine
# engine = create_engine('mysql+pymysql://root:Sushant#1485abcd@localhost/mysql_portfolio')
# df_symbolfromdb = pd.read_sql_table('symbol_list',engine)
# df_symbolfromdb.head(5)
# symbol = df_symbolfromdb['symbol']

# #2 Retrieve data
# rowcount = 0
# url = 'https://financialmodelingprep.com/api/v3/technical_indicator/daily/symbol?period=0&type=ema&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# for x in symbol:
#     newurl = url.replace('symbol',x)
#     df_daily_price = pd.read_json(newurl)
# #3 Append symbol
#     df_daily_price['symbol'] = x
#     saveToSQL(df_daily_price,"daily_price",'append')

# df_daily_price.head(10)
# #     df_income_statement.append(df_income_statement)
# #     call_api(newurl)


# In[ ]:


# #JUST FOR AN EXERCISE
# #ADDING COLUMN AS A FOREIGN KEY IN A DATAFRAME FROM ANOTHER DATAFRAME TO SAVE IN DATABASE
# # in below API link we do not have 'symbol' in json file. So we will
# # 1 Read symbol table from database in dataframe.
# # create another dataframe 'symbol_id' with symbol and its id
# # 2 we will retrieve API data from symbol and will insert in new dataframe
# # 3 then we will JOIN 'symbol_id' to new dataframe based on symbol we retrieved the data.

# #1 Read symbol
# from sqlalchemy import create_engine
# engine = create_engine('mysql+pymysql://root:Sushant#1485abcd@localhost/mysql_portfolio')
# df_symbolfromdb = pd.read_sql_table('symbol_list',engine)
# df_symbolfromdb.head(5)
# df_symbol_id = df_symbolfromdb[['symbol','id']].copy()
# df_symbol_id.rename({'id': 'symbol_id'}, axis=1, inplace=True)
# df_symbol_id.head(5)

# symbol = df_symbolfromdb['symbol']
# #2 Retrieve data
# rowcount = 0
# url = 'https://financialmodelingprep.com/api/v3/technical_indicator/daily/symbol?period=0&type=ema&apikey=96d0bbfe61e1cad96d3a497d880cdd2f'
# for x in symbol:
#     newurl = url.replace('symbol',x)
#     df_daily_price2 = pd.read_json(newurl)
# #3 Append symbol
#     df_daily_price2['symbol'] = x
#     print(x)
#     df_daily_price_with_foreign_key = pd.merge(df_daily_price2,df_symbol_id,on='symbol')
#     saveToSQL(df_daily_price_with_foreign_key,"daily_price2",'append')

# df_daily_price_with_foreign_key(5)
# # df_daily_price.head(10)
# # #     df_income_statement.append(df_income_statement)
# #     call_api(newurl)


# In[ ]:


import xml.etree.ElementTree as ET
import urllib.request

import mysql.connector as msc

mydb1 = msc.connect(host='127.0.0.1', user='root', passwd='Sushant#1485abcd', database='mysql_portfolio',
                    auth_plugin='mysql_native_password')

if mydb1:
    print("Connected Successfully")
else:
    print("Connection Not Established")

url = 'https://www.treasury.gov/resource-center/data-chart-center/interest-rates/pages/XmlView.aspx?data=yield'
response = urllib.request.urlopen(url).read()
tree = ET.fromstring(response)

data2 = tree.findall('pre')
print(data2)

for i, j in zip(data2, range(1, 100)):
    latest_date = i.find('INDEX_DATE').text
    print(latest_date)
    t_bill_rate = i.find('ROUND_B1_CLOSE_13WK_2').text

    # sql query to insert data into database
    data = """INSERT INTO mysql_portfolio.risk_free_rate(latest_date,t_bill_rate) VALUES(%s,%s)"""

    c = conn.cursor()
    # executing cursor object
    c.execute(data, (latest_date, t_bill_rate))
    conn.commit()
    print("vignan student No-", j, " stored successfully")

print("done")
# for compTitle in tree.findall('.//{urn:hl7-org:v3}title'):
#     print(compTitle.text)

DOWNLOAD
RATING
AND
DCF
VALUE
API
AFTER
DEVELOPING
OUR
PRODUCT

AND
COMPARE
OUR
PRICES
AND
BUY / SELL
SIGNAL
WITH
API
VALUES

DOWNLOAD
PEER
LIST
DATA
AS
WELL, GOOD
INFO
FOR
IDENTIFY
GROWTH
STOCK

SOME
GOOD
NOTES
ABOUT
GROWTH
STOCK:
1.
https: // www.dummies.com / personal - finance / investing / stocks - trading / how - to - choose - growth - stocks /
2.
https: // www.investopedia.com / terms / g / growthstock.asp

# In[ ]:


STUDY
THIS
FROM
API:

https: // site.financialmodelingprep.com / developer / docs / formula

https: // site.financialmodelingprep.com / developer / docs / dcf - formula

https: // site.financialmodelingprep.com / developer / docs / recommendations - formula

