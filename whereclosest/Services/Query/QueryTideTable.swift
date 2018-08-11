//
//  QueryTideTable.swift
//  whereclosest
//
//  Created by John Matthew Weston on 7/15/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation

public class QueryTideTable : NSObject
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
        
        //SHORTCUT: should determine closest station, for now...
        
        let stationID = "941413"

        var query = "https://tidesandcurrents.noaa.gov/api/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=20180715&end_date=20180716&datum=MLLW&station=9414131&time_zone=lst_ldt&units=english&interval=hilo&format=json"

        session = URLSession.shared
        let url = URL(string: query)
        let task = session?.dataTask(with: url!){ data, response, error in
            
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
            
            // style #1
            guard let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Error: Problem decoding stream into JSON")
                return
            }
            print("DATA \(json)")
            
            // style #2
            if let data = data, let jsonString = String(data: data, encoding: String.Encoding.utf8), error == nil {
                print("DATA \(jsonString)")
            } else {
                print("error=\(error!.localizedDescription)")
            }
        }
        
        task?.resume()
    }
    
    /*
     { "predictions" : [
     {"t":"2018-07-11 04:10", "v":"-1.111", "type":"L"},{"t":"2018-07-11 10:43", "v":"4.320", "type":"H"},{"t":"2018-07-11 15:28", "v":"2.305", "type":"L"},{"t":"2018-07-11 21:39", "v":"6.869", "type":"H"},{"t":"2018-07-12 04:57", "v":"-1.499", "type":"L"},{"t":"2018-07-12 11:34", "v":"4.528", "type":"H"},{"t":"2018-07-12 16:21", "v":"2.301", "type":"L"},{"t":"2018-07-12 22:27", "v":"6.982", "type":"H"}
     ]}
     */
    
    // TODO: public func generateElementDescriptor( index: Int ) -> DataElementDescriptor {...}
    
}


public struct TideTableSequence : Codable
{
    public var tidePredicationSet = [ TidePrediction]()
    
    public init( )
    {
    }
    
    public init( predictions: [TidePrediction])
    {
        tidePredicationSet = predictions
    }
}

public struct TidePrediction : Codable {
    public var _t: String = String()
    public var _v: String = String()
    public var _type: String = String()
    
    public init( time: String, value: String, type: String )
    {
        _t = time
        _v = value
        _type = type
    }
}

