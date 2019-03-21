# Using Python requests and the Google Maps Geocoding API.
#
# References:
#
# * http://docs.python-requests.org/en/latest/
# * https://developers.google.com/maps/

import requests
import os
import pandas as pd
import time

GOOGLE_MAPS_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json'

params = {
    'address': '',
    'key':os.environ['GOOGLE_API_KEY'] # Don't keep your API key in your code
}

venues = pd.read_csv('trivia_venues.csv',index_col=0)
print(len(venues))

for i in range(len(venues)):
    params['address']=venues.loc[i,'Address']
    req = requests.get(GOOGLE_MAPS_API_URL, params=params)
    res = req.json()
    result = res['results'][0]
    lat = result['geometry']['location']['lat']
    lng = result['geometry']['location']['lng']
    venues.at[i,'lat']=lat
    venues.at[i,'lng']=lng
    print(i)
    time.sleep(1) if i%50==0 else 1

print(venues.loc[0:3,:])
venues.to_csv('trivia_venues_loc.csv')
