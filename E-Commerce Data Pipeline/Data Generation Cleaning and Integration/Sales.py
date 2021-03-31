import numpy as np
import pandas as pd
import random

#data source : https://archive.ics.uci.edu/ml/datasets/Online+Retail+II

# Importing Sales Data
sales = pd.read_csv("online_retail_II.csv")
sales.dropna(inplace = True)
sales_imp = sales[['Invoice', 'StockCode', 'Quantity', 'InvoiceDate',
       'Price', 'Customer ID']]

# Calculating Amount per product
sales_imp["ProductAmount"] = sales_imp['Quantity'] * sales_imp['Price']

# Conversion to Datatime
sales_imp['InvoiceDate'] =  pd.to_datetime(sales_imp['InvoiceDate'], format='%Y%m%d %H:%M:%S.%f')


# Choosing Sales Data for year 2011
sales_imp = sales_imp[sales_imp.InvoiceDate > "2010-12-31 23:59:59"]


# Substituting ProductID and CustomerID in Sales Dataframe
StockCode = [a for a in set(sales_imp.StockCode)]
prod_id = [a for a in range (0,10000)]
prod_id_list = random.sample(prod_id, len(StockCode))
res = dict(zip(StockCode, prod_id))
sales_imp_copy = sales_imp.copy()
sales_imp_copy['StockCode']=sales_imp_copy['StockCode'].map(res)

sales_imp_copy = sales_imp_copy.reset_index()
sales_imp_copy.drop("index", axis= 1, inplace = True)
sales_imp_copy['Customer ID'] = sales_imp_copy['Customer ID'].apply(np.int64)

cust_list = [a for a in set(sales_imp_copy["Customer ID"])]
cust_id = [a for a in range (0,4245)]
res1 = dict(zip(cust_list, cust_id))
sales_imp_copy['Customer ID']=sales_imp_copy['Customer ID'].map(res1)


# print(sales_imp_copy)
# sales_imp_copy.to_csv("sales_imp.csv", index=False)