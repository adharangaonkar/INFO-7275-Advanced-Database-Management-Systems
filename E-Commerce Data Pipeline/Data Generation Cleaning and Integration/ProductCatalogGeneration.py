import pandas as pd

# data source : https://www.kaggle.com/PromptCloudHQ/toy-products-on-amazon

prod = pd.read_csv("amazon_co-ecommerce_sample.csv")

prod_imp = prod[['product_name', 'manufacturer', 'price', 'number_available_in_stock', 'average_review_rating',
                'sellers']]

prod_imp["product_id"] = prod_imp.index

print(prod_imp)

# prod_imp.to_csv("product_catalog.csv")