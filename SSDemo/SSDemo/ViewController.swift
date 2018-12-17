//
//  ViewController.swift
//  SSDemo
//
//  Created by zhouzhiwei on 2018/12/17.
//  Copyright © 2018 zzw. All rights reserved.
//

import UIKit
import NetworkExtension
import CocoaLumberjack

class ViewController: UIViewController {
    
    var tunnelManager:NETunnelProviderManager?
    @IBOutlet weak var sw: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadVPN()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadVPN() {
        NETunnelProviderManager.loadAllFromPreferences { (manager:[NETunnelProviderManager]?, error:Error?) in
            if error == nil {
                if let m = manager {
                    if m.count > 0 {
                        self.tunnelManager = manager?.first
                        if m.count > 1 {
                            
                            for (_,value) in m.enumerated() {
                                value.removeFromPreferences(completionHandler: { (e2:Error?) in
                                    if e2 == nil {
                                        DDLogDebug("remove dumplicate VPN config successful!")
                                    }else{
                                        DDLogError("remove dumplicate VPN config failed with \(String(describing: e2?.localizedDescription))")
                                    }
                                })
                            }
                            
                        }
                    }
                }
                
                if self.tunnelManager == nil {
                    self.createVPN()
                    self.loadVPN()
                }
            }else{
                DDLogError("load VPN Preferences \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func createVPN() {
        tunnelManager = NETunnelProviderManager.init()
        let config = NETunnelProviderProtocol.init()
        config.serverAddress = "127.0.0.1"
        
        // set up providerConfiguration
        var providerConfiguration = [String:AnyObject]()
        providerConfiguration["ss_address"] = "140.82.50.80" as AnyObject
        providerConfiguration["ss_port"] = "8989" as AnyObject
        providerConfiguration["ss_method"] = "CHACHA20" as AnyObject
        providerConfiguration["ss_password"] = "zw1993" as AnyObject
        providerConfiguration["ymal_configutation"] = "" as AnyObject
        config.providerConfiguration = providerConfiguration
        
        tunnelManager?.protocolConfiguration = config
        tunnelManager?.localizedDescription = "SSDemo"
        tunnelManager?.isEnabled = true
    }
    
    func saveVPN() {
        tunnelManager?.saveToPreferences(completionHandler: { (error:Error?) in
            if error == nil {
                self.tunnelManager?.loadFromPreferences(completionHandler: { (error:Error?) in
                    if error == nil {
                        DDLogDebug("save VPN success")
                    }
                })
            }
        })
    }
    @IBAction func switchOnClick(_ sender: UISwitch) {
        if (VpnManager.shared.vpnStatus == .off) {
            VpnManager.shared.startVPN()
        } else {
            VpnManager.shared.stopVPN()
        }
    }
}

