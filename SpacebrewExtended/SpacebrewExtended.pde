final String server = "localhost";
final String clientName = "FOO_RHAZ";
final String clientDescription = "Lorum Ipsum";


WsClient wsc; 
Spacebrew sb;

void setup() {
  try {
    wsc = new WsClient( this, ("ws://" + server + ":9000") );
    wsc.connect();
  } 
  catch (Exception e) {
    println("error connecting to the websocket server" + e);
  }

  jsonAdmin = new JSONObject();
  jsonAdmin.setBoolean("admin", true);
  jsonAdmin.setBoolean("no_msgs", false);  
  println(jsonAdmin.toString());


  //sample config message...I hope that by sending this we will get some updates??
  /*
{"config":
   {"name":"RHAZES TEST"
   ,"description":"This is a simple example of using the admin mix-in."
   ,"publish":
   {"messages":
   [{"name":"buttonPress"
   ,"type":"boolean"
   ,"default":"false"}
   ,{"name":"newClient"
   ,"type":"string"
   ,"default":""}
   ]
   }
   ,"subscribe":
   {"messages":
   [{"name":"toggleBackground"
   ,"type":"boolean"}
   ]
   },
   "options":{}
   ,"remoteAddress":"127.0.0.1"
   },
   "targetType":
   "admin"
   }
   */



  //sb = new Spacebrew(this);
  //sb.addSubscribe("buttonPress", "boolean");
  //sb.connect(server, clientName, clientDescription);
  noLoop();
}

JSONObject jsonAdmin;


void onOpen() {
  println("we opened a connection");
  println("now attempting to send an admin message to register to receive config");
  println("messages\n\n...");

  // This is the only method that we have to add to the Spacebrew lib
  // currently you can't send an admin message

  wsc.send(jsonAdmin.toString());
}


void onMessage(String message) {
  JSONObject jsObj = null;
  JSONObject iterObj = null;  
  JSONArray jsArr = null;

  try {
    jsObj = parseJSONObject(message);
    //println(jsObj);
  } 
  catch (Exception e) {
    //println("[onMessage] - failed to parse JSON object. Trying to parse array");
    jsObj = null;
  }

  if (jsObj == null) {
    try {
      jsArr = parseJSONArray(message);
    } 
    catch (Exception e ) {
      //println("[onMessage] - failed to parse JSON Array.");
      jsArr = null;
    }
  }

  if (jsObj == null && jsArr == null ) {
    println("[onMessage] - ERROR Bad Message Format on message: \n " + message );
    return ;
  }

  if (jsObj != null ) {
    //println("[onMessage 111] - " + jsObj );
    parseMessageJSON(jsObj);
  } else if (jsArr != null ) {
    //println("[onMessage 222] - " + jsArr );
  }  

  //filterConfig
  if (jsArr != null) {
    for ( int i=0; i < jsArr.size(); i++) {
      iterObj = jsArr.getJSONObject(i);
      parseMessageJSON(iterObj);
    }
  }
}


void parseMessageJSON(JSONObject o) {
  JSONObject msg = o.getJSONObject("message");
  if(msg!= null) {
   parseMessage(msg); 
  }
  // try the message for the id
  //if (msgId == null ) {
  //  msg = o.getJSONObject("message");
  //  if (msg == null) {
  //    println("[parseMessageJSON] I don't know what this message is. Ignoring : " + o);
  //  } else {
  //    msgId = o.getString("name");
  //    msgType = o.getString("type");
  //    msgValue = o.getString("value");
  //  }
  //}

  //handle config
  JSONObject config = o.getJSONObject("config");
  if (config != null) {
    println("configuration for client: " + config.getString("name"));
    parseConfig(config);
    //see what we publish
  }
}

void parseMessage(JSONObject o) {
  println("[parseMessage] " + o);
  SpacebrewMessage sb = parseSpacebrewMessage(o);
  println(sb);
}

void parseConfig(JSONObject o) {
  JSONArray msgs = o.getJSONObject("publish").getJSONArray("messages");
  Channel c;
  if (msgs != null ) {
    for (int i=0; i < msgs.size(); i++) {
      c = parseChannel(msgs.getJSONObject(i));
      println("\t" + c);
    }
  }
}  


//for config messages we wabt to get the new players
JSONObject[] filterConfigMessages() {
  //if this is a config message the get the configuration for the player

  //player name is the playerId

  //do we already have info for the player??
  //if then update it

  //if this is a new player then we need to add its config information

  //config information is the data that it publishes -- custom??
  return null;
}