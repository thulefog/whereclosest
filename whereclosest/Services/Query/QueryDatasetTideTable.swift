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

    // https://tidesandcurrents.noaa.gov/api/
    // https://tidesandcurrents.noaa.gov/noaatidepredictions.html?id=9414131
    
    public var data: [[String: Any]]! = []
    
    public init( )
    {
    }
    
    public func execute()
    {
        
        //TODO: parameterize
        //      - applicaiton
        //      - StationID <--- use proximity to look up "closest" station; may require addtional query for Station lat/long
        //      - begin_date
        //      - end_date
        
        var query = "https://tidesandcurrents.noaa.gov/api/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=20180715&end_date=20180716&datum=MLLW&station=9414131&time_zone=lst_ldt&units=english&interval=hilo&format=json"
        
        //https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory?language=objc
        
        let url = URL(string: query)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error ) in
            
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
            
            guard let content = data else {
                print("Warning: Empty result set from query")
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Error: Problem decoding stream into JSON")
                return
            }

    }
    
    }
/*
    public func generateElementDescriptor( index: Int ) -> DataElementDescriptor
    {
        ...
     
    }
 */
}
