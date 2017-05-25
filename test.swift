import Foundation

enum jsonResponseType {
    case batteryRequest
    case temperatureRequest
}

enum OutputSpeechType:String {
    case PlainText = "PlainText"
    case SSML = "SSML"
}

func getJsonResponse(responseType: jsonResponseType) -> String? {
    let outputSpeech : [String : Any] = [
        "type" : OutputSpeechType.PlainText.rawValue,
        "text" : "This is a sample text from AlexaSwift."
    ]
    //let card : [String : Any] = [:]
    let response = ["outputSpeech" : outputSpeech]//, "card" : card]
    let jsonDict = ["response" : response]
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        return String(data: jsonData, encoding: String.Encoding.utf8)
    } catch {
        print("ERROR: JSON could not be created for Alexa.")
    }
    return nil
}

if let jsonText = getJsonResponse(responseType: .batteryRequest) {
    print(jsonText)
}