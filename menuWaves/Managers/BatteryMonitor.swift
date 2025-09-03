//
//  BatteryMonitor.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit
import IOKit.ps

class BatteryMonitor {
    // Battery monitoring properties
    var isCharging: Bool = false
    var lastChargingState: Bool = false
    var chargingEffectProgress: CGFloat = 0
    var chargingEffectTimer: Timer?
    var batteryMonitorTimer: Timer?
    
    weak var delegate: BatteryMonitorDelegate?
    
    func setupBatteryMonitoring() {
        batteryMonitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkBatteryStatus()
        }
    }
    
    private func checkBatteryStatus() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "ps"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let newIsCharging = output.contains("AC Power")
                
                // Kiểm tra thay đổi trạng thái charging
                if newIsCharging != lastChargingState && newIsCharging {
                    startChargingEffect()
                }
                
                lastChargingState = newIsCharging
                isCharging = newIsCharging
            }
        } catch {
            print("Error checking battery status: \(error)")
        }
    }
    
    func startChargingEffect() {
        chargingEffectProgress = 0
        chargingEffectTimer?.invalidate()
        
        let startTime = CACurrentMediaTime()
        chargingEffectTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            guard let self = self else { 
                timer.invalidate()
                return 
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            
            if elapsed < 2.0 {
                // Sóng xanh chạy từ trái qua phải trong 2 giây
                self.chargingEffectProgress = CGFloat(elapsed / 2.0) // 0 -> 1
            } else {
                // Kết thúc hiệu ứng
                self.chargingEffectProgress = 0
                timer.invalidate()
                self.chargingEffectTimer = nil
            }
            
            self.delegate?.batteryChargingEffectDidUpdate()
        }
    }
    
    func cleanup() {
        batteryMonitorTimer?.invalidate()
        chargingEffectTimer?.invalidate()
        batteryMonitorTimer = nil
        chargingEffectTimer = nil
    }
}

protocol BatteryMonitorDelegate: AnyObject {
    func batteryChargingEffectDidUpdate()
}
