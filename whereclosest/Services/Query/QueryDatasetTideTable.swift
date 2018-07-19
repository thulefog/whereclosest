//
//  QueryDatasetTideTable.swift
//  whereclosest
//
//  Created by John Matthew Weston on 7/15/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation

public class QueryDatasetTideTable
{
    let PROSPECTIVE_DAY_IN_MILLISECONDS = 86400

    // https://tidesandcurrents.noaa.gov/api/
    // https://tidesandcurrents.noaa.gov/noaatidepredictions.html?id=9414131
    
    public var data: [[String: Any]]! = []
    
    var response:URLResponse?
    var session:URLSession?
    
    public init( )
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
 
    // TODO: public func generateElementDescriptor( index: Int ) -> DataElementDescriptor {...}
    
}
