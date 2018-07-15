//
//  QueryDataset.swift
//  whereclosest
//
//  Created by John Matthew Weston on 6/26/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation
import UIKit

// https://dev.socrata.com/consumers/getting-started.html
// Access token registration: http://dev.socrata.com/register

// Pit Stop
// https://dev.socrata.com/foundry/data.sfgov.org/snkr-6jdf
// https://data.sfgov.org/resource/snkr-6jdf.json
  
public class QueryDatasetPitStop
{
    var session: SODAClient
    public var data: [[String: Any]]! = []
    
    public init( )
    {
        session = SODAClient(domain: "data.sfgov.org", token: "vqcAOkEyVt8wTqGMbzRqv58yR")
    }
    public func execute()
    {
        let cngQuery = session.query(dataset: "snkr-6jdf")

        cngQuery.get { res in
            switch res {
            case .dataset (let data):
                // Update our data
                self.data = data
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                print( errorMessage )
            }
        }
    }
    
    public func generateElementDescriptor( index: Int ) -> DataElementDescriptor
    {
        let item = data[index]
        
        //Diagnostic ---> for (key,value) in item { print( "KEY '\(key)' VALUE '\(value)' ") }
        
        let location = item["location"]! as! String
        let neighborhood = item["neighborhood"]! as! String
        let hoursofoperation = item["hoursofoperation"]! as! String
        var elementDescriptor = "\(neighborhood), \(location), \(hoursofoperation)"

        var descriptor = DataElementDescriptor( Summary: location, Detail: elementDescriptor)

        return descriptor
    }
}


