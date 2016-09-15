import Foundation
import Firebase

struct Users {
    
    var meetAmount:             Int!
    
    var status:                 String!
    var taken:                  String!
    var email:                  String!
    var name:                   String!
    var gender:                 String!
    var year:                   String!
    var firstMajor:             String!
    var firstMinor:             String!
    var secondMajor:             String!
    var secondMinor:             String!
    var urlOne:                 String!
    var urlTwo:                 String!
    var latitude:               String!
    var longitude:              String!
    var destinationLatitude:    String!
    var destinationLongitude:   String!
    var matchKey:               String!
    var releaseDate:               Int!
    
    var otherUserID:                    String!
    var otherUserName:                  String!
    var otherUserFirstMajor:            String!
    var otherUserUrlOne:                String!
    var otherUserUrlTwo:                String!
    var otherUserLatitude:              String!
    var otherUserLongitude:             String!
    
    var ref:                    FIRDatabaseReference?
  
    // Initialize from arbitrary data
    init(meetAmount: Int, status: String,                taken: String,              email: String,              name: String,
         gender: String,                year: String,               firstMajor: String, firstMinor: String, secondMajor: String, secondMinor: String,         urlOne: String,
         urlTwo: String,                latitude: String,           longitude: String,          destinationLatitude: String,
         destinationLongitude: String,  matchKey: String,           otherUserName: String,      otherUserFirstMajor: String, otherUserID: String,
         otherUserUrlOne: String,       otherUserUrlTwo: String,    otherUserLatitude: String,  otherUserLongitude: String, releaseDate: Int) {
            self.meetAmount                 = meetAmount
            self.status                     = status
            self.taken                      = taken
            self.email                      = email
            self.name                       = name
            self.gender                     = gender
        self.year                       = year
        self.firstMajor                 = firstMajor
        self.firstMinor                 = firstMinor
        self.secondMajor                 = secondMajor
        self.secondMinor                 = secondMinor
            self.urlOne                     = urlOne
            self.urlTwo                     = urlTwo
            self.latitude                   = latitude
            self.longitude                  = longitude
            self.destinationLatitude        = destinationLatitude
            self.destinationLongitude       = destinationLongitude
            self.matchKey                   = matchKey
            self.otherUserID                = otherUserID
            self.otherUserName              = otherUserName
            self.otherUserFirstMajor        = otherUserFirstMajor
            self.otherUserUrlOne            = otherUserUrlOne
            self.otherUserUrlTwo            = otherUserUrlTwo
        self.otherUserLatitude          = otherUserLatitude
        self.otherUserLongitude         = otherUserLongitude
        self.releaseDate         = releaseDate
            self.ref                        = nil
    }
  
    init(snapshot: FIRDataSnapshot) {
        meetAmount                      = snapshot.value!["meetAmount"] as! Int
        status                          = snapshot.value!["status"] as! String
        taken                           = snapshot.value!["taken"] as! String
        email                           = snapshot.value!["email"] as! String
        name                            = snapshot.value!["name"] as! String
        gender                          = snapshot.value!["gender"] as! String
        year                            = snapshot.value!["year"] as! String
        firstMajor                      = snapshot.value!["firstMajor"] as! String
        firstMinor                      = snapshot.value!["firstMinor"] as! String
        secondMajor                      = snapshot.value!["secondMajor"] as! String
        secondMinor                      = snapshot.value!["secondMinor"] as! String
        urlOne                          = snapshot.value!["urlOne"] as! String
        urlTwo                          = snapshot.value!["UrlTwo"] as! String
        latitude                        = snapshot.value!["latitude"] as! String
        longitude                       = snapshot.value!["longitude"] as! String
        destinationLatitude             = snapshot.value!["destinationLatitude"] as! String
        destinationLongitude            = snapshot.value!["destinationLongitude"] as! String
        matchKey                        = snapshot.value!["matchKey"] as! String
        
        otherUserID                   = snapshot.value!["otherUserID"] as! String
        otherUserName                   = snapshot.value!["otherUserName"] as! String
        otherUserFirstMajor             = snapshot.value!["otherUserFirstMajor"] as! String
        otherUserUrlOne                 = snapshot.value!["otherUserUrlOne"] as! String
        otherUserUrlTwo                 = snapshot.value!["otherUserUrlTwo"] as! String
        otherUserLatitude               = snapshot.value!["otherUserLatitude"] as! String
        otherUserLongitude              = snapshot.value!["otherUserLongitude"] as! String
        releaseDate                      = snapshot.value!["releaseDate"] as! Int
        ref                             = snapshot.ref
  }
  
    func toAnyObject() -> AnyObject {
        return [
            "meetAmount": meetAmount,
            "status": status,
            "taken": taken,
            "email": email,
            "name": name,
            "gender": gender,
            "year": year,
            "firstMajor": firstMajor,
            "firstMinor": firstMinor,
            "secondMajor": secondMajor,
            "secondMinor": secondMinor,
            "urlOne": urlOne,
            "urlTwo": urlTwo,
            "latitude": latitude,
            "longitude": longitude,
            "destinationLatitude": destinationLatitude,
            "destinationLongitude": destinationLongitude,
            "matchKey": matchKey,
            
            "otherUserID": otherUserID,
            "otherUserName": otherUserName,
            "otherUserFirstMajor": otherUserFirstMajor,
            "otherUserUrlOne": otherUserUrlOne,
            "otherUserUrlTwo": otherUserUrlTwo,
            "otherUserLatitude": otherUserLatitude,
            "otherUserLongitude": otherUserLongitude,
            "releaseDate": releaseDate
            ]
    }
}









