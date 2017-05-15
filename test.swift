import Foundation

struct AlexaSwift {

	static var sharedInstance = AlexaSwift()
	
	let tokenUrl = "https://owner-api.teslamotors.com/oauth/token"
	let clientId = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384" // OWNERAPI_CLIENT_ID
	let clientSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3" // OWNERAPI_CLIENT_SECRET
	
	var email : String?
	var password : String?
	var accesstoken : String?
	var accesstokenExpiry : String?
	var vehicleID : Int?
	
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
	
	func getJsonFromUrl(myUrlString: String, header : String) -> String? {
	    if let myUrl = URL(string: myUrlString) {
	        // request content from URL
	        let request = URLRequest(url: url)
	        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
	            guard error == nil else {
	                return
	            }
	            guard let data = data else {
	                return
	            }
	            do {
	                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
	                    print(json)
	                }
	            } catch let error {
	                print(error.localizedDescription)
	            }
	        })
	        task.resume()
	        return "{ 'name' : 'myName', 'id' : 374 }"
	    } else { return nil }
	}
	
	func postJsonToUrl(myUrlString : String, json : String) -> String {
	    return "{ 'name' : 'myName', 'id' : 374 }"
	}

}