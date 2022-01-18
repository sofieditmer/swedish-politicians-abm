# %%
import os
import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.preprocessing import LabelEncoder
from sklearn.decomposition import PCA

os.chdir('/Users/au582299/Desktop/dm/decision-making-tweak/politicians_sweden')

# %%
# load data
df = pd.io.stata.read_stata('dat/Opinion_Schumacher.dta')

# %%
# label encoder
le = LabelEncoder()

columns_to_encode = [
    'Satisfied_polls',
    'Change_policy_overall',
    'Change_economy',
    'Change_welfare',
    'Change_strategy'
    ]

for col in columns_to_encode: 
    df[col] = le.fit_transform(df[col])

df.to_csv('dat/df_label_encoded.csv', index=False)


# %%
change_desire_2D = PCA(n_components=2).fit_transform(
    df[[
        'Change_policy_overall',
        'Change_economy',
        'Change_welfare',
        'Change_strategy'
        ]]
    )

change_desire_1D = PCA(n_components=1).fit_transform(
    df[[
        'Change_policy_overall',
        'Change_economy',
        'Change_welfare',
        'Change_strategy'
        ]]
    )

df_pca = df.copy()
df_pca['change_X'] = change_desire_2D[:, 0]
df_pca['change_Y'] = change_desire_2D[:, 1]
df_pca['change_1D'] = change_desire_1D

# %%
# PCA(change_desire) colored by treatment
sns.scatterplot(
    x=df_pca['change_X'],
    y=df_pca['change_Y'],
    hue=df_pca['Treatment_polls']
)

# %%
# bullshit plot, says the same as the previous one
sns.lineplot(
    x=df_pca['Satisfied_polls'],
    y=df_pca['change_1D'],
    hue=df_pca['Treatment_polls']
)

# %%
sns.barplot(
    x=df['Satisfied_polls'],
    y=df['Change_policy_overall']
)


# %%
satisfaction_change = df[['Satisfied_polls', 'Change_policy_overall']]

satisfaction_change = satisfaction_change.pivot_table(
    index='Satisfied_polls',
    columns='Change_policy_overall',
    aggfunc=np.sum
)

# %%
