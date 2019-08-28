'''
This file is to illustrate how to optimize run time in pandas.
Topics that are covered:
1. how to use loop in Pandas
2. how to use Pandas vectorized operations
3. how to use numpy vectorized operations

Other miner topics:
1. how to parse string dates to datetime dates
2. iterrows and itertuples
3. datetime data parsing
'''

import pandas as pd
import time
import sys
import numpy as np

# The timer function returns the average time that func needs to run n times

def timer(func):

    def wrapper(*args, **kwargs):
        t0 = time.time()
        for i in range(10):
            result = func(*args, **kwargs)
        t1 = time.time()
        t = (t1-t0)/10
        print(f'The average time for function {func.__name__} is {t}')
        return result

    return wrapper

electric = pd.read_csv('/Users/aaronpr_us/Documents/Academics/python/pandas/speedup_pd_s1/data/electricity.csv', header=0)
print(electric.head())

print(electric.date_time.dtype)

# As we can see, the data type for date_time column is object, sometimes we want to change object data type into datetime datatype

# @timer
# def convert(df, col_name):
#     # we can use df[col_name] to select a specific column
#     return pd.to_datetime(df[col_name])
#
# convert(electric, 'date_time')

# As you can see on average it takes 1 sec to do the conversion. It doesn't seem to bad, but as our data size increases, it will takes longer to do that. Can we do better?

@timer
def convert_with_format(df, col_name):
    return pd.to_datetime(df[col_name], format='%d/%m/%y %H:%M')

electric['date_time'] = convert_with_format(electric, 'date_time')

# After we specified the format, the average time is 0.03 second, which is more than 30 times faster. The reason is that without specifying the format, pandas will use the dateutil package to convert each string to a date. However, if you the format is given, pandas can immediately take a fast route to parse the dates. Note that we can also specify the format when we read the data with pandas, like read_csv

################################################################################

# Looping over pandas
# Now we are going to calculate the price for each time period. If the price is fix for different time period, say $0.28. We can easily do that by the following:

electric['cost'] = electric['energy_kwh'] * 0.28
print(electric.head())

# However, if we want to charge different price for different time period like the following:
###########################
# time range  # price/kwh #
###########################
# 17:00-24:00 #    28     #
###########################
# 07:00-17:00 #    20     #
###########################
# 00:00-07:00 #    12     #
###########################


def tariff(kwh, hour):
    if 0 <= hour < 7:
        p = 0.12
    elif 7 <= hour < 17:
        p = 0.2
    elif 17 <= hour < 24:
        p = 0.28
    else:
        raise ValueError(f'Invalid hour: {hour}')

    return p * kwh

# An intuitive way is to write a Loop

# @timer
# def apply_tariff(df):
#     cost = []
#     for i in range(len(df)):
#         energy_used = df.iloc[i]['energy_kwh']
#         time = df.iloc[i]['date_time'].hour
#         cost.append(tariff(energy_used, time))
#     df['cost'] = cost
#
# apply_tariff(electric)
# print(electric.head())

# As you can see, the average time for python loop to calculate the cost is 3.3 sec. There are three drawback with these method:
# 1. it needs to create an empty list
# 2. it needs to append to a list, and use the list to create a df
# 3. the biggest issue is the time cost of the calculation

# pd has two buildin loop that allows us to speed up if we really want to use a loop, df.itertuples() and df.iterrows()
# Note that df.iterrows() returns a tuple of a row, the first element is the index of the row; the second element is the pd.series of the corresponding data. Since it is a pd.series, we can use [col_name] or [col_index] to specify the column we want

# @timer
# def apply_tariff(df):
#     cost = []
#     for index, data in df.iterrows():
#         kwh = data['energy_kwh']
#         hour = data['date_time'].hour
#         cost.append(tariff(kwh, hour))
#     df['cost'] = cost
#
# apply_tariff(electric)

# By using iterrows(), it takes only 0.75 second to do the same thing, how about itertuples?

# @timer
# def apply_tariff(df):
#     cost = []
#     for row in df.itertuples():
#         kwh = row.energy_kwh
#         hour = (row.date_time).hour
#         cost.append(tariff(kwh, hour))
#     df['cost'] = cost
#
# apply_tariff(electric)
# print(electric.head())

# By using itertuples(), it takes only 0.05 second to finish the calculation, which is faster than 0.75 sec

# @timer
# def apply_tariff(df):
#     df['cost'] = df.apply(lambda row: tariff(row['energy_kwh'], row['date_time'].hour),axis=1)
#
# apply_tariff(electric)
# print(electric.head())

# It takes 0.25 sec to process, it is not as fast as itertuples, but still better than iterrows

# Can we do better? As we know the fundamental unit of Pandas are DataFrame and series, and both of them are based on arrays, instead of sequentially operating on an individual values(scalars), vectorized operations are the preferable & much fast ways to execute b/c array operations are fully optimized


# @timer
# def apply_tariff(df):
#     peak = df['date_time'].dt.hour.isin(range(17, 24))
#     shoulder = df['date_time'].dt.hour.isin(range(7, 17))
#     off_peak = df['date_time'].dt.hour.isin(range(0, 7))
#
#     df.loc[peak, 'cost'] = df.loc[peak, 'energy_kwh'] * 0.28
#     df.loc[shoulder, 'cost'] = df.loc[shoulder, 'energy_kwh'] * 0.2
#     df.loc[off_peak, 'cost'] = df.loc[off_peak, 'energy_kwh'] * 0.12
#
# apply_tariff(electric)

# By using verctorized operation, the average run time is 0.01 sec, which is the fastest method so faster. There is one drawback in this method. We are acutally manually type in every cases, but what if we have 24 different price range, we have to type in all 24 cases, which it horrible. Now we can try to use pd.cut() method to make things easier

# @timer
# def apply_tariff(df):
#     price = pd.cut(df['date_time'].dt.hour, bins= [0,7,17,24], labels = [0.12, 0.20, 0.28],include_lowest=True).astype(float)
#     df['cost'] = df['energy_kwh'] * price
#
# apply_tariff(electric)

# By using pd.cut(), we not only make the program more progammatic, but more efficient. It only takes 0.003 sec to process

# Since pandas are build on top of numpy, it adds some pandas functionality. If those functionality is not crucial, we can turn pandas dataframe/series into numpy array to maximize our speed

@timer
def apply_tariff(df):
    price = np.array([0.12, 0.20, 0.28])
    index = np.digitize(df['date_time'].dt.hour, [7, 17, 24], right=False)
    df['cost'] = df['energy_kwh'] * price[index]

apply_tariff(electric)

# By using verctorized numpy operation, it improve the run time from 0.003 to 0.001

"""
In conclusion:
---------------------------------
function                   time
---------------------------------
crappy loop                3.3s
---------------------------------
iterrows                   0.75s
---------------------------------
itertuples                 0.05s
---------------------------------
.apply                     0.25s
---------------------------------
chunk_vect ops             0.01s
---------------------------------
pd.cut                     0.003s
---------------------------------
np vect ops                0.001s
---------------------------------
"""
