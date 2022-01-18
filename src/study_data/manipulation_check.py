# %%
import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# %%
os.chdir('/Users/au582299/Desktop/dm/decision-making-tweak/politicians_sweden')

df = pd.read_csv('dat/data_recoded.csv')

# %%
sns.barplot(
    x=df['Treatment_polls'],
    y=df['n.months']
)

# %%
sns.barplot(
    x=df['Satisfied_polls'],
    y=df['n.months']
)


# %%
# gender effect
sns.barplot(
    x=df['sex'],
    y=df['Change_policy_overall']
)
