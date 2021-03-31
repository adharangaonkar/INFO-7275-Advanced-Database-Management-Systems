#To use Reco Utils,follow the instructions
"""To setup on your local machine:

Install Anaconda with Python >= 3.6. Miniconda is a quick way to get started.

Clone the repository

git clone https://github.com/Microsoft/Recommenders
Run the generate conda file script to create a conda environment: (This is for a basic python environment, see SETUP.md for PySpark and GPU environment setup)
cd Recommenders
python tools/generate_conda_file.py
conda env create -f reco_base.yaml
Activate the conda environment and register it with Jupyter:
conda activate reco_base
python -m ipykernel install --user --name reco_base --display-name "Python (reco)"
Start the Jupyter notebook server
jupyter notebook
"""


import sys
sys.path.append("../../")
import pandas as pd
import tensorflow as tf
tf.get_logger().setLevel('ERROR') # only show error messages

from reco_utils.common.timer import Timer
from reco_utils.recommender.ncf.ncf_singlenode import NCF
from reco_utils.recommender.ncf.dataset import Dataset as NCFDataset
from reco_utils.dataset import movielens
from reco_utils.common.notebook_utils import is_jupyter
from reco_utils.dataset.python_splitters import python_chrono_split
from reco_utils.evaluation.python_evaluation import (rmse, mae, rsquared, exp_var, map_at_k, ndcg_at_k, precision_at_k,
                                                     recall_at_k, get_top_k_items)

print("System version: {}".format(sys.version))
print("Pandas version: {}".format(pd.__version__))
print("Tensorflow version: {}".format(tf.__version__))


# Import Sales Data
sales = pd.read_csv("sales_imp.csv")
data_series = sales.groupby(['Customer ID', 'StockCode'])['Quantity'].sum()
new_sales = data_series.to_frame \
    (name = 'sum').reset_index() # using total number of prodcuts purcahsed by a customer as default weights

# Renaming for convinience
new_sales.rename(columns = {'Customer ID' :'userID', 'StockCode' :'itemID',
                              'sum' :'rating'}, inplace = True)


# Custom Split
train, test = python_chrono_split(new_sales, 0.75)

# Customizing Data
data = NCFDataset(train=train, test=test, seed=SEED)

# Neural Collaborative Filtering Model
model = NCF (
    n_users=data.n_users,
    n_items=data.n_items,
    model_type="NeuMF",
    n_factors=4,
    layer_sizes=[16 ,8 ,4],
    n_epochs=EPOCHS,
    batch_size=BATCH_SIZE,
    learning_rate=1e-3,
    verbose=10,
    seed=SEED
)


# Fitting the data into the model
model.fit(data)



users, items, preds = [], [], []
item = list(train.itemID.unique())
for user in train.userID.unique():
    user = [user] * len(item)
    users.extend(user)
    items.extend(item)
    preds.extend(list(model.predict(user, item, is_list=True)))

all_predictions = pd.DataFrame(data={"userID": users, "itemID" :items, "prediction" :preds})

merged = pd.merge(train, all_predictions, on=["userID", "itemID"], how="outer")
all_predictions = merged[merged.rating.isnull()].drop('rating', axis=1)


# Selecting Top 5 Recommended Products on the Basis of Model Predictions
top_5_predictions = all_predictions.sort_values(['userID','prediction'], ascending=False).groupby('userID').head(5)
final_5_pred = top_5_predictions.sort_values(['userID'], ascending = True)
final_5_pred.reset_index(inplace=True)
del final_5_pred['index']
del final_5_pred['timestamp']





#############UPSERTING DATA INTO COSMOS DB###################
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




#Data
df = final_5_pred.copy()

user_list = [a for a in set(df.userID)]


prediction_list = {}
for user in user_list:
    user_loc = top_5_predictions.loc[top_5_predictions['userID'] == user]
    result = user_loc.to_json(orient="records")
    parsed = json.loads(result)
    user_prediction_list = json.dumps(parsed)
    prediction_list['user_'+str(user)] = user_prediction_list


#Create a Database and a Container within it
from azure.cosmos import CosmosClient, PartitionKey, exceptions
client = CosmosClient(url, credential=key)
database_name = 'HDIdatabase'
database = client.get_database_client(database_name)
container_name = 'RecommendedProducts'

try:
    container = database.create_container(id=container_name, partition_key=PartitionKey(path="/userID"))
except exceptions.CosmosResourceExistsError:
    container = database.get_container_client(container_name)
except exceptions.CosmosHttpResponseError:
    raise

# Upsert the data to Cosmos DB
client = CosmosClient(url, credential=key)
database_name = 'HDIdatabase'
database = client.get_database_client(database_name)
container_name = 'RecommendedProducts'
container = database.get_container_client(container_name)
