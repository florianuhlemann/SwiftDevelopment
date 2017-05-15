import Foundation
import Vapor

print("AlexaSwift v0.0.1 Server started...")

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
drop.get("hello") { request in
    return "Hello, world!"
}

drop.get("accesstoken") { request in
    
    return "test"
}

// initiate server
drop.run()