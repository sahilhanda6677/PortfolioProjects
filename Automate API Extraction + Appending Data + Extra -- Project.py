#!/usr/bin/env python
# coding: utf-8

# In[1]:


from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json

url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {
  'start':'1',
  'limit':'5000',
  'convert':'USD'
}
headers = {
  'Accepts': 'application/json',
  'X-CMC_PRO_API_KEY': '73e3735a-8e27-4c9b-8270-fccd3f2284d4',
}

session = Session()
session.headers.update(headers)

try:
  response = session.get(url, params=parameters)
  data = json.loads(response.text)
  print(data)
except (ConnectionError, Timeout, TooManyRedirects) as e:
  print(e)


# In[18]:


import pandas as pd
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)


# In[4]:


df=pd.json_normalize(data['data'])
df['timestamp'] = pd.to_datetime('now')
df


# In[25]:


def api_runner():
    global df
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    parameters = {
      'start':'1',
      'limit':'15',
      'convert':'USD'
    }
    headers = {
      'Accepts': 'application/json',
      'X-CMC_PRO_API_KEY': '73e3735a-8e27-4c9b-8270-fccd3f2284d4',
    }

    session = Session()
    session.headers.update(headers)

    try:
      response = session.get(url, params=parameters)
      data = json.loads(response.text)
      #print(data)
    except (ConnectionError, Timeout, TooManyRedirects) as e:
      print(e)
    
    df2 = pd.json_normalize(data['data'])
    df2['Timestamp'] = pd.to_datetime('now')
    df = pd.concat([df, df2])
    
    #if not os.path.isfile(r'C:\Users\sahil\OneDrive\Email attachments\Documents\api.csv'):
        #df.to_csv(r'C:\Users\alexf\OneDrive\Documents\Python Scripts\API.csv', header='column_names')
    #else:
        #df.to_csv(r'C:\Users\alexf\OneDrive\Documents\Python Scripts\API.csv', mode='a', header=False)


# In[26]:


import os
from time import time
from time import sleep

for i in range(333):
    api_runner()
    print('Api runner completed')
    sleep(60)#Sleep for one minute
exit()    


# In[27]:


df


# In[28]:


pd.set_option('display.float_format', lambda x: '%.5f' % x)


# In[29]:


df


# In[30]:


df3 = df.groupby('name', sort=False)[['quote.USD.percent_change_1h','quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d']].mean()
df3


# In[31]:


df4 = df3.stack()
df4


# In[32]:


type(df4)


# In[33]:


df5 = df4.to_frame(name='values')
df5


# In[34]:


df5.count()


# In[36]:


index = pd.Index(range(90))

df6 = df5.reset_index()
df6


# In[37]:


df7 = df6.rename(columns={'level_1': 'percent_change'})
df7


# In[38]:


import seaborn as sns
import matplotlib.pyplot as plt


# In[41]:


df7['percent_change'] = df7['percent_change'].replace(['quote.USD.percent_change_1h'],  ['1h'])
df7
df7['percent_change'] = df7['percent_change'].replace(['quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d'],['24h','7d','30d','60d','90d'])
df7


# In[42]:


sns.catplot(x='percent_change', y='values', hue='name', data=df7, kind='point')


# In[44]:


df9 = df[['name','quote.USD.price','Timestamp']]
df9 = df9.query("name == 'Bitcoin'")
df9


# In[46]:


sns.set_theme(style="darkgrid")

sns.lineplot(x='Timestamp', y='quote.USD.price', data = df9)


# In[ ]:




