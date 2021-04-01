import pandas as pd
import json
import azure.cosmos.cosmos_client as cosmos_client
import azure.cosmos.errors as errors
import azure.cosmos.documents as documents
import azure.cosmos.http_constants as http_constants

print('Imported packages successfully.')

# Initialize the Cosmos client
"""

We will start by importing the necessary packages and creating the Cosmos client. 
By initializing the Cosmos client with our URI endpoint and access key, 
we will be able to use the azure-cosmos API to interact with our Cosmos DB account.

"""

from azure.cosmos import CosmosClient, exceptions
import os

url = "https://adbms-cosmos.documents.azure.com:443/"
key = 'MjyGDQH9W1ZRAPUkhDzSyKHhPQS3nmUIXOm2MpE8tIDx7EYXx5sLkBkpWXUUoAlfVHDXZzcQm461NTyUU2GUmA=='
client = CosmosClient(url, credential=key)
database_name = 'HDIdatabase'
try:
    database = client.create_database(database_name)
except exceptions.CosmosResourceExistsError:
    database = client.get_database_client(database_name)


# Importing Data
df = pd.read_csv("product_sales.csv", encoding='ISO-8859–1',dtype='str')
# Filling NA values in Manufacturer Column with 'Undisclosed
df.fillna(value = "Undisclosed", inplace= True)

# Changing Precision of Float Data
df["reviews.rating_mean"] = df[["reviews.rating_mean"]].applymap(lambda x: x[:4])
df["compound_mean"] = df[["compound_mean"]].applymap(lambda x: x[:4])
df["neg_mean"] = df[["neg_mean"]].applymap(lambda x: x[:4])
df["neu_mean"] = df[["neu_mean"]].applymap(lambda x: x[:4])
df["pos_mean"] = df[["pos_mean"]].applymap(lambda x: x[:4])

# Changing Data Types
df['reviews.rating_mean'] = df['reviews.rating_mean'].astype("float64")
df['compound_mean'] = df['compound_mean'].astype("float64")
df['neg_mean'] = df['neg_mean'].astype("float64")
df['neu_mean'] = df['neu_mean'].astype("float64")
df['pos_mean'] = df['pos_mean'].astype("float64")
df['AvailableStock'] = df['AvailableStock'].astype("float64")

#Create a Database and a Container within it
from azure.cosmos import CosmosClient, PartitionKey, exceptions
client = CosmosClient(url, credential=key)
database_name = 'HDIdatabase'
database = client.get_database_client(database_name)
container_name = 'SalesDetails'

try:
    container = database.create_container(id=container_name, partition_key=PartitionKey(path="/SaleID"))
except exceptions.CosmosResourceExistsError:
    container = database.get_container_client(container_name)
except exceptions.CosmosHttpResponseError:
    raise


# Retreiving an existing container from an existing database
client = CosmosClient(url, credential=key)
database_name = 'HDIdatabase'
database = client.get_database_client(database_name)
container_name = 'SalesDetails'
container = database.get_container_client(container_name)



# Upsert the data to Cosmos DB
"""

we will iterate over the rows of the pandas DataFrame and create a dictionary of each row. 
That dictionary is already nicely formatted for json extraction, which is accomplished with json.dumps(). 
Each row is then written to the Cosmos DB as the for loop executes

"""

for i in range(0,df.shape[0]):
    # create a dictionary for the selected row
    data_dict = dict(df.iloc[i,:])
    # convert the dictionary to a json object.
    data_dict = json.dumps(data_dict)
    insert_data = container.upsert_item(json.loads(data_dict)
    )
print('Records inserted successfully.')