//
//  PacketTunnelProvider.swift
//  SSPacketTunnel
//
//  Created by zhouzhiwei on 2018/12/17.
//Copyright © 2018 zzw. All rights reserved.
//

import NetworkExtension
import CocoaLumberjack

class PacketTunnelProvider: NEPacketTunnelProvider {
	var pendingStartCompletion: ((NSError?) -> Void)?
    var lastPath:NWPath?
    var proxyPort: Int!
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        
        // Debug
        DDLog.removeAllLoggers()
        DDLog.add(DDASLLogger.sharedInstance, with: DDLogLevel.info)
        
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else {
            NSLog("[ERROR] No ProtocolConfiguration Found")
            exit(EXIT_FAILURE)
        }
        
        let ss_adr = conf["ss_address"] as! String
        let ss_port = conf["ss_port"] as! Int
        let method = conf["ss_method"] as! String
        let password = conf["ss_password"] as!String
        
        //
        proxyPort =  9090
        let networkSettings = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "8.8.8.8")
        networkSettings.mtu = 1000
        
        // set up ipv4
        let ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
//        if enablePacketProcessing {
//            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
//            ipv4Settings.excludedRoutes = [
//                NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
//                NEIPv4Route(destinationAddress: "100.64.0.0", subnetMask: "255.192.0.0"),
//                NEIPv4Route(destinationAddress: "127.0.0.0", subnetMask: "255.0.0.0"),
//                NEIPv4Route(destinationAddress: "169.254.0.0", subnetMask: "255.255.0.0"),
//                NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
//                NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
//                NEIPv4Route(destinationAddress: "17.0.0.0", subnetMask: "255.0.0.0"),
//            ]
//        }
        networkSettings.ipv4Settings = ipv4Settings
        let proxySettings = NEProxySettings()
        //        proxySettings.autoProxyConfigurationEnabled = true
        //        proxySettings.proxyAutoConfigurationJavaScript = "function FindProxyForURL(url, host) {return \"SOCKS 127.0.0.1:\(proxyPort)\";}"
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.excludeSimpleHostnames = true
        // This will match all domains
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = ["api.smoot.apple.com","configuration.apple.com","xp.apple.com","smp-device-content.apple.com","guzzoni.apple.com","captive.apple.com","*.ess.apple.com","*.push.apple.com","*.push-apple.com.akadns.net"]
        networkSettings.proxySettings = proxySettings
        
        // the 198.18.0.0/15 is reserved for benchmark.
//        if enablePacketProcessing {
//            let DNSSettings = NEDNSSettings(servers: ["198.18.0.1"])
//            DNSSettings.matchDomains = [""]
//            DNSSettings.matchDomainsNoSearch = false
//            networkSettings.dnsSettings = DNSSettings
//        }
        
        setTunnelNetworkSettings(networkSettings) { (error:Error?) in
            guard error == nil else {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
//        setTunnelNetworkSettings(networkSettings) {
//            error in
//            guard error == nil else {
//                DDLogError("Encountered an error setting up the network: \(error.debugDescription)")
//                completionHandler(error)
//                return
//            }
//
//            if (!self.started) {
//                self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: "127.0.0.1"), port: NEKit.Port(port: UInt16(self.proxyPort)))
//                try! self.proxyServer.start()
//                self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
//            } else {
//                self.proxyServer.stop()
//                try! self.proxyServer.start()
//            }
            
//            completionHandler(nil)
        
            
//            if (self.enablePacketProcessing) {
//                if (self.started) {
//                    self.interface.stop()
//                }
//
//                self.interface = TUNInterface(packetFlow: self.packetFlow)
//
//
//                let fakeIPPool = try! IPPool(range: IPRange(startIP: IPAddress(fromString: "198.18.1.1")!, endIP: IPAddress(fromString: "198.18.255.255")!))
//
//
//                let dnsServer = DNSServer(address: IPAddress(fromString: "198.18.0.1")!, port: NEKit.Port(port: 53), fakeIPPool: fakeIPPool)
//                let resolver = UDPDNSResolver(address: IPAddress(fromString: "114.114.114.114")!, port: NEKit.Port(port: 53))
//                dnsServer.registerResolver(resolver)
//                self.interface.register(stack: dnsServer)
//
//                DNSServer.currentServer = dnsServer
//
//                let udpStack = UDPDirectStack()
//                self.interface.register(stack: udpStack)
//                let tcpStack = TCPStack.stack
//                tcpStack.proxyServer = self.proxyServer
//                self.interface.register(stack:tcpStack)
//                self.interface.start()
//            }
//            self.started = true
            
//        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "defaultPath") {
            if self.defaultPath?.status == .satisfied && self.defaultPath != self.lastPath {
                if (self.lastPath == nil) {
                    self.lastPath = self.defaultPath
                } else {
                    NSLog("received network change notifcation")
                    let xSeconds = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + xSeconds) {
                        self.startTunnel(options: nil){ _ in }
                    }
                }
            } else {
                self.lastPath = defaultPath
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }

	override func wake() {
		
	}
}
