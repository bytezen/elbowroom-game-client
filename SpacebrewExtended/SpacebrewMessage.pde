

class SpacebrewMessage {
  // to-do: this is weird!
  public String name, type, _default;
  public int       intValue;
  public String    stringValue;
  public boolean   boolValue;
  
  public String toString() {
    return "[SpacebrewMessage] " + name + "; type: " + type + "; intVal: " + intValue
             + "; stringVal: " + stringValue
              + "; boolVal: " + boolValue;
  }  
}

 class Channel {
  private String name;
  private String type;
  private String _default;
  private String remoteAddress;
  
  public String toString() {
    return "[channel] " + name + "; type: " + type + "; default: " + _default;
  }
}


Channel parseChannel(JSONObject o) {
  Channel c = new Channel();
  c.name = o.getString("name");
  c.type = o.getString("type");
  c.remoteAddress = o.getString("remoteAddress");
  c._default = o.getString("default");
  
  return c;
}


SpacebrewMessage parseSpacebrewMessage(JSONObject o) {
  SpacebrewMessage sb = new SpacebrewMessage();
  sb.name = o.getString("name");
  sb.type = o.getString("type");
  Boolean useDefault = o.isNull("value");

  if (sb.type.equals("string")) {
    if(useDefault) {
      sb.stringValue = sb._default;      
    } else {
      sb.stringValue = o.getString("value");
    }
  } else if (sb.type.equals("int")) {
    if (useDefault) {
      sb.intValue = int(sb._default);
    } else {
      sb.intValue = int(o.getString("value"));
    }
  } else if (sb.type.equals("boolean")) {
    if (useDefault) {
      sb.boolValue = boolean(sb._default);
    } else {
      sb.boolValue = boolean(o.getString("value"));
    }
  } else if (sb.type.equals("custom")) {
    //here we need a way to call specialized SpacebrewMessages
    if (useDefault)  {
      sb.stringValue = sb._default;
    } else {
      sb.stringValue = o.getString("value");
    }
  } else {
    println("[parseSpacebrewMessage] unknown message type: " + o);
  }
  return sb;
}

/* If there is one client
 {
 "config": {
 "name": "PLAYER 2",
 "description": "PLAYER2 client ",
 "subscribe": {
 "messages": []
 },
 "publish": {
 "messages": [{
 "name": "player2",
 "type": "string",
 "default": ""
 }]
 },
 "remoteAddress": "127.0.0.1"
 },
 "targetType": "admin"
 }
 */


/* if there is more than one client then we get back an array
 
 [{
 "config": {
 "name": "PLAYER 2",
 "description": "PLAYER2 client ",
 "subscribe": {
 "messages": []
 },
 "publish": {
 "messages": [{
 "name": "player2",
 "type": "string",
 "default": ""
 }]
 },
 "remoteAddress": "127.0.0.1"
 }
 }, 
 
 {
 "config": {
 "name": "PLAYER 1",
 "description": "PLAYER1 client ",
 "subscribe": {
 "messages": []
 },
 "publish": {
 "messages": [{
 "name": "player1",
 "type": "string",
 "default": ""
 }]
 },
 "remoteAddress": "127.0.0.1"
 }
 }]
 
 
 */

/* direction messages
 
 {
 "targetType": "admin",
 "message": {
 "clientName": "PLAYER 1",
 "name": "player1",
 "type": "string",
 "value": "jump",
 "remoteAddress": "127.0.0.1"
 }
 }
 */