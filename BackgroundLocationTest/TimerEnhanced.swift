//
//  TimerEnhanced.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/12/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

class TimerEnhanced: Timer {
    fileprivate var _timer:Timer? 
    fileprivate var ti:TimeInterval?
    fileprivate var t:Any?
    fileprivate var s:Selector?
    fileprivate var ui:Any?
    fileprivate var rep:Bool?
    
    func start(interval ti: TimeInterval, target t: Any?, selector s: Selector, userInfo ui: Any?, repeats rep: Bool) {
        guard _timer == nil, let t = t else {
            return
        }
        
        _timer = Timer.scheduledTimer(timeInterval: ti, target: t, selector: s, userInfo: ui, repeats: rep)
        _timer?.fire()
        
        self.ti = ti
        self.t = t
        self.s = s
        self.ui = ui
        self.rep = rep
    }
    
    func restart() {
        guard let ti = ti, let t = t, let s = s, let ui = ui, let rep = rep else {
            return
        }
        
        stop()
        start(interval: ti, target: t, selector: s, userInfo: ui, repeats: rep)
    }
    
    func restartIfNotRunning()  {
        guard _timer == nil else {
            return
        }
        
        guard let ti = ti, let t = t, let s = s, let ui = ui, let rep = rep else {
            return
        }
        
        start(interval: ti, target: t, selector: s, userInfo: ui, repeats: rep)
    }
    
    func stop() {
        guard _timer != nil else {
            return
        }
        
        _timer?.invalidate()
        _timer = nil
    }
}
