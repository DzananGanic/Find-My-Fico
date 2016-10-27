//
//  MQTTClient.swift
//  Find My Fico
//
//  Created by Dzanan Ganic on 11/10/2016.
//  Copyright © 2016 fica.io. All rights reserved.
//

import Foundation
import Moscapsule

class MyMQTTClient{
    var mqttConfig:MQTTConfig
    var mqttClient:MQTTClient?
    var updateMapCallback:((Float, Float)->Void)?
    
    init() {
        
        let path = Bundle.main.path(forResource: "MQTTCredentials", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        let clientId = dict!.object(forKey: "ClientId") as! String
        let url = dict!.object(forKey: "URL") as! String
        let port = dict!.object(forKey: "Port") as! NSNumber
        
        mqttConfig = MQTTConfig(clientId: clientId, host: url, port: port.int32Value, keepAlive: 60)
    }

    private func parseResponse(response:String) -> (Float, Float){
        if let dataFromString = response.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            let (lat, lng) = (Float(json["location"]["lat"].number!), Float(json["location"]["lng"].number!))
            return (lat,lng)
        }
        return (0.0,0.0)
    }
    
    public func connect(){
        mqttConfig.onMessageCallback = { mqttMessage in
            if let callback=self.updateMapCallback {
                let coordinates = self.parseResponse(response: mqttMessage.payloadString!);
                callback(coordinates.0, coordinates.1)
            }
        }
        mqttClient = MQTT.newConnection(mqttConfig)
    }
    
    public func subscribe(topic:String) -> Void {
        mqttClient?.subscribe(topic, qos: 2)
    }
    
    public func disconnect() -> Void {
        mqttClient?.disconnect()
    }
    
}
