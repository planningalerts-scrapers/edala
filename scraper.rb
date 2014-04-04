require 'date'
require 'mechanize'

today = Date.today.strftime("%d+%b+%Y")
two_days_ago = (Date.today - 2).strftime("%d+%b+%Y")

# In a quick look there were roughly 20 applications over 3 days. For ease
# just scraping the first page of results which holds up to 40 applications.
# We scrape a little more than one day so we have a little room for scraper
# errors

url = "https://www.edala.sa.gov.au/edala/EDALAView.aspx?PageMode=ApplicationSearchResultsView&hdnCoAId=&SearchType=View&UseAdvancedSearch=1&dLodgedFrom=#{two_days_ago}&dLodgedTo=#{today}&SortBy=LodgementDate"

agent = Mechanize.new
page = agent.get(url)

ids = []

# TODO Scrape more than first page of results

# Get all the application ids on this page
ids += page.search("tr.content").map{|c| c.at("a").inner_text}

ids.each do |id|
  url = "https://www.edala.sa.gov.au/edala/EDALAView.aspx?PageMode=ApplicationDisplayView&ApplicationId=#{id}"
  page = agent.get(url)
  record = {
    council_reference: id,
    description: page.at("#referencesummary1_0").search("td.content")[2].inner_text,
    info_url: url,
    comment_url: url,
    date_received: Date.parse(page.at("#otherdetail1_0").search("td.content")[3].inner_text).to_s
  }
  # Nice spelling for the id!
  p = page.at("#propterydetail1_0").search("td.content")
  house_number = p[0].inner_text.strip
  lot_number = p[1].inner_text.strip
  street = p[3].inner_text.strip
  suburb = p[4].inner_text.strip
  if house_number
    first = "#{house_number} "
  elsif lot_number
    first = "Lot #{lot_number} "
  else
    first = ""
  end
  record[:address] = "#{first}#{street}, #{suburb}, SA"
  record[:date_received]
  record[:date_scraped] = Date.today.to_s
  p record
end
