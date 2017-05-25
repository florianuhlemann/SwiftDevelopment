import Foundation
import Vapor


print("AlexaSwift v0.0.1 Server started...")
let squeue = DispatchQueue(label: "squeue.AlexaSwift")


// Init application for single-owner use.
if AlexaSwift.sharedInstance.email == nil, AlexaSwift.sharedInstance.password == nil {
    print("Please enter your eMail address: ", terminator: "")
    AlexaSwift.sharedInstance.email = readLine(strippingNewline: true)
    print("Please enter your password: ", terminator: "")
    AlexaSwift.sharedInstance.password = readLine(strippingNewline: true)
    print("Your eMail and password have been successfully set.")
} else {
	print("WARNING: eMail or password have already been set.")
}


// define Vapor webserver instance
let drop = Droplet()


// define REST interfaces for Alexa
drop.get("json") { request in
    if let myJson = AlexaSwift.sharedInstance.getJsonResponse(responseType: .batteryRequest) {
    	return myJson
    } else {
    	return "ERROR"
	}
}


// initiate server
drop.run()


//squeue.async { print(AlexaSwift.sharedInstance.getBatteryStatus!) }