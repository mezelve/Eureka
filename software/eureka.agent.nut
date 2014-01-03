/*
Xively code by @electricimp
https://github.com/electricimp/reference/tree/master/webservices/xively
*/
Xively <- {};  // this makes a 'namespace'

class Xively.Client {
    ApiKey = null;
	triggers = [];

	constructor(apiKey) {
		this.ApiKey = apiKey;
	}
	
	/*****************************************
	 * method: PUT
	 * IN:
	 *   feed: a XivelyFeed we are pushing to
	 *   ApiKey: Your Xively API Key
	 * OUT:
	 *   HttpResponse object from Xively
	 *   200 and no body is success
	 *****************************************/
	function Put(feed){
		local url = "https://api.xively.com/v2/feeds/" + feed.FeedID + ".json";
		local headers = { "X-ApiKey" : ApiKey, "Content-Type":"application/json", "User-Agent" : "Xively-Imp-Lib/1.0" };
		local request = http.put(url, headers, feed.ToJson());

		return request.sendsync();
	}
	
	/*****************************************
	 * method: GET
	 * IN:
	 *   feed: a XivelyFeed we fulling from
	 *   ApiKey: Your Xively API Key
	 * OUT:
	 *   An updated XivelyFeed object on success
	 *   null on failure
	 *****************************************/
	function Get(feed){
		local url = "https://api.xively.com/v2/feeds/" + feed.FeedID + ".json";
		local headers = { "X-ApiKey" : ApiKey, "User-Agent" : "xively-Imp-Lib/1.0" };
		local request = http.get(url, headers);
		local response = request.sendsync();
		if(response.statuscode != 200) {
			server.log("error sending message: " + response.body);
			return null;
		}
	
		local channel = http.jsondecode(response.body);
		for (local i = 0; i < channel.datastreams.len(); i++)
		{
			for (local j = 0; j < feed.Channels.len(); j++)
			{
				if (channel.datastreams[i].id == feed.Channels[j].id)
				{
					feed.Channels[j].current_value = channel.datastreams[i].current_value;
					break;
				}
			}
		}
	
		return feed;
	}

}
    

class Xively.Feed{
    FeedID = null;
    Channels = null;
    
    constructor(feedID, channels)
    {
        this.FeedID = feedID;
        this.Channels = channels;
    }
    
    function GetFeedID() { return FeedID; }

    function ToJson()
    {
        local json = "{ \"datastreams\": [";
        for (local i = 0; i < this.Channels.len(); i++)
        {
            json += this.Channels[i].ToJson();
            if (i < this.Channels.len() - 1) json += ",";
        }
        json += "] }";
        return json;
    }
}

class Xively.Channel {
    id = null;
    current_value = null;
    
    constructor(_id)
    {
        this.id = _id;
    }
    
    function Set(value) { 
    	this.current_value = value; 
    }
    
    function Get() { 
    	return this.current_value; 
    }
    
    function ToJson() { 
    	return http.jsonencode({id = this.id, current_value = this.current_value }); 
    }
}

client <- Xively.Client("YOUR_API_KEY");
eurekaChannel <- Xively.Channel("eureka_counter");
feed <- Xively.Feed("FEED_ID", [eurekaChannel]);
client.Get(feed);
local eurekaCount = eurekaChannel.Get();
server.log("eurekaCount: "+eurekaCount);

/*
Twitter code by @electricimp
https://github.com/electricimp/reference/tree/master/webservices/twitter
*/

helper <- {
    function encode(str) {
        return http.urlencode({ s = str }).slice(2);
    }
}
 
class TwitterClient {
    consumerKey = null;
    consumerSecret = null;
    accessToken = null;
    accessSecret = null;
    
    baseUrl = "https://api.twitter.com/";
    
    constructor (_consumerKey, _consumerSecret, _accessToken, _accessSecret) {
        this.consumerKey = _consumerKey;
        this.consumerSecret = _consumerSecret;
        this.accessToken = _accessToken;
        this.accessSecret = _accessSecret;
    }
    
    function post_oauth1(postUrl, headers, post) {
        local time = time();
        local nonce = time;
 
        local parm_string = http.urlencode({ oauth_consumer_key = consumerKey });
        parm_string += "&" + http.urlencode({ oauth_nonce = nonce });
        parm_string += "&" + http.urlencode({ oauth_signature_method = "HMAC-SHA1" });
        parm_string += "&" + http.urlencode({ oauth_timestamp = time });
        parm_string += "&" + http.urlencode({ oauth_token = accessToken });
        parm_string += "&" + http.urlencode({ oauth_version = "1.0" });
        parm_string += "&" + http.urlencode({ status = post });
        
        local signature_string = "POST&" + helper.encode(postUrl) + "&" + helper.encode(parm_string)
        
        local key = format("%s&%s", helper.encode(consumerSecret), helper.encode(accessSecret));
        local sha1 = helper.encode(http.base64encode(http.hash.hmacsha1(signature_string, key)));
        
        local auth_header = "oauth_consumer_key=\""+consumerKey+"\", ";
        auth_header += "oauth_nonce=\""+nonce+"\", ";
        auth_header += "oauth_signature=\""+sha1+"\", ";
        auth_header += "oauth_signature_method=\""+"HMAC-SHA1"+"\", ";
        auth_header += "oauth_timestamp=\""+time+"\", ";
        auth_header += "oauth_token=\""+accessToken+"\", ";
        auth_header += "oauth_version=\"1.0\"";
        
        local headers = {
            "Authorization": "OAuth " + auth_header,
        };
        
        local response = http.post(postUrl + "?status=" + helper.encode(post), headers, "").sendsync();
        return response
    }
 
    function Tweet(_status) {
        local postUrl = baseUrl + "1.1/statuses/update.json";
        local headers = { };
        
        local response = post_oauth1(postUrl, headers, _status)
        if (response && response.statuscode != 200) {
            server.log("Error updating_status tweet. HTTP Status Code " + response.statuscode);
            server.log(response.body);
            return null;
        } else {
            server.log("Tweet Successful!");
        }
    }
}
//
_CONSUMER_KEY <- "YourConsumerKey" 
_CONSUMER_SECRET <- "YourConsumerSecret"
_ACCESS_TOKEN <- "YourAccessToken"
_ACCESS_SECRET <- "YourAccessSecret"
twitter <- TwitterClient(_CONSUMER_KEY, _CONSUMER_SECRET, _ACCESS_TOKEN, _ACCESS_SECRET);

local tweets = array(11);
tweets[0] = "Hell yeah, I had an awesome idea!";
tweets[1] = "Having a great idea. Again.";
tweets[2] = "One idea I'll never forget.";
tweets[3] = "Ideas don't grow on trees. But in my brain.";
tweets[4] = "Eureka! Let's remember this moment.";
tweets[5] = "It's all about the idea.";
tweets[6] = "Who owns an idea? I do.";
tweets[7] = "Here's another one!";
tweets[8] = "I'm on a roll.";
tweets[9] = "This is a good one.";
tweets[10] = "An idea I might keep to myself ...";

function random(min,max) {
    return min+((max-min+1)*(1.0*math.rand()/RAND_MAX)).tointeger();
}
function chargeBattery(data){
    twitter.Tweet("@YOUR_TWITTER_HANDLE please recharge my battery ASAP. "+data);
}
function sendTweet(data){
    local ran = random(0,10);
    server.log("sendTweet: "+tweets[ran]+" Time: "+data);
    twitter.Tweet(tweets[ran]+" Time: "+data);
    //
    eurekaCount = eurekaCount.tointeger() + 1;
    eurekaChannel.Set(eurekaCount);
    client.Put(feed);
}
device.on("eureka",sendTweet);
device.on("batLow",chargeBattery);
