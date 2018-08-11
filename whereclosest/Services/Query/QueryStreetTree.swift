//
//  QueryStreetTree.swift
//  whereclosest
//
//  Created by John Matthew Weston on 7/15/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation

// https://dev.socrata.com/consumers/getting-started.html
// Aaccess token registration: http://dev.socrata.com/register

// Street Tree list
// https://dev.socrata.com/foundry/data.sfgov.org/2zah-tuvt

public class QueryStreetTree
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
    
    public func generateElementDescriptor( index: Int ) -> DataElementDescriptor
    {
        let item = data[index]
        
        //Diagnostic ---> for (key,value) in item { print( "KEY '\(key)' VALUE '\(value)' ") }
        
        //location is a cartesian - latitude, longitude
        let address = item["qaddress"]! as! String
        let siteinfo = item["qsiteinfo"]! as! String
        let species = item["qspecies"]! as! String
        var elementDescriptor = "\(address), \(siteinfo), \(species)"
    
        var descriptor = DataElementDescriptor( Summary: address, Detail: elementDescriptor)
        
        return descriptor
    }
    /*
     KEY 'ycoord' VALUE '2118403.70426'
     KEY ':@computed_region_yftq_j783' VALUE '13'
     KEY 'treeid' VALUE '131214'
     KEY 'qaddress' VALUE '* Green St'
     KEY ':@computed_region_rxqg_mtj9' VALUE '1'
     KEY 'dbh' VALUE '11'
     KEY ':@computed_region_p5aj_wyqh' VALUE '9'
     KEY 'latitude' VALUE '37.7969908368189'
     KEY 'qcaretaker' VALUE 'Private'
     KEY 'location' VALUE '{
     coordinates =     (
     "-122.428231397978",
     "37.796990836819"
     );
     type = Point;
     }'
     KEY 'planttype' VALUE 'Tree'
     KEY 'qsiteinfo' VALUE 'Sidewalk: Curb side : Cutout'
     KEY ':@computed_region_bh8s_q3mv' VALUE '57'
     KEY 'qlegalstatus' VALUE 'DPW Maintained'
     KEY 'plotsize' VALUE 'Width 4ft'
     KEY 'siteorder' VALUE '1'
     KEY 'qspecies' VALUE 'Melaleuca quinquenervia :: Cajeput'
     KEY 'xcoord' VALUE '6004570.89315'
     KEY 'longitude' VALUE '-122.428231397978'
     KEY ':@computed_region_fyvs_ahh9' VALUE '17'

     */
}
