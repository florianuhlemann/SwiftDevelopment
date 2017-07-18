import Foundation
import Vapor
import TLS
import HTTP


let config = try TLS.Config(
    mode: .server,
    certificates: .files(
        certificateFile: "/etc/letsencrypt/live/evjo.in/fullchain.pem", 
        privateKeyFile: "/etc/letsencrypt/live/evjo.in/privkey.pem", 
        signature: .selfSigned
    ),
    verifyHost: true,
    verifyCertificates: true
)


HTTP.defaultServerTimeout = 60*60


print("AlexaSwift v0.1.0 Server started...")


// Init application for single-owner use.
if AlexaSwift.sharedInstance.email == nil, AlexaSwift.sharedInstance.password == nil {
    print("Please enter your eMail address: ", terminator: "")
    AlexaSwift.sharedInstance.email = readLine(strippingNewline: true)
    print("Please enter your password: ", terminator: "")
    AlexaSwift.sharedInstance.password = readLine(strippingNewline: true)
    print("Please enter your Alexa UserID: ", terminator: "")
    AlexaSwift.sharedInstance.alexaUserId = readLine(strippingNewline: true)!
    print("Your eMail, password and user ID have been successfully set.")
} else {
    print("WARNING: eMail or password have already been set.")
}


// define Vapor webserver instance
let drop = Droplet()


// define API interface for JSON POST requests
drop.post("") { request in
    if let contentType = request.headers["Content-Type"], contentType.contains("application/json"), let bytes = request.body.bytes {
        let json = try JSON(bytes: bytes)
        if let myUserId = json["session"]?["user"]?["userId"]?.string {
            if myUserId == AlexaSwift.sharedInstance.alexaUserId {
                if let intentName = json["request"]?["intent"]?["name"]?.string {
                    guard let localeString = json["request"]?["locale"]?.string else { return AlexaSwift.sharedInstance.getJsonResponse(responseType: .unknownRequest, language: .enUS)! }
                    var language = AlexaSwift.ReponseLanguage.enUS
                    if localeString == "de-DE" { language = AlexaSwift.ReponseLanguage.deDE }
                    switch intentName {
                        case "GetBatteryState":
                            if let myJsonResponse = AlexaSwift.sharedInstance.getJsonResponse(responseType: .batteryRequest, language: language) {
                                return myJsonResponse
                            } else { return AlexaSwift.sharedInstance.getJsonResponse(responseType: .noData, language: language)! }
                        case "ActivateAC":
                            if let myJsonResponse = AlexaSwift.sharedInstance.getJsonResponse(responseType: .temperatureRequest, language: language) {
                                return myJsonResponse
                            } else { return AlexaSwift.sharedInstance.getJsonResponse(responseType: .noCommandResponse, language: language)! }
                        default:
                            return AlexaSwift.sharedInstance.getJsonResponse(responseType: .unknownRequest, language: language)!
                    }
                }
            }
        }
    }
    return ""
}

drop.get("") { request in
    return ""
}


// initiate server
drop.run(servers: [
    "secure": ("vapor.codes", 8888, .tls(config))
])