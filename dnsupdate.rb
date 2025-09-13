require 'json'
require 'date'

class NodePingResult
attr_accessor :ip, :isup, :numberOfBadResults

def to_s
"#{@ip} #{@isup} #{@numberOfBadResults}"
end
end

nodepingReports = []
nodepingIPs = []
nodePingResults = []

recordId = ""
ip = ""

#######################################################
#Please change you cloudflare and nodeping information
#######################################################
domain = 'mydomain'
cloudflaretoken='QWERTZUIOP'
cloudflarelogin='test@domain.com'
##################################
nodepingReports << 'https://nodeping.com/reports/results/[reportid]/50?format=json'
nodepingIPs << '127.0.0.1'
nodepingReports << 'https://nodeping.com/reports/results/[reportid]/50?format=json'
nodepingIPs << '127.0.0.1'
#######################################################

nodepingIPs = nodepingIPs.reverse

counter = 0
nodepingReports.reverse_each do | report |

res = NodePingResult.new
res.ip = nodepingIPs[counter]
res.numberOfBadResults = 0

reportResult = `curl #{report}`
results = JSON.parse(reportResult)
results.each do | result |
if ('Success' == result['m'])
res.isup = true
else
res.isup = false
res.numberOfBadResults += 1
end
end
counter += 1
nodePingResults << res
end

nodePingResults.sort! { |a,b| a.numberOfBadResults <=> b.numberOfBadResults }
nodePingResults.each do | newip |
if (newip.isup == true)
ip = newip.ip
break
end
end
puts "selected ip: #{ip}"

parameterDomainList = "-d 'tkn=#{cloudflaretoken}' -d 'email=#{cloudflarelogin}' -d 'z=#{domain}'"
listResponse = `curl https://www.cloudflare.com/api_json.html -d 'a=rec_load_all' #{parameterDomainList}`
#puts listResponse

domains = JSON.parse(listResponse)
domains['response']['recs']['objs'].each do | domainrecord |
puts domainrecord
if (domain == domainrecord['name'])
recordId = domainrecord['rec_id']
break
end
end
puts recordId

parameterDomainUpdate = "-d 'tkn=#{cloudflaretoken}' -d 'id=#{recordId}' -d 'email=#{cloudflarelogin}' -d 'z=#{domain}' -d 'type=A' -d 'name=#{domain}' -d 'content=#{ip}' -d 'service_mode=1' -d 'ttl=1'"
updateResponse = `curl https://www.cloudflare.com/api_json.html -d 'a=rec_edit' #{parameterDomainUpdate}`
status = JSON.parse(updateResponse)
#puts status

if status['result'] == 'success'
puts "update done: #{domain} now pointing to #{ip}"
else
puts "error - check last response: #{status['msg']}"
end
