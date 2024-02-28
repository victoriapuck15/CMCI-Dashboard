import matlab.engine
import pandas as pd
import data_trans

# Start MATLAB engine
eng = matlab.engine.start_matlab()

eng.cd('/Users/michaellicata/Documents/MATLAB/')

dateStrings, countries, data = eng.DFM2(nargout=3)

# Stop the MATLAB engine
eng.quit()

df_numeric = pd.DataFrame(data, columns=countries)
dates = pd.to_datetime(dateStrings)

df_numeric.insert(0, 'Dates', dates)

final = data_trans.merge_data(df_numeric)








