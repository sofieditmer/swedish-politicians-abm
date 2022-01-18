''' 
Append metadata to dataset

Variables
---------

party_leader_age
    age in 2016, when the data were collected

party_leader_sex

'''

# %%
import os
import pandas as pd

os.chdir('/Users/au582299/Desktop/dm/decision-making-tweak/politicians_sweden')

df = pd.read_csv('dat/data_recoded.csv')

# %%

party_leader_dat = [
    {
        'party': 'Center Party',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Christian Democrats',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Conservatives',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Green Party',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Left Party',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Liberal Party',
        'party_leader_name': '',
        'party_leader_age': '',
        'party_leader_sex': ''
    },
    {
        'party': 'Social Democrats',
        'party_leader_name': 'Kjell Stefan Löfven',
        'party_leader_age': 59,
        'party_leader_sex': 0
    },
    {
        'party': 'Sweden Democrats',
        'party_leader_name': 'Per Jimmie Åkesson',
        'party_leader_age': 37,
        'party_leader_sex': 0
    }
]