import altair as alt
import pandas as pd

df = pd.read_csv('data/wales-waiting-times.csv')
df = df[['Data', 'Category_Code', 'Date_Code', 'Measure_Code']]
df = df[df['Category_Code'] == 'All']
df = df[df['Measure_Code'] == 'Percentages']
df['Value'] = df.apply(lambda row: row.Data / 100.0, axis=1) # turn percentage into fraction between 0 and 1 since Altair will format it
df['Year'] = df.apply(lambda row: row.Date_Code.split('m')[0], axis=1)
df['Month'] = df.apply(lambda row: row.Date_Code.split('m')[1], axis=1)
df['Date'] = pd.to_datetime(df.Date_Code, format='%Ym%m')

chart = alt.Chart(df).mark_line().encode(
    alt.Y('Value', title=None, axis=alt.Axis(format='%')),
    alt.X('Date', title=None),
    tooltip=[
        alt.Tooltip(field='Date', type="temporal", format="%b %Y"),
        alt.Tooltip(field='Value', type="quantitative", format=".1%")
        ]
).properties(
    title={
        'text': 'Percentage of patients attending A&E in Wales who are seen within four hours',
        'subtitle': 'Data source: StatsWales'
    },
    width=500,
    height=500
)
chart.save('06-a-and-e-waiting-times-in-wales-interactive.html')

chart_by_year = alt.Chart(df).mark_line().encode(
    alt.Y('Value', title=None, axis=alt.Axis(format='%')),
    alt.X('Month'),
    color=alt.Color('Year', scale=alt.Scale(scheme='yellowgreenblue')),
    tooltip=['Date', 'Data']
).properties(
    title={
        'text': 'Percentage of patients attending A&E in Wales who are seen within four hours',
        'subtitle': 'Data source: StatsWales'
    },
    width=600,
    height=600
)
chart_by_year.save('06-a-and-e-waiting-times-in-wales-by-year-interactive.html')
