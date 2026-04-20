import pandas as pd

df = pd.read_csv('C:/Portfolio Projects/Exercise Dataset/US_PER_CAPITA20.CSV')

year_cols = [col for col in df.columns if col.startswith('Y')]

df_melted = df.melt(
    id_vars=['State_Name', 'Item'],
    value_vars=year_cols,
    var_name='year',
    value_name='per_capita_spending'
)

df_melted = df_melted[df_melted['Item'] == 'Personal Health Care ($)']
df_melted = df_melted[df_melted['State_Name'].notna()]
df_melted['year'] = df_melted['year'].str.replace('Y', '')
df_melted = df_melted[df_melted['year'].between('2011', '2020')]

with open('C:/Portfolio Projects/Exercise Dataset/US_PER_CAPITA20_long.csv',
          'w', encoding='utf-8', newline='\n') as f:
    df_melted.to_csv(f, index=False)
