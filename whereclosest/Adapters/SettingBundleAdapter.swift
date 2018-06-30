//
//  SettingBundleAdapter.swift
//  whereclosest
//
//  Created by John Matthew Weston on 6/22/18.
//  Copyright © 2018 John Matthew Weston. All rights reserved.
//

import Foundation

public class SettingBundleAdapter
{
    func registerDefaultsFromSettingsBundle()
    {
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                NSLog("Key not fount")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
    
}
