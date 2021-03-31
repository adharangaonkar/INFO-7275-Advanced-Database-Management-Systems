import numpy as np
import pandas as pd
from textblob import TextBlob
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer


###############READ DATA FROM AZURE BLOB STORAGE##########################

"""

As fetching data from Blob to move ahead with ETL process needs a virtual environment setup for Azure Storage Blob Libraries.
Below is the code that fetches blobs from Azure Storage and converts it to Dataframe on the fly.
Being it a cumbersome process, currently we begin the ETL process by fetching the CSV files locally. 
We will demonstrate the Pipeline in our further submissions 

"""

# !pip install azure-storage-blob
# from azure.storage.blob import BlobServiceClient
# from azure.storage.blob import ContentSettings, ContainerClient, BlobClient
# from io import StringIO
# from io import BytesIO
# import os
#
# AZURE_STORAGE_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=adbmsdata;AccountKey=majMcgrT5S0zrx7ZRNjzShni7qbtdAuv+uMX3GFmIB7NHSi4dk1asLvg7BGClaxChF7XJK0bkMWN1AAKWL2LXQ==;EndpointSuffix=core.windows.net"
# MY_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
# MY_BLOB_CONTAINER = "demotrial"
# MY_BLOB_CONTAINER_AUTO = "autodemo"
# LOCAL_BLOB_PATH = "/adbmsdata"
#
#
# class AzureBlobFileDownloader:
#     def __init__(self):
#         print("Intializing AzureBlobFileDownloader")
#
#         # Initialize the connection to Azure storage account
#         self.blob_service_client = BlobServiceClient.from_connection_string(AZURE_STORAGE_CONNECTION_STRING)
#         self.my_container = self.blob_service_client.get_container_client(MY_BLOB_CONTAINER_AUTO)
#
#     def save_blob(self, file_name, file_content):
#         # Get full path to the file
#         download_file_path = os.path.join(LOCAL_BLOB_PATH, file_name)
#
#         # for nested blobs, create local path as well!
#         os.makedirs(os.path.dirname(download_file_path), exist_ok=True)
#
#         with open(download_file_path, "wb") as file:
#             # file.write(file_content)
#             var = BytesIO(file_content)
#             vardf = pd.DataFrame(var)
#             print(vardf.head())
#
#     def download_all_blobs_in_container(self):
#         my_blobs = self.my_container.list_blobs()
#         for blob in my_blobs:
#             print(blob.name)
#             bytes = self.my_container.get_blob_client(blob).download_blob().readall()
#             self.save_blob(blob.name, bytes)


# Initialize class and upload files

# azure_blob_file_downloader = AzureBlobFileDownloader()
# azure_blob_file_downloader.download_all_blobs_in_container()


###################Product Catalog########################

product = pd.read_csv("product_catalog.csv", encoding="utf-8").iloc[:, 1:]

# Product Data Cleaning
product[['number_available_in_stock']] = product[['number_available_in_stock']].fillna(value='0\xa0ProductUnavailable')

# Changing the '\xa0' encoding to ' '
product['number_available_in_stock'] = product['number_available_in_stock'].str.split().str.join(' ')

# Splitting the Dataframe Column 'number_available_in_stock' into two Columns 'AvailableStock' and 'ProductType'
stock = product["number_available_in_stock"].str.split(" ", n=1, expand=True)
product["AvailableStock"] = stock[0]
product["ProductType"] = stock[1]

prod_final = product[['product_id', 'product_name', 'manufacturer', 'AvailableStock',
                      'ProductType']]

# print(prod_final)

                                            ###################Customer########################
# Importing Customer Demographics
customer = pd.read_csv("customer.csv").iloc[:, 1:]

                                  ###################Reviews and Sentiment Analysis########################
# Importing Product Reviews
reviews = pd.read_csv("reviews.csv").iloc[:, 1:]

data = reviews[['review_id', 'product_id', 'reviews.rating', 'reviews.title', 'reviews.text']]
data["reviews.text"] = data["reviews.text"].astype("str")

############Sentiment Analysis using Vader################

"""
VADER ( Valence Aware Dictionary for Sentiment Reasoning) is a model used for text sentiment analysis that is sensitive to both polarity (positive/negative) and intensity (strength) of emotion. 
It is available in the NLTK package and can be applied directly to unlabeled text data.
VADER sentimental analysis relies on a dictionary that maps lexical features to emotion intensities known as sentiment scores.
 The sentiment score of a text can be obtained by summing up the intensity of each word in the text.

"""

# load VADER
analyzer = SentimentIntensityAnalyzer()
# Add VADER metrics to dataframe

data['compound'] = [analyzer.polarity_scores(v)['compound'] for v in data['reviews.text']]
data['neg'] = [analyzer.polarity_scores(v)['neg'] for v in data['reviews.text']]
data['neu'] = [analyzer.polarity_scores(v)['neu'] for v in data['reviews.text']]
data['pos'] = [analyzer.polarity_scores(v)['pos'] for v in data['reviews.text']]

# Print this Dataframe to get Sentiment Analysis for each Review
# print(data)

# Aggregating Ratings, Compound Review, Negative Review, Neutral Review, Positive Review
a = data.groupby(data["product_id"])[["reviews.rating", "compound", "neg", "neu", "pos"]].agg(["mean"])
a.columns = ['_'.join(col) for col in a.columns.values]

                                    #########################Sales#########################
# Importing Sales Data
sales = pd.read_csv("sales_imp.csv")

# Renaming Columns to match data
sales.rename(columns={"StockCode": "product_id", "Customer ID": "CustomerID"}, inplace=True)

                                    ################Combining Dataframes###################


#############Combining Product Data with Sentiments#################
product_catalog_final = prod_final.merge(a, on='product_id')
# product_catalog_final.to_csv("product_sentiment.csv", index=False)
# print(product_catalog_final)

#############Combining Product and Sales Data#################
product_sales = sales.merge(product_catalog_final, on='product_id')
product_sales['SaleID'] = product_sales.index
# product_sales.to_csv("product_sales.csv", index= False)
# print(product_sales)

##############Combining Sales and Customer Data################
sales_customer = sales.merge(customer, on='CustomerID')
sales_customer['SaleID'] = sales_customer.index
# sales_customer.to_csv("sales_customer.csv", index = False)
# print(sales_customer)
