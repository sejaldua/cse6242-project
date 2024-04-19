# FanGraphs uses JavaScript to load our target tables
# Use Requests-HTML or Selenium to render page correctly
from requests_html import HTMLSession
from bs4 import BeautifulSoup
import pandas as pd

def scrape_injury_report(season = 2024):
    url = f"https://www.fangraphs.com/roster-resource/injury-report?groupby=injury&timeframe=all&season={str(season)}"

    session = HTMLSession()
    page = session.get(url)
    # Requests-HTML (and Selenium) can be very slow
    # Downloads Chromium to home directory on first run
    page.html.render(timeout = 100)

    soup = BeautifulSoup(page.html.html, "html.parser")

    # Both "table-scroll" and "table-fixed" should work here
    tables = soup.find_all("div", class_ = "table-fixed")

    injury_report_df_list = pd.read_html(str(tables))
    injury_report_df = pd.concat(injury_report_df_list)

    return injury_report_df.reset_index(drop = True)

injury_data = pd.DataFrame()
for season in range(2019, 2024):
    injury_report_season = scrape_injury_report(season = 2024)
    injury_data = pd.concat([injury_data, injury_report_season], axis=0, ignore_index=True)
injury_data.to_csv('./injury_data.csv', index=False)