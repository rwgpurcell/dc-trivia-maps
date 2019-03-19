from requests import get
from requests.exceptions import RequestException
from contextlib import closing
from bs4 import BeautifulSoup
import pandas as pd
import re
import time

def simple_get(url):
    """
    Attempts to get the content at `url` by making an HTTP GET request.
    If the content-type of response is some kind of HTML/XML, return the
    text content, otherwise return None.
    """
    try:
        with closing(get(url, stream=True)) as resp:
            if is_good_response(resp):
                return resp.content
            else:
                return None

    except RequestException as e:
        log_error('Error during requests to {0} : {1}'.format(url, str(e)))
        return None


def is_good_response(resp):
    """
    Returns True if the response seems to be HTML, False otherwise.
    """
    content_type = resp.headers['Content-Type'].lower()
    return (resp.status_code == 200 
            and content_type is not None 
            and content_type.find('html') > -1)


def log_error(e):
    """
    It is always a good idea to log errors. 
    This function just prints them, but you can
    make it do anything.
    """
    print(e)

SITE = "http://www.district-trivia.com"

WHERE = "/where/is-trivia"

DAYS = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]


raw_html = simple_get(SITE+WHERE)
print(len(raw_html))

html = BeautifulSoup(raw_html, 'html.parser')
dcvenues = html.find_all("a",href=re.compile("^/venues/dc"))
mdvenues = html.find_all("a",href=re.compile("^/venues/maryland"))
vavenues = html.find_all("a",href=re.compile("^/venues/virginia"))

venues = dcvenues + mdvenues + vavenues

venues = [tag for tag in venues if tag.string!=None]
n = len(venues)
venueUrls = [tag.get('href') for tag in venues]

venueNames = [tag.string for tag in venues]
#print(venues[1].get('href'))
#print(venues[1].text)
print(len(venueNames))
print(venues[:5])
print(venueNames[:5])
print(venueUrls[:5])

venueTimes = [None]*n
venueDays = [None]*n
venueAddresses = [None]*n
i=0
for tag in venues:  
    raw_html = simple_get(SITE+tag.get('href'))
    #print(len(raw_html))
    html = BeautifulSoup(raw_html, 'html.parser')

    timeTag = html.find("h5")
    #print(timeTag.text)
    venueDays[i],venueTimes[i] = timeTag.text.split(" at ")
    table = html.find_all('div',attrs={"class":"four columns"})
    addressTag = table[-1].find('p')
    for br in addressTag.find_all("br"):
        br.replace_with("\n")

    venueAddresses[i] = addressTag.text
    #print(addressTag.text)
    i += 1
    time.sleep(1)
    print(i)
    #for x in table:
    #    print(x.find('p'))
    #    addressTag = x.find('p')
    #addressTags = html.descendants.find("p",string=re.compile("Washington, DC 2"))
    #print(addressTag.text)
    #print(addressTag.text)
    #print(timeTag.text)

venueData = pd.DataFrame(data={'Venue':venueNames,
    'Address':venueAddresses,'Day':venueDays,'Time':venueTimes, 'Host':'District Trivia'})

#SITE = 'https://triviakings.com/locations/'

#raw_html = simple_get(SITE)
#print(len(raw_html))

#html = BeautifulSoup(raw_html, 'html.parser')
#venueTable = html.find('table')

#dfs = pd.read_html(SITE)

#venueData2 = dfs[0]

#venueData2 = venueData2. 

#venueData2.to_csv('test.csv')

venueData.to_csv('trivia_venues.csv')