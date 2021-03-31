from faker import Faker
import pandas as pd
import numpy as np

fake = Faker()
Faker.seed(0)
list_cust = []
for _ in range(4244):
    fake.simple_profile()
    list_cust.append(fake.simple_profile())

df_cust = pd.DataFrame(list_cust)

list_phone = []
for _ in range(4244):
    fake.phone_number()
    list_phone.append(fake.phone_number())



#True False

# Subscribed to the Newsletter
# Array for random sampling
sample_arr = [True, False]
# Create a numpy array with random True or False of size 10
subs_arr = np.random.choice(sample_arr, size=4244)


# Premiunm Account
sample_arr = [True, False]
# Create a numpy array with random True or False of size 10
prem_arr = np.random.choice(sample_arr, size=4244)

df_cust["Contact"] = list_phone
df_cust["Subscribed?"] = subs_arr
df_cust["Premium?"] = prem_arr
df_cust['CustomerID'] = df_cust.index

print(df_cust)

# df_cust.to_csv("customer.csv")