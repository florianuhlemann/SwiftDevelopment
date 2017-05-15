import Foundation

struct AlexaSwift {
    
    static var sharedInstance = AlexaSwift()
    
    let tokenUrl = URL(string: "https://owner-api.teslamotors.com/oauth/token")!
    let clientId = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384" // OWNERAPI_CLIENT_ID
    let clientSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3" // OWNERAPI_CLIENT_SECRET
    
    var email : String?
    var password : String?
    var accesstoken : String?
    var accesstokenExpiry : String?
    var vehicleID : Int?
    
    //var request = URLRequest(url: URL(string: usersDataPoint)!)
    //request.addValue("Token \(tokenString)", forHTTPHeaderField: "Authorization")
    
    
    var authorizationHeader : String? {
        get {
            if AlexaSwift.sharedInstance.accesstoken == nil {
                print("ERROR: No accesstoken has been set.")
                return nil
            } else {
                return "Authorization: Bearer \(AlexaSwift.sharedInstance.accesstoken!)"
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
    
    func getAccessToken() -> Void {
        var request = URLRequest(url: AlexaSwift.sharedInstance.tokenUrl)
        let session = URLSession(configuration: .default)
        request.httpMethod = "POST"
        request.httpBody = AlexaSwift.sharedInstance.tokenAuthorization!.data(using: String.Encoding.utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            let myString = String(data: data, encoding: String.Encoding.utf8)
            print(myString!)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
}