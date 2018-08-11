//
//  QueryTideStation
//  whereclosest
//
//  Created by John Matthew Weston on 7/27/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation


public class QueryTideStation : NSObject, XMLParserDelegate
{
    let PROSPECTIVE_DAY_IN_MILLISECONDS = 86400

    // https://tidesandcurrents.noaa.gov/api/
    // https://tidesandcurrents.noaa.gov/noaatidepredictions.html?id=9414131
    // https://tidesandcurrents.noaa.gov/stations.html
    // https://www.ndbc.noaa.gov/activestations.shtml
    
    public var data: [[String: Any]]! = []
    
    var response:URLResponse?
    var session:URLSession?
    
    public override init( )
    {
    }
    
    public func execute()
    {
        
        // TODO: parameterize
        //      - applicaiton
        //      - StationID (*)
        //      - begin_date
        //      - end_date
        //
        // (*) use proximity to look up "closest" station; may require addtional query for Station lat/long
        // https://www.ndbc.noaa.gov/activestations.shtml
        
        var dateFormat = "yyyyMMdd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = dateFormat
        
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let startDateEdge = calendar.startOfDay(for: date)
        let startDate = dateFormatter.string(from: startDateEdge )

        let timeInterval = TimeInterval( PROSPECTIVE_DAY_IN_MILLISECONDS )
        let endDateEdge = Date( timeInterval: timeInterval, since: startDateEdge  )
        let endDate = dateFormatter.string(from: endDateEdge )

        //NB: needed NSAppTransportSecurity + NSAllowsArbitraryLoads in plist for this
        let url = NSURL(string: "https://www.ndbc.noaa.gov/activestations.xml")
        
        let task = URLSession.shared.dataTask( with: url! as URL) { data, response, error in
            
            guard error == nil else {
                print("Error: Problem with URLSession dataTask")
                return
            }
            if let error = error {
                print("Error: Problem with URLSession dataTask")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error: Problem - server returned error code \(response)")
                    return
            }
            
            print( "DATA: \(data)" )

            let parser = XMLParser(data: data!)
            parser.delegate = self
            parser.parse()
            
        }
        
        task.resume()
    }
    
    var stations = StationSequence()
    
    var stationSequenceKey = "stations"
    var stationElementKey = "station"
    var currentElementName: String = String()

    
    //MARK:- XML Delegate methods
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == stationSequenceKey {
            //print("START parsing element \(elementName)")
        }
        else if elementName == stationElementKey {
            //print( "START parsing element \(elementName)" )
            currentElementName = elementName
            
            let station = Station(id: attributeDict["id"]!,
                                  latitude: attributeDict["lat"]!,
                                  longitude: attributeDict["lon"]! )
            stations.stationSet.append(station)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in:NSCharacterSet.whitespacesAndNewlines)
        
        /* NOTE: Data in this format, so this delegate not hit.
         
         ...
        <stations created="2018-07-25T00:05:01UTC" count="1372">
        <!--Site Elevation (elev attribute), when present, is reported in meters above mean sea level.-->
        <station id="00922" lat="30" lon="-90" name="OTN201 - 4800922" owner="Dalhousie University" pgm="IOOS Partners" type="other" met="n" currents="n" waterquality="n" dart="n"/>
         ...
         
         If data was formatted as below, this approach would be in play:
           <station>
             <id>...</id>
             <lat>...</lat>
              ...
           </sttation>
         
         if (!data.isEmpty) {
           if( currentElementName == "id" ) {
             var stationIdValue += data
           } else if currentElementName == "lat" {
             var stationLatitudeValue += data
           } else if currentElementName == "long" {
             var stationLongitudeValue += data
           }
         }
        
        */

    }
    
    func parser(parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == stationElementKey {
            
            ///print( "END parsing element \(elementName)" )
            
            // NOTE: see comment above about the found character delegate
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // TODO: check elementName
        ///print( "END parsing element \(elementName)" )
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
        
            print( "END parserDidEndDocument" )
        }
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("ERROR: parseErrorOccurred: \(parseError)")
    }
    
    // TODO: public func generateElementDescriptor( index: Int ) -> DataElementDescriptor {...}
    
}

public struct StationSequence : Codable
{
    public var stationSet = [ Station]()
    
    public init( )
    {
    }
    
    public init( stations: [Station])
    {
        stationSet = stations
    }
}

public struct Station : Codable {
    public var _id: String = String()
    public var _latitude: String = String()
    public var _longitude: String = String()
    
    public init( id: String, latitude: String, longitude: String )
    {
        _id = id
        _latitude = latitude
        _longitude = longitude
    }
}

