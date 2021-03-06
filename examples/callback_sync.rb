require "havenondemand"

$client = HODClient.new("YOUR_API_KEY", "v1")
$parser = HODResponseParser.new()

def syncCallback(response)
  response = $parser.parse_payload(response)
  if response != nil
    puts response
  else
    errors = $parser.get_last_errors()
    errors.each { |error|
      eCode = error["error"]
      if eCode == ErrorCode::QUEUED
        jobID = error["jobID"]
        $client.get_job_status(jobID, method(:syncCallback))
      elsif eCode == ErrorCode::IN_PROGRESS
        jobID = error["jobID"]
        $client.get_job_status(jobID, method(:syncCallback))
      else
        puts eCode
        puts error["detail"]
        puts error["reason"]
      end
    }
  end
end

# call Haven OnDemand APIs using synchronous mode
params = {}
params["url"] = "http://www.cnn.com"
params["entity_type"] = ['people_eng','places_eng']
hodApp = 'extractentities'
$client.post_request(hodApp, params, false, method(:syncCallback))
