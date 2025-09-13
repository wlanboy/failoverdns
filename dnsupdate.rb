require 'json'
domain = ARGV[0]
ip = ARGV[1]
id = ""
listResponse = `curl [parameters 1]`
puts listResponse

domains = JSON.parse(listResponse)
domains['response']['recs']['objs'].each do | domainrecord |
puts domainrecord
if (domain == domainrecord['name'])
id = domainrecord['rec_id']
break
end
end

updateResponse = `curl [parameters 2]`
status = JSON.parse(updateResponse)
puts status

if status['result'] == 'success'
puts "update done"
else
puts "error during update of #{domain}"
end
