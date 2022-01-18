# %%
import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

os.chdir('/Users/au582299/Desktop/dm/decision-making-tweak/politicians_sweden')

df = pd.read_csv('dat/data_recoded.csv')
fig_outdir = 'fig/exploratory'

###
### Satisfied polls 
###
# %%
f = sns.barplot(
    x=df['sex'],
    y=df['Satisfied_polls'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'sex_satisfied.png'))


# %%
f = sns.barplot(
    x=df['edu'],
    y=df['Satisfied_polls'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'edu_satisfied.png'))


# %%
plt.figure(figsize=(15, 8))
f = sns.barplot(
    x=df['party_combined'],
    y=df['Satisfied_polls'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'party_satisfied.png'))


# %%
###
### Change overall
###
f = sns.barplot(
    x=df['sex'],
    y=df['Change_policy_overall'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'sex_change.png'))


# %%
f = sns.barplot(
    x=df['edu'],
    y=df['Change_policy_overall'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'edu_change.png'))


# %%
plt.figure(figsize=(15, 8))
f = sns.barplot(
    x=df['party_combined'],
    y=df['Change_policy_overall'],
    hue=df['Treatment_polls']
)

f.get_figure().savefig(os.path.join(fig_outdir, 'party_change.png'))


# %%
# party close
sns.distplot(
    x=df['party_close_rec']
)

# %%
sns.barplot(
    x=df['party_close_h14'].astype('str')
)
# %%
df['party_close_str'] = df['party_close_h14'].astype(str)
df.groupby('party_close_str')['party_close_str'].value_counts()

# %%
plt.figure(figsize=(15, 8))
f = sns.violinplot(
    x=df['party_close_str'],
    y=df['Satisfied_polls'],
    hue=df['Treatment_polls'],
    order=["1.0", "2.0", "3.0", "4.0", "nan"]
)

# %%
