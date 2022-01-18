# %%
import os
import numpy as np
import pandas as pd

from scipy.stats import zscore
from scipy.stats import pearsonr, spearmanr


import seaborn as sns
import matplotlib.pyplot as plt

from value_functions import value_function, probability_weighting, prospect

os.chdir('/Users/au582299/Desktop/dm/decision-making-tweak/politicians_sweden')
df = pd.read_csv('dat/data_recoded.csv')
# df_reference = pd.read_csv('dat/df_label_encoded.csv')
df_reference = pd.io.stata.read_stata('dat/Opinion_Schumacher.dta')

# %%
# plt settings
scale = 1.8

rc = {"text.usetex": False,
    "font.family": "Times New Roman",
    "font.serif": "serif",
    "mathtext.fontset": "cm",
    "axes.unicode_minus": False,
    "axes.labelsize": 9*scale,
    "xtick.labelsize": 9*scale,
    "ytick.labelsize": 9*scale,
    "legend.fontsize": 9*scale,
    'axes.titlesize': 14,
    "axes.linewidth": 1
    }

plt.rcParams.update(rc)

sns.set_theme(
    style="ticks",
    # font='Times New Roman'
    rc=rc
    )

# %%
# replace variables to make more sense
df['Satisfied_polls'] = df['Satisfied_polls'].replace({
    1: 5,
    2: 4,
    3: 3,
    4: 2,
    5: 1
})

# party_close_h14 doesn't need recoding
# 1 = very close, 4 = not close at all


df['Change_policy_overall'] = df['Change_policy_overall'].replace({
    2: 0, #no changes at all
    1: 1, #change in a few areas
    0: 2 # change in many areas
})

df['Change_economy'] = df['Change_economy'].replace({
    3: 0, #no change
    2: 1, #somewhat to the left
    4: 1, #somewhat to the right
    1: 2, #much more to the left
    5: 2 # much more the right
})

df['Change_welfare'] = df['Change_welfare'].replace({
    3: 0, #no change
    2: 1, #somewhat to the left
    4: 1, #somewhat to the right
    1: 2, #much more to the left
    5: 2 # much more the right
})

df['Change_strategy'] = df['Change_strategy'].replace({
    1: 0, #not at all
    2: 1, #to a very small extent
    3: 2, #to some extent
    4: 3, #to a rather large extent
    5: 4, #To a very large extent 
})

# recode closness
df['party_close_h14'] = df['party_close_h14'].replace({
    1: 1, #very close
    2: 2, #fairly close
    3: 3, #not very close
    4: 3, #not close at all 
})

# %%
###
### check 1: observed satisfaction follows prospect theory's value funciton
###

df_nona = df.dropna(subset=['Satisfied_polls', 'gain.dif'])

gains_total = df_nona['gain.dif.tot'].tolist()
gains_prop = df_nona['gain.dif'].tolist()
real_sat = df_nona['Satisfied_polls'].tolist()
treatment = df_nona['Treatment_polls'].tolist()

assert len(gains_total) == len(real_sat) == len(gains_prop)

pred_sat_gtotal = [value_function(val) for val in gains_total]
pred_sat_gprop = [value_function(val) for val in gains_prop]

# zscale
z_real_sat = zscore(real_sat)
z_pred_sat_gtotal = zscore(pred_sat_gtotal)
z_pred_sat_gprop = zscore(pred_sat_gprop)

# correlation = they correlate
# proportional gains correlate better than total gains
print('\n'.join([
    "pearson",
    str(pearsonr(z_real_sat, z_pred_sat_gtotal)),
    str(pearsonr(z_real_sat, z_pred_sat_gprop)),
    "spearman",
    str(spearmanr(z_real_sat, z_pred_sat_gtotal)),
    str(spearmanr(z_real_sat, z_pred_sat_gprop))
]))

# %%
# non-zscaled, non predicted
print('\n'.join([
    "pearson",
    str(pearsonr(real_sat, gains_total)),
    str(pearsonr(real_sat, gains_prop)),
    "spearman",
    str(spearmanr(real_sat, gains_total)),
    str(spearmanr(real_sat, gains_prop))
]))

# %%
# investigate just treatment
print('\n'.join([
    "pearson",
    str(pearsonr(real_sat, treatment)),
    "spearman",
    str(spearmanr(real_sat, treatment)),
]))

# %%
### is value_function(gain) a better predictor than gain?
### they correlate slightly more under pearson, exactly the same under spearman
z_gains_total = zscore(gains_total)
z_gains_prop = zscore(gains_prop)

print('\n'.join([
    "pearson",
    str(pearsonr(z_real_sat, z_gains_total)),
    str(pearsonr(z_real_sat, z_gains_prop)),
    "spearman",
    str(spearmanr(z_real_sat, z_gains_total)),
    str(spearmanr(z_real_sat, z_gains_prop))
]))



# %%
###
### check 2: radicalization is predicted by closeness to party
###

df_nan_close = df.dropna(subset=['party_close_h14', 'Change_strategy', 'Change_welfare', 'Change_economy'])
df_nan_close_2 = df.dropna(subset=['Change_policy_overall', 'party_close_h14', 'sex', 'age', 'edu', 'party_combined'])

# %%
a = pd.crosstab(index=df_reference['party_close_h14'], columns=df_reference['Change_policy_overall'])

# %%
plt.figure(figsize=(10, 6))
f = sns.violinplot(
    x=df['party_close_h14'],
    y=df['Change_policy_overall'],
    inner=None
)
plt.xlabel("Closeness to party", labelpad=15)
plt.ylabel("Desire to change overall policy", labelpad=15)
# plt.xticks(
#     ticks=[0, 1, 2, 3],
#     labels=['Very close', 'Fairly close', 'Not very close', 'Not close at all']
#     )
plt.xticks(
    ticks=[0, 1, 2],
    labels=['Very close', 'Fairly close', 'Not very close / Not close at all']
    )
plt.yticks(
    ticks=[0, 1, 2],
    labels=['No changes at all', 'Change policy in few areas', 'Change policy in many areas']
    )

f = f.get_figure()
f.savefig('fig/closeness_radicalization_policy.png')


# %%
sns.violinplot(
    x=df_reference['party_close_h14'],
    y=df_reference['Change_economy']
)

# %%
sns.violinplot(
    x=df['party_close_h14'],
    y=df['Change_welfare']
)

# %%
sns.violinplot(
    x=df['party_close_h14'],
    y=df['Change_strategy']
)

# %%
spearmanr(
    df_nan_close['party_close_h14'].tolist(),
    df_nan_close['Change_strategy'].tolist()
)


# %%
###
### check 3: radicalization is predicted by satisfaction
###



# %%
###
### check 4: radicalization is prospect-theory related to closenss to party + satisfaction
###

df_nan_prosp = df.dropna(subset=['gain.dif', 'party_close_h14', 'Change_strategy'])

probs = df_nan_prosp['party_close_h14'].tolist()
gains = df_nan_prosp['gain.dif'].tolist()

decision_weights = [prospect(gain=gain, prob=prob) for gain, prob in zip(gains, probs)]

spearmanr(
    decision_weights,
    df_nan_prosp['Change_strategy'].tolist()
)


# df['Change_policy_overall']

# df['Change_economy']

# df['Change_welfare']

# df['Change_strategy']

# df['party_close_h14']

# %%
# decision tree
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import classification_report

df_nonan = df.dropna(subset=['party_close_h14', 'Change_policy_overall'])

X = df_nonan['party_close_h14'].to_numpy().reshape(-1, 1)
y = df_nonan['Change_policy_overall'].to_numpy().reshape(-1, 1)

dt = DecisionTreeClassifier()
dt.fit(X, y)

y_pred = dt.predict(X)

print(
    classification_report(y, y_pred)
)


# %%
# PCA on 
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

df_nan_close = df.dropna(subset=['party_close_h14', 'Change_policy_overall', 'Change_strategy', 'Change_welfare', 'Change_economy'])

X = df_nan_close[['Change_policy_overall', 'Change_strategy', 'Change_welfare', 'Change_economy']].to_numpy()
X_z = StandardScaler().fit_transform(X)
X_1D = PCA(n_components=1).fit_transform(X_z)

# %%
sns.violinplot(
    x=df_nan_close['party_close_h14'],
    y=X_1D[:, 0]
)

# %%
