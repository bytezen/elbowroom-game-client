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
ArrayList<Sub> subscriptions, newSubscriptions;
ArrayList<JSONObject> routes, newRoutes;


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
}

void spacebrewConnect() { 
  //stuff we want to share

  // value = playerid
  //sb.addPublish("reset", "string", "");
  // value = playerid
  //sb.addPublish("youdied", "string", "");

  sb.connect(SB_SERVER, SB_NAME, SB_DESCRIPTION);
}

//void initSpacebrewPlayerChannel(Player p) {
//  String channelId = p.name;
//  sb.addSubscribe(channelId, "string");
//  //println("[subscriptionInitialized] - channel = " + p.name);
//  playerChannelMap.put(channelId, p);
//}


/*
 * subscription message
 */
void onStringMessage( String channel, String value) {
  println("[onStringMessage]" + channel + " " + value );
  println("\tcurrent playerChannelMap : " + playerChannelMap);
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

  //TODO: have handleUnknownMessage return boolean if handled
  // have the subscriptions and routes get added to a buffer
  // run through the buffer here and send all of the messages
  // 1 cumulative config subscribe message
  // 1 route message per client subscription
}

/*
 * This is a bit of a hack to workaround the fact that the server
 * does not send back JSON objecta all the time
 * specifically the config message when connecting as an admin
 * to a server with multiple channels will send a message as an 
 * Array not as an object
 *
 * This function will deduce if it is an Array or an object
 * If it is an array then it will process every member of the array
 */
void handleUnknownMessage(String message) {
  //println("\n\n[unknown message]\n " + message + "\n\n");
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
    //println("[handleUnknownMessageObject] identified configMessage:\n" + o);    
    if (handleConfigMessage(o)) {
      println("[handleUnknownMessageObject] config message");    
      //TODO: Instead of sending the subscription here let's add the subscription objects to a 
      // new subscription buffer. Then copy the contents of the buffer to the subscription list
      // and send out the subscription message
      sendSubscription();
      //establish a route
    }
    handled = true;
  } else if (handleRouteMessage(o)) {
    println("[handleUnknownMessageObject] route Message:");//\n ");// + o);    
    handled = true;
  } else if ( isRemoveMessage(o) ) {
    println("[handleUnknownMessageObject] remove Message");//:\n " + o);
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



void handleUnknownMessageArray(JSONArray arr) {
  //println("\n[handleUnknownMessageArray]\n" + arr );  
  JSONObject iterObj;
  boolean needToSendSubscription = false;

  for ( int i=0; i < arr.size(); i++) {
    iterObj = arr.getJSONObject(i);
    if ( isConfigMessage(iterObj) ) {
      //once it is set to true keep it true
      needToSendSubscription = handleConfigMessage(iterObj) || needToSendSubscription;
    } else if ( handleRouteMessage(iterObj) ) {
      continue;
    } else {
      println("[handleUnknownMessageArray] ignoring message: " + iterObj);
    }
  }

  if (needToSendSubscription) {
    sendSubscription();
    for ( JSONObject msg : routes ) {
      sb.send(msg.toString());
    }
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

/*
 * Grab configuration from player clients and create subscriptions,
 * and routes
 */
boolean handleConfigMessage(JSONObject jsObj) {

  Sub addedSubscription = null;

  //the configuration object
  /* {"config": {
   "subscribe": {"messages": []},
   "publish": {"messages": [{
   "default": "",
   "name": "player10",
   "type": "string"
   }]}
   */
  JSONObject config = jsObj.getJSONObject("config");

  //ignore configuration for ourselves, the game client
  if ( config.getString("name").equals(SB_NAME)) {
    //println("[handleConfigMessage] - ignore configuration for game client");
    return false;
  }

  //if we already have the player then ignore this config
  if ( clientPlayerMap.get(config.getString("name")) != null) {
    println("[handleConfigMessage] already have configuration for player: " + config.getString("name"));
    return false;
  }

  if (config.getString("name").toLowerCase().indexOf("player") == -1 ) {
    println("[handleConfigMessage] config message is not from a player client " + config);
    return false;
  }  

  //ignore config messages from us
  if ( ! config.getString("name").equals(SB_NAME) ) {
    Player p = new Player(config.getString("name"), int(random(0.5*width, 0.5* width)), 0.1*height, colorAPI.getColor());
    p.active = true;

    newPlayers.add(p);

    //subscribe to what they be publishing
    JSONArray arr = config.getJSONObject("publish").getJSONArray("messages");

    // this will be a message in the publish array from the client
    JSONObject msg;

    for (int i=0; i < arr.size(); i++) {
      //the name of the config object is the client name
      //the name of the message object is the name of the channel      
      msg = arr.getJSONObject(i);
      
      //map the name of this channel to the players name
      playerChannelMap.put(msg.getString("name"), p);
      //println("********\n" + config +"\n*********\n");
      //println("[handleConfigMessage] added players. New Player Channel Map = " + playerChannelMap);      

      addedSubscription = subscribeToStringChannel(config.getString("name"), msg.getString("name"), "default", config.getString("remoteAddress"));
      buildRoute( addedSubscription );
    }
    //println("\t addedSubscription = " + (addedSubscription != null));
    return addedSubscription != null;
  }

  return false;
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

      removeOldPlayer(p);
      //oldPlayers.add(p);

      //remove it from subscriptions to
      //println("[handleRemoveMessage]Checking subscriptions for player to remove " + idList);
      for (int i=subscriptions.size()-1; i >= 0; i--) {
        //println("\t...checking subscription: " + subscriptions.get(i));
        if (subscriptions.get(i).client().equals(p.name) ) {
          //println("\t\t....should be removing player from subscriptions");
          subscriptions.remove(i);
        }
      }
      removedClient = true;
    }
  }

  if (removedClient) {
    //println("[handleRemoveMessage] remove route " + oldPlayers + subscriptions);    
    //println("[handleRemoveMessage] removing client " + oldPlayers + subscriptions);
    sendSubscription();
  }
}


/*
 {
 "route": {
 "subscriber": {
 "clientName": "Snakeden Game Client",
 "name": "player15",
 "type": "string",
 "remoteAddress": "127.0.0.1"
 },
 "publisher": {
 "clientName": "PLAYER 15",
 "name": "player15",
 "type": "string",
 "remoteAddress": "127.0.0.1"
 },
 "type": "add" OR "remove"
 },
 "targetType": "admin"
 }
 */

//TODO: make this more generic by passing in Channel pub object
//this way we can use this method to construct routes that we want to publish
//as well.
void buildRoute(Channel sub) {
  JSONObject msg, route, subscriber;
  //routes.add(new Pub());

  subscriber = new JSONObject();
  subscriber.setString("clientName", SB_NAME );
  subscriber.setString("name", sub.channel());
  subscriber.setString("type", sub.type());
  subscriber.setString("remoteAddress", sub.ip());


  route = new JSONObject()
    .setJSONObject("subscriber", subscriber)
    .setJSONObject("publisher", sub.json())
    .setString("type", "add");

  msg = new JSONObject()          
    .setJSONObject("route", route)
    .setString("targetType", "admin");

  println("\n[buildRoute]\n " + msg);

  routes.add(msg);
}

boolean handleRouteMessage(JSONObject obj) {
  if ( obj.isNull("route")) {
    return false;
  }
  println("[handleRouteMessage] ");
  return true;
}


void makeRoute() {
}

/*
* @return true if this client is not already in the subscriptions; we will also
 * add the client to the subscription list.
 * Otherwise return false
 *
 */
Sub subscribeToStringChannel(String clientName, String name, String _default, String remoteAddress) {
  boolean addedSubscription = false;
  Sub sub = null;

  if ( ! subscribedTo(name) ) { 
    //JSONObject obj = new JSONObject()
    //  .setString("clientName", clientName)
    //  .setString("name", name)
    //  .setString("type", "string");
    println("[subscribeToStringChannel] subscribing to " + clientName + " " + name );
    sub = new Sub(clientName, name, "string", remoteAddress );
    subscriptions.add( sub );
    //addedSubscription = true;
  }

  return sub;
  /*
  if (addedSubscription) {
   println("[subscribeToStringChannel] " + subscriptions);  
   sendSubscription();
   }
   */
}

void sendSubscription() {
  JSONObject configObj, configMsg, subMsg, pubMsg;
  JSONArray msgs;

  //build objects for all subscriptions
  msgs = new JSONArray();
  int i = 0;
  for ( Sub s : subscriptions ) {
    msgs.setJSONObject(i, s.json());
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
  for ( Sub s : subscriptions ) {
    if (s.channel().equals(name)) {
      return true;
    }
  }
  return false;
}

class Route {
  JSONObject sub, pub;

  Route(JSONObject sub, JSONObject pub) {
    this.sub = new JSONObject();
    this.sub.setString("name", sub.getString("name"));
    this.sub.setString("type", sub.getString("type"));
    this.sub.setString("default", sub.getString("default"));

    this.pub = new JSONObject();
    this.pub.setString("name", pub.getString("name"));
    this.pub.setString("type", pub.getString("type"));
    this.pub.setString("default", pub.getString("default"));
  }

  boolean subEqual(JSONObject aSub) {
    return sub.getString("name").equals(aSub.getString("name"))
      && sub.getString("type").equals(aSub.getString("type"));
  }

  boolean pubEqual(JSONObject aPub) {
    return pub.getString("name").equals(aPub.getString("name"))
      && pub.getString("type").equals(aPub.getString("type"));
  }
}



interface Channel {
  String client();
  String channel();
  String type();
  String ip();
  JSONObject json();
}

class Sub implements Channel {
  JSONObject _obj;

  Sub(String client, String channel, String type, String remoteAddress) {
    _obj = new JSONObject()
      .setString("clientName", client)
      .setString("name", channel)
      .setString("type", type)
      .setString("remoteAddress", remoteAddress);
  }

  String client() { 
    return _obj.getString("clientName");
  }
  String channel() { 
    return _obj.getString("name");
  }
  String type() { 
    return _obj.getString("type");
  }
  String ip() {
    return _obj.getString("remoteAddress");
  }

  JSONObject json() {
    return _obj;
  }
}

/*
class Pub implements Channel {
 JSONObject _obj;
 
 Pub(String client, String channel, String type, String remoteAddress) {
 _obj = new JSONObject()
 .setString("clientName", client)
 .setString("name", channel)
 .setString("type", type)
 .setString("remoteAddress", remoteAddress);
 }
 
 String client() { 
 return _obj.getString("clientName");
 }
 String channel() { 
 return _obj.getString("name");
 }
 String type() { 
 return _obj.getString("type");
 }
 
 JSONObject json() {
 return _obj;
 }
 }
 */