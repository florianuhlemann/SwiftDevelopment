import Foundation

struct AlexaSwift {
    
    static var sharedInstance = AlexaSwift()
    
    enum ApiError : Error {
        case generalError
        case jsonError
    }

    enum jsonResponseType {
        case batteryRequest
        case temperatureRequest
    }

    enum OutputSpeechType : String {
        case PlainText = "PlainText"
        case SSML = "SSML"
    }
    
    struct BatteryInformation {
        let lastUpdate : Int
        let percent : Int
        let rangeInKm : Int
        let rangeInMiles : Int
    }

    var myDateFormatter : DateFormatter {
        get {
            let mDF = DateFormatter()
            mDF.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return mDF
        }
    }

    // URLs for Tesla API including custom built URLs
    let tokenUrl = URL(string: "https://owner-api.teslamotors.com/oauth/token")!
    let vehicleUrl = URL(string: "https://owner-api.teslamotors.com/api/1/vehicles")!
    
    var chargestateUrl : URL? {
        get {
            if let myVehicleID = AlexaSwift.sharedInstance.getVehicleID {
                if let myUrl = URL(string: "https://owner-api.teslamotors.com/api/1/vehicles/\(myVehicleID)/data_request/charge_state") {
                    return myUrl
                } else { return nil }
            } else { return nil }
        }
    }
    
    let clientId = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384" // OWNERAPI_CLIENT_ID
    let clientSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3" // OWNERAPI_CLIENT_SECRET
    
    var email : String?
    var password : String?
    var accessToken : String?
    var accessTokenExpiry : Int?
    var accessTokenInUpdate : Bool = false
    var vehicleID : Int?
    var vehicleIDInUpdate : Bool = false
    var batteryStatus : BatteryInformation?
    var batteryStatusInUpdate : Bool = false
    
    var getAccessToken : String? {
        get {
            if let accessTokenExpiry = AlexaSwift.sharedInstance.accessTokenExpiry {
                if (accessTokenExpiry < AlexaSwift.sharedInstance.currentTimeStamp) {
                    if (!AlexaSwift.sharedInstance.accessTokenInUpdate) {
                        AlexaSwift.sharedInstance.renewAccessToken()
                    }
                } else { /* do nothing as accessToken is still valid */ }
            } else if (!AlexaSwift.sharedInstance.accessTokenInUpdate) {
                AlexaSwift.sharedInstance.renewAccessToken()
            }
            while (AlexaSwift.sharedInstance.accessTokenInUpdate) {
                //do nothing
            }
            return AlexaSwift.sharedInstance.accessToken
        }
    }
    
    var getVehicleID : Int? {
        get {
            if (AlexaSwift.sharedInstance.vehicleID == nil) {
                if (!AlexaSwift.sharedInstance.vehicleIDInUpdate) {
                    AlexaSwift.sharedInstance.renewVehicleID()
                }
            }
            while (AlexaSwift.sharedInstance.vehicleIDInUpdate) { /* do nothing */ }
            return AlexaSwift.sharedInstance.vehicleID
        }
    }
    
    var getBatteryStatus : BatteryInformation? {
        get {
            if let myStatus = AlexaSwift.sharedInstance.batteryStatus {
                if ((myStatus.lastUpdate + 300 ) < AlexaSwift.sharedInstance.currentTimeStamp) {
                    if (!AlexaSwift.sharedInstance.batteryStatusInUpdate) {
                        AlexaSwift.sharedInstance.renewBatteryStatus()
                    }
                }
            } else if (!AlexaSwift.sharedInstance.batteryStatusInUpdate) {
                AlexaSwift.sharedInstance.renewBatteryStatus()
            }
            while (AlexaSwift.sharedInstance.batteryStatusInUpdate) {
                //do nothing
            }
            return AlexaSwift.sharedInstance.batteryStatus
        }
    }
    
    var authorizationHeader : String? {
        get {
            if let myAccessToken = AlexaSwift.sharedInstance.getAccessToken {
                return "Bearer \(myAccessToken)"
            } else {
                return nil
            }
        }
    }
    
    var tokenAuthorization : String? {
        get {
            let dict = [
                "grant_type" : "password",
                "client_id" : AlexaSwift.sharedInstance.clientId,
                "client_secret" : AlexaSwift.sharedInstance.clientSecret,
                "email" : AlexaSwift.sharedInstance.email!,
                "password" : AlexaSwift.sharedInstance.password!
            ]
            let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let theJSONText = String(data: theJSONData!, encoding: String.Encoding.utf8)!
            return theJSONText
        }
    }
    
    var currentTimeStamp : Int {
        get {
            return Int(Date().timeIntervalSince1970.rounded())
        }
    }
    
    func renewAccessToken() -> Void {
        print("Starting new AccessTokenRequest at \(AlexaSwift.sharedInstance.myDateFormatter.string(from: Date()))")
        AlexaSwift.sharedInstance.accessTokenInUpdate = true
        var request = URLRequest(url: AlexaSwift.sharedInstance.tokenUrl)
        let session = URLSession(configuration: .default)
        request.httpMethod = "POST"
        request.httpBody = AlexaSwift.sharedInstance.tokenAuthorization!.data(using: String.Encoding.utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            //print(String(data: data, encoding: String.Encoding.utf8)!)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let access_token = json["access_token"]{
                        let expires_in = json["expires_in"]! as! Int
                        let created_at = json["created_at"] as! Int
                        AlexaSwift.sharedInstance.accessToken = (access_token as! String)
                        AlexaSwift.sharedInstance.accessTokenExpiry = created_at + expires_in - 86400
                        AlexaSwift.sharedInstance.accessTokenInUpdate = false
                        print("STATUS: AccessToken has been updated.")
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func renewVehicleID() -> Void {
        print("Starting new VehicleIDRequest at \(AlexaSwift.sharedInstance.myDateFormatter.string(from: Date()))")
        AlexaSwift.sharedInstance.vehicleIDInUpdate = true
        var request = URLRequest(url: AlexaSwift.sharedInstance.vehicleUrl)
        let session = URLSession(configuration: .default)
        request.httpMethod = "GET"
        request.setValue(AlexaSwift.sharedInstance.authorizationHeader!, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            //print(String(data: data, encoding: String.Encoding.utf8)!)
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { throw AlexaSwift.ApiError.jsonError }
                guard let array = json["response"] as? [Any] else { throw AlexaSwift.ApiError.jsonError }
                guard let newArry = array[0] as? [String: Any] else { throw AlexaSwift.ApiError.jsonError }
                guard let myVehicleID = newArry["id"] as? Int else { throw AlexaSwift.ApiError.jsonError }
                AlexaSwift.sharedInstance.vehicleID = myVehicleID
                AlexaSwift.sharedInstance.vehicleIDInUpdate = false
                print("STATUS: VehicleID has been updated.")
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func renewBatteryStatus() -> Void {
        print("Starting new BatteryRequest at \(AlexaSwift.sharedInstance.myDateFormatter.string(from: Date()))")
        AlexaSwift.sharedInstance.batteryStatusInUpdate = true
        if let myUrl = AlexaSwift.sharedInstance.chargestateUrl {
            var request = URLRequest(url: myUrl)
            let session = URLSession(configuration: .default)
            request.httpMethod = "GET"
            request.setValue(AlexaSwift.sharedInstance.authorizationHeader!, forHTTPHeaderField: "Authorization")
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil else { return }
                guard let data = data else { return }
                //print(String(data: data, encoding: String.Encoding.utf8)!)
                 do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { throw AlexaSwift.ApiError.jsonError }
                    guard let array = json["response"] as? [String: Any] else { throw AlexaSwift.ApiError.jsonError }
                    guard let ideal_battery_range = array["ideal_battery_range"] as? Double else { throw AlexaSwift.ApiError.jsonError }
                    guard let battery_level = array["battery_level"] as? Int else { throw AlexaSwift.ApiError.jsonError }
                    let rangeInMiles = Int(ideal_battery_range.rounded())
                    let rangeInKm = Int((ideal_battery_range * 1.609344).rounded())
                    let newBatteryStatus = AlexaSwift.BatteryInformation(lastUpdate: AlexaSwift.sharedInstance.currentTimeStamp, percent: battery_level, rangeInKm: rangeInKm, rangeInMiles: rangeInMiles)
                    AlexaSwift.sharedInstance.batteryStatus = newBatteryStatus
                    AlexaSwift.sharedInstance.batteryStatusInUpdate = false
                    print("STATUS: BatteryStatus has been updated.")
                 } catch let error {
                    print(error.localizedDescription)
                 }
            })
            task.resume()
        }
    }

    func getJsonResponse(responseType: AlexaSwift.jsonResponseType) -> String? {

        var outputSpeechText : String
            
        switch responseType {
            case .batteryRequest:
                if let batteryInfo = AlexaSwift.sharedInstance.getBatteryStatus {
                    outputSpeechText = "Your Tesla's battery has a remaining range of \(batteryInfo.rangeInKm) kilometers."
                } else {
                    outputSpeechText = "Your Tesla's battery information could not be requested."
                }
            case .temperatureRequest:
                outputSpeechText = "The outside air temperature is 19°C."
        }

        let outputSpeech = [
            "type" : OutputSpeechType.PlainText.rawValue,
            "text" : outputSpeechText
        ]
        let response = ["outputSpeech" : outputSpeech]
        let jsonDict = ["response" : response]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch {
            print("ERROR: JSON could not be created for Alexa.")
        }
        return nil
    }
    
}
