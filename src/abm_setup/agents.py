# %%
import pandas as pd

# %%
###
### EXPERIMENT 1
###
'''
Party 
    poll_trend = [stable, increasing, decreasing]
    poll_magnitude = Normal(0, 1)
    radicalization = 0

Agents
    closeness = Normal(0.5, 0.1) * 5
    equal distribution of value functions across parties
    each value function represented with one closeness

Value functions
    0.25 prospect
    0.25 no loss aversion prospect
    0.25 linear
    0.25 no response
'''

parties = [1, 2, 3]
positive_trend_probability = [0.5, 0.7, 0.3]
poll_magnitude = [1, 1, 1]
radicalizations = [0.5, 0.5, 0.5]

value_functions = ['prospect', 'utility', 'linear', 'flat']

agent_settings = pd.DataFrame({
    'ideological_stance': [0.2, 0.4, 0.6, 0.8]
})



# %%
df_population = pd.DataFrame([])
for party, trend, magnitude, radicalization in zip(parties, positive_trend_probability, poll_magnitude, radicalizations):
    
    # get stances and value functions in
    agent_vs_function = pd.DataFrame([])
    for val_fun in value_functions:
        df = agent_settings.copy()
        df['value_function'] = val_fun
        agent_vs_function = agent_vs_function.append(df)
    
    agent_vs_function.reset_index()

    # get party settings in
    df_2 = agent_vs_function.copy()
    df_2['party'] = party
    df_2['positive_trend_probability'] = trend
    df_2['poll_magnitude'] = magnitude
    df_2['radicalization'] = radicalization

    df_population = df_population.append(df_2)

df_population = df_population.reset_index().drop(columns='index')


    




# %%
###
### EXPERIMENT 2
###
'''

'''