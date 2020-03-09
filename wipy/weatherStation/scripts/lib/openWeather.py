from microWebCli import MicroWebCli  # https://github.com/jczic/MicroWebCli
import json
from ucollections import namedtuple

API_KEY = "4ff3b1c9e4fb7364d145a08eec7b2aca"
API_URL= "https://api.openweathermap.org/data/2.5/weather"

WeatherData = namedtuple("WeatherData", ("temp"))

def load_current(city_id):
    jdata = json.loads(
        MicroWebCli.GETRequest(
            API_URL,
            {
                "id": city_id,
                "units": "metric",
                "appid": API_KEY
            }))
    return WeatherData(jdata["main"]["temp"])
