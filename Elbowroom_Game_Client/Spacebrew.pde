import spacebrew.*;

//String SB_SERVER = "131.179.0.44";//"127.0.0.1";
String SB_SERVER = "localhost";
String SB_NAME = "Snakeden Game Client";
String SB_DESCRIPTION = "The main game console for Snakeden Players.";

Spacebrew sb;


//remoteIPAddress -> Clientname -> List ChannelName
HashMap<String, ArrayList<String>> channelMap;
HashMap<String, Player> clientPlayerMap;

//{name:String, client:String, type:String}
ArrayList<JSONObject> subscriptions;

void initSpacebrewConnection() {
  sb = new Spacebrew( this );

  //try {
  //  wsc = new WsClient( this, ("ws://" + SB_SERVER + ":9000") );
  //  wsc.connect();
  //} 
  //catch (Exception e) {
  //  println("error connecting to the websocket server" + e);
  //}


  //jsonAdmin = new JSONObject();
  //jsonAdmin.setBoolean("admin", true);
  //jsonAdmin.setBoolean("no_msgs", false);
}


void onSbOpen() {
  println("we got connected");
  JSONObject jsonAdmin = new JSONObject();
  jsonAdmin.setBoolean("admin", true);
  jsonAdmin.setBoolean("no_msgs", false);    

  sb.send(jsonAdmin.toString());
  //if (!sentAdmin) {
  //  try {
  //    wsc = new WsClient( this, ("ws://" + SB_SERVER + ":9000") );
  //    wsc.connect();
  //    sentAdmin = true;
  //  } 
  //  catch (Exception e) {
  //    println("error connecting to the websocket server" + e);
  //  }
  //}

  //if (sentAdmin && !adminConfigured) {
  //JSONObject jsonAdmin = new JSONObject();
  //jsonAdmin.setBoolean("admin", true);
  //jsonAdmin.setBoolean("no_msgs", false);    
  //wsc.send(jsonAdmin.toString());
  //}
}

void spacebrewConnect() { 
  //stuff we want to share

  // value = playerid
  //sb.addPublish("reset", "string", "");
  // value = playerid
  //sb.addPublish("youdied", "string", "");

  //to implement
  // value = playerid
  //sb.addPublish("youwon","string",""); 
  //value = playerid:placestring e.g player10:6/20
  //sb.addPublish("youplaced","string","");
  sb.connect(SB_SERVER, SB_NAME, SB_DESCRIPTION);
}

void initSpacebrewPlayerChannel(Player p) {
  String channelId = p.name;
  sb.addSubscribe(channelId, "string");
  //println("[subscriptionInitialized] - channel = " + p.name);
  playerChannelMap.put(channelId, p);
}


void onStringMessage( String channel, String value) {
  println("[onStringMessage]" + channel + " " + value );
  Player p = playerChannelMap.get(channel);

  //make sure we have a proper id
  if ( p == null ) {
    println("[ERROR: onStringMessage] unknown player: " + channel);
    return;
  }

  // -- value = hello messages

  if (value.equals("hello")) {
    p.active = true;
    return;
  }

  // -- value = goodbye messages

  if (value.equals("goodbye")) {
    p.active = false;
    return;
  }

  // -- value = jump messages

  if (value.equals("jump")) {
    p.jump();
    return;
  }



  // -- directions messages
  // values = {up,down,left,right,jump}
  //let's assume good data in for now
  if (value.equals("up") || value.equals("down") ||
    value.equals("left") || value.equals("right") ) {
    p.changeDirection(directionFromString(value));
  }
}

void onUnknownMessage(String message) {
  //println("captured the unknown message: " + message);
  handleUnknownMessage(message);
  //From SB-admin.js
  /*
  var handleMsg = function(json){
   if (json.config){
   handleConfigMsg(json);
   } else if (json.message){
   handleMessageMsg(json);
   } else if (json.route){
   handleRouteMsg(json);
   } else if (json.remove){
   handleRemoveMsg(json);
   } else if (json.admin){
   //do nothing
   } else {
   return false;
   }
   return true;
   };
   */
}

void handleUnknownMessage(String message) {
  //println("\n\n[unknown message] " + message + "\n\n");
  JSONObject jsObj = null;
  JSONObject iterObj = null;  
  JSONArray jsArr = null;

  try {
    jsObj = parseJSONObject(message);
  } 
  catch (Exception e) {
    jsObj = null;
  }

  if (jsObj == null) {
    try {
      jsArr = parseJSONArray(message);
    } 
    catch (Exception e ) {
      jsArr = null;
    }
  }

  if (jsObj == null && jsArr == null ) {
    println("[handleUnkownMessage] - Message is not an array or object. It might not be proper JSON. Try linting it: " + message);
    return ;
  }

  if (jsObj != null ) {
    handleUknownMessageObject(jsObj);
  } else if (jsArr != null ) {
    handleUnknownMessageArray(jsArr);
  }
}


void handleUknownMessageObject(JSONObject o) {
  boolean handled = false;

  if ( isConfigMessage(o) ) {
    //println("[handleUnknownMessageObject] identified configMessage: " + o);    
    handleConfigMessage(o);
    handled = true;
  } else if (handleRouteMessage(o)) {
    handled = true;
  } else if ( isRemoveMessage(o) ) {
    println("[handleUnknownMessageObject] identified removeMessage: " + o);
    handleRemoveMessage(o);   
    handled = true;
  } else if ( isAdminMessage(o) ) {
    //ignore these
    return;
  }

  if ( ! handled) {
    println("[handleUnknownMessage] no handler for JSON converted message: " + o );
  }
}


boolean isConfigMessage(JSONObject o) {
  //return isAdminMessage(o) && !o.isNull("config");
  return !o.isNull("config") ;
}

boolean isAdminMessage(JSONObject o) {
  return o.getString("targetType").equals("admin");
}

boolean isRemoveMessage(JSONObject o) {
  return isAdminMessage(o) && !o.isNull("remove");
}

void handleConfigMessage(JSONObject jsObj) {
  
  JSONObject obj = jsObj.getJSONObject("config");
  if ( obj.getString("name").equals(SB_NAME)) {
    //println("[handleConfigMessage] - ignore configuration for game client");
    return;
  }
  
  //if we already have the player then ignore this config
  if ( clientPlayerMap.get(obj.getString("name")) != null) {
    println("[handleConfigMessage] already have configuration for player: " + obj.getString("name"));
    return;    
  }

  if (obj.getString("name").toLowerCase().indexOf("player") == -1 ) {
    println("[handleConfigMessage] config message is not from a player client " + obj);
    return;
  }  

  //ignore config messages from us
  if ( ! obj.getString("name").equals(SB_NAME) ) {
    Player p = new Player(obj.getString("name"), int(random(0.5*width, 0.5* width)), 0.1*height, colorAPI.getColor());
    p.active = true;
    println("creating player for client: " + obj.getString("name") + " " + p);
    newPlayers.add(p);

    //subscribe to what they be publishing
    JSONArray arr = obj.getJSONObject("publish").getJSONArray("messages");
    JSONObject msg;

    for (int i=0; i < arr.size(); i++) {
      //name and type
      msg = arr.getJSONObject(i);
      subscribeToStringChannel(obj.getString("name"), msg.getString("name"), "default");
    }

    //return true;
  }

  /*
  ArrayList<String> channels;
   if ( ( channels  = channelMap.get(obj.getString("remoteAddress"))) != null ) {
   if (channels.indexOf(obj.getString("name")) == -1 ) {
   channels.add(obj.getString("name"));
   }
   } else {
   channels = new ArrayList();
   channels.add( obj.getString("name") );
   //println("...adding a client to the map : " + obj.getString()
   channelMap.put(obj.getString("remoteAddress"), channels);
   }
   
   println("[handleConfigMessage] channelMap updated: " + channelMap );
   
   */
  //index by remoteaddress
  //then index by name
  // value is channel
  //return false;
}

void handleRemoveMessage( JSONObject obj ) {
  JSONArray arr = obj.getJSONArray("remove");
  String[] ids = new String[arr.size()];
  boolean removedClient = false;

  for (int i=0; i < arr.size(); i++) {
    ids[i] = arr.getJSONObject(i).getString("name");
  }
  List<String> idList = Arrays.asList(ids);

  for (Player p : players ) {
    if (idList.indexOf(p.name) > -1) {

      oldPlayers.add(p);
      //remove it from subscriptions to
      for (int i=subscriptions.size()-1; i >= 0; i--) {
        if (subscriptions.get(i).getString("name").equals(p.name) ) {
          subscriptions.remove(i);
        }
      }
      removedClient = true;
    }
  }

  if (removedClient) {
    println("[handleRemoveMessage] removing client " + oldPlayers);
    sendSubscription();
  }
}

void handleUnknownMessageArray(JSONArray arr) {
  println("\n[handleUnknownMessageArray]\n" + arr );
  JSONObject iterObj;
  for ( int i=0; i < arr.size(); i++) {
    iterObj = arr.getJSONObject(i);
    if ( isConfigMessage(iterObj) ) {
      handleConfigMessage(iterObj);
      //continue;
    } else if ( handleRouteMessage(iterObj) ) {
      continue;
    } else {
      println("[handleUnknownMessageArray] ignoring message: " + iterObj);
    }
  }
}


boolean handleRouteMessage(JSONObject obj) {
  if ( obj.isNull("route")) {
    return false;
  }
  println("[handleRouteMessage] ");
  return true;
}

//void parseMessage(JSONObject o) {
//  println("[parseMessage] " + o);
//  SpacebrewMessage sb = parseSpacebrewMessage(o);
//  println(sb);
//}

//void parseConfig(JSONObject o) {
//  JSONArray msgs = o.getJSONObject("publish").getJSONArray("messages");
//  Channel c;
//  if (msgs != null ) {
//    for (int i=0; i < msgs.size(); i++) {
//      c = parseChannel(msgs.getJSONObject(i));
//      println("\t" + c);
//    }
//  }
//}  


void subscribeToStringChannel(String clientName, String name, String _default) {
  boolean addedSubscription = false;

  if ( ! subscribedTo(name) ) { 
    JSONObject obj = new JSONObject()
      .setString("clientName", clientName)
      .setString("name", name)
      .setString("type", "string");

    subscriptions.add(obj);
    addedSubscription = true;
  }

  if (addedSubscription) {
    println("[subscribeToStringChannel] " + subscriptions);  
    sendSubscription();
  }
}

void sendSubscription() {
  JSONObject configObj, configMsg, subMsg, pubMsg;
  JSONArray msgs;

  println("SEND SUB!!!!");

  //build objects for all subscriptions
  msgs = new JSONArray();
  int i = 0;
  for ( JSONObject o : subscriptions ) {
    msgs.setJSONObject(i, o);
    i++;
  }

  subMsg = new JSONObject().setJSONArray("messages", msgs);
  pubMsg = new JSONObject().setJSONArray("messages", new JSONArray());

  configObj = new JSONObject();
  configObj.setString("name", SB_NAME);
  configObj.setString("description", SB_DESCRIPTION);
  configObj.setJSONObject("subscribe", subMsg);
  configObj.setJSONObject("publish", pubMsg);
  configObj.setString("remoteAddress", "127.0.0.1");

  configMsg = new JSONObject();
  configMsg.setJSONObject("config", configObj);

  sb.send(configMsg.toString());
}



boolean subscribedTo(String name) {
  for ( JSONObject o : subscriptions ) {
    if (o.getString("name").equals(name)) {
      return true;
    }
  }
  return false;
}