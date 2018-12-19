//
//  SockClient.swift
//  SSPacketTunnel
//
//  Created by zhouzhiwei on 2018/12/18.
//  Copyright © 2018 zzw. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import CocoaLumberjack


class SockClient: NSObject,GCDAsyncSocketDelegate {
    var localServer:GCDAsyncSocket?
    var delegateQueue:DispatchQueue?
    var RemoteAddress:String?
    var port:UInt16?
    
    
    init(host:String?,port:UInt16?) {
        self.RemoteAddress = host
        self.port = port
    }
    
    func acceptedLocalPort(interface:String?,port:UInt16,completionHandler: @escaping (Bool) -> Void){
        delegateQueue = DispatchQueue(label: "com.zzw.SSDemo")
        localServer = GCDAsyncSocket.init(delegate: self, delegateQueue: delegateQueue)
        do {
            try localServer?.accept(onInterface: interface, port: port)
        }catch{
            DDLogDebug("绑定端口失败！")
            completionHandler(false)
        }
        completionHandler(true)
    }
    
    // MARK:connect remote server
    func connectRemoteServer(<#parameters#>) -> <#return type#> {
        <#function body#>
    }
    
    // MARK:GCDAsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        DDLogDebug("Accept New Socket")
        newSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        DDLogDebug("Read Data：\(data)")
        sock.write(data, withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 1)
    }
    
    //
}
