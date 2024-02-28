import pandas as pd
from sklearn.preprocessing import StandardScaler

# Step 1: Load the data

def transform_cci(): 
    cci_all = pd.read_csv('cci_all.csv')
    cci_all = cci_all.rename(columns={'TIME': 'Date'})

    # Convert 'Date' to datetime
    cci_all['Date'] = pd.to_datetime(cci_all['Date'])

    # Pivot the data so that each country becomes a column
    cci_pivot = cci_all.pivot(index='Date', columns='Country', values='CCI')

    # Convert all columns to numeric, coercing errors
    cci_pivot = cci_pivot.apply(pd.to_numeric, errors='coerce')

    # Resample each country's data to quarterly and calculate the mean
    cci_quarterly = cci_pivot.resample('Q').mean()

    # Optional: If you want to melt it back to long format
    cci_quarterly_melted = cci_quarterly.reset_index().melt(id_vars=['Date'], var_name='Country', value_name='CCI')

    # Adjusting for custom quarter-end dates
    custom_quarters = {1: '01-31', 2: '04-30', 3: '07-31', 4: '10-31'}
    cci_quarterly_melted['Date'] = cci_quarterly_melted['Date'].dt.to_period('Q').dt.to_timestamp('Q').apply(
        lambda x: pd.Timestamp(f"{x.year}-{custom_quarters[x.quarter]}")
    )

    # Display the first few rows of the transformed DataFrame
    scaler = StandardScaler()

    # Fit and transform the CCI column
    cci_quarterly_melted['CCI2'] = scaler.fit_transform(cci_quarterly_melted[['CCI']])

    del cci_quarterly_melted['CCI']

    return(cci_quarterly_melted)

def transform_hmci(hmci):
    # Convert the 'Date' column in HMCI data to datetime
    hmci['Dates'] = pd.to_datetime(hmci['Dates'])
    hmci = hmci.rename(columns={'Dates': 'Date'})
    return(hmci)

def merge_data(hmci_data):
    final_cci = transform_cci()
    final_hmci = transform_hmci(hmci_data)

    for country in final_hmci.columns[1:2]:  # Skip the 'Date' column
        # Pivot HMCI data so that each country becomes a column
        hmci_country = final_hmci[['Date', country]].dropna()  # Drop NA values
        hmci_country.columns = ['Date', 'HMCI']

        # Display the first few rows of the transformed DataFrame
        scaler = StandardScaler()

        # Fit and transform the CCI column
        hmci_country['HMCI2'] = scaler.fit_transform(hmci_country[['HMCI']])

        del hmci_country['HMCI']
        # Subset the CCI data for this country
        cci_country = final_cci[final_cci['Country'] == country].dropna()  # Drop NA values

        # Merge CCI and HMCI data for this country
        merged_data = pd.merge(cci_country, hmci_country, on='Date', how='inner')
    
    return merged_data

if __name__ == "__main__":
    merge_data()

