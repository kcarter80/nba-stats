require 'net/http'
require 'json'

def clean(variable)
  if variable.nil?
    return 0
  else
    return variable
  end
end


uri = 'http://stats.nba.com/stats/leaguedashplayershotlocations?College=&Conference=&Country=&DateFrom=&DateTo=&DistanceRange=By+Zone&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=Totals&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2015-16&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight='
url = URI.parse(uri)
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
data = JSON.parse(res.body)

massagedData = Array.new

data['resultSets']['rowSet'].each_with_index do |player,i|
  name = player[1]
  paintMakes = clean(player[5])+clean(player[8])
  paintAttempts = clean(player[6])+clean(player[9])
  paintPercent = paintMakes > 1 ? 100 * paintMakes.to_f / paintAttempts : nil

  midMakes = clean(player[11])
  midAttempts = clean(player[12])
  midPercent = midMakes > 1 ? 100 * midMakes.to_f / midAttempts : nil

  threeAttempts = clean(player[15])+clean(player[18])+clean(player[21])
  threeMakes = clean(player[14])+clean(player[17])+clean(player[20])
  threePercent = threeMakes > 1 ? 100 * threeMakes.to_f / threeAttempts : nil

  # (FG + 0.5 * 3P) / FGA
  if midAttempts > 0 || threeAttempts > 0
  	outsidePaintPercent = 100 * (midMakes + threeMakes).to_f / (midAttempts + threeAttempts) 
  	outsidePaintEPercent = 100 * (midMakes + threeMakes * 1.5).to_f / (midAttempts + threeAttempts) 
  else
  	outsidePaintPercent = nil
    outsidePaintEPercent = nil
  end

  massagedData.push([
  	name,
  	paintMakes,
  	paintAttempts,
  	paintPercent,
  	midMakes,
  	midAttempts,
  	midPercent,
  	threeMakes,
  	threeAttempts,
  	threePercent,
  	outsidePaintPercent,
  	outsidePaintEPercent
  ])
end

massagedData.reject! { |player| player[5] + player[8] < 250 }

massagedData.sort! { |x,y| x[10] <=> y[10] }