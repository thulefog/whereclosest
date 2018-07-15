//
//  QueryDataset.swift
//  whereclosest
//
//  Created by John Matthew Weston on 6/26/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation
import UIKit

// Register for access tokens here: http://dev.socrata.com/register

// https://dev.socrata.com/consumers/getting-started.html

// Pit Stop
// https://dev.socrata.com/foundry/data.sfgov.org/snkr-6jdf
// https://data.sfgov.org/resource/snkr-6jdf.json

// Street Tree list
// https://dev.socrata.com/foundry/data.sfgov.org/2zah-tuvt

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
    
}

public class QueryDatasetStreetTree
{
    var session: SODAClient
    public var data: [[String: Any]]! = []
    
    public init( )
    {
        session = SODAClient(domain: "data.sfgov.org", token: "vqcAOkEyVt8wTqGMbzRqv58yR")
    }
    public func execute()
    {
        let cngQuery = session.query(dataset: "2zah-tuvt")
        
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
    
}
