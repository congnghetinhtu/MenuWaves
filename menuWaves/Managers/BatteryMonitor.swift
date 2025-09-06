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
    var isChargingEffectLooping: Bool = false
    var batteryMonitorTimer: Timer?
    
    // Random easing properties
    var currentEasingType: EasingType = .easeInOutCubic
    var currentDuration: TimeInterval = 2.0
    
    weak var delegate: BatteryMonitorDelegate?
    
    func setupBatteryMonitoring() {
        batteryMonitorTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkBatteryStatus()
        }
    }
    
    private func checkBatteryStatus() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "batt"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let newIsCharging = output.contains("AC Power")
                let isFullyCharged = output.contains("100%") && newIsCharging
                
                // Kiểm tra thay đổi trạng thái charging
                if newIsCharging != lastChargingState && newIsCharging {
                    startChargingEffect()
                }
                
                // Khi pin sạc đầy và đang sạc, chạy hiệu ứng lặp lại
                if isFullyCharged && !isChargingEffectLooping {
                    startChargingEffectLoop()
                } else if (!isFullyCharged || !newIsCharging) && isChargingEffectLooping {
                    stopChargingEffectLoop()
                }
                
                lastChargingState = newIsCharging
                isCharging = newIsCharging
            }
        } catch {
            print("Error checking battery status: \(error)")
        }
    }
    
    func startChargingEffect() {
        // Randomize easing for variety
        randomizeEasing()
        
        chargingEffectProgress = 0
        chargingEffectTimer?.invalidate()
        
        let startTime = CACurrentMediaTime()
        chargingEffectTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] timer in
            guard let self = self else { 
                timer.invalidate()
                return 
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            
            if elapsed < self.currentDuration {
                // Sóng xanh chạy từ trái qua phải với random easing và duration
                let linearProgress = CGFloat(elapsed / self.currentDuration) // 0 -> 1
                self.chargingEffectProgress = self.applyEasing(linearProgress)
            } else {
                // Kết thúc hiệu ứng với easing
                let fadeOutProgress = min(CGFloat((elapsed - self.currentDuration) / 0.5), 1.0) // Fade out trong 0.5 giây
                self.chargingEffectProgress = self.applyEasing(1.0 - fadeOutProgress)
                
                if fadeOutProgress >= 1.0 {
                    self.chargingEffectProgress = 0
                    timer.invalidate()
                    self.chargingEffectTimer = nil
                }
            }
            
            self.delegate?.batteryChargingEffectDidUpdate()
        }
    }
    
    func startChargingEffectLoop() {
        isChargingEffectLooping = true
        chargingEffectProgress = 0
        chargingEffectTimer?.invalidate()
        
        // Randomize initial easing
        randomizeEasing()
        
        var isInDelay = false
        var delayStartTime: TimeInterval = 0
        
        chargingEffectTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] timer in
            guard let self = self else { 
                timer.invalidate()
                return 
            }
            
            if isInDelay {
                // Đang trong thời gian delay 1 giây
                let delayElapsed = CACurrentMediaTime() - delayStartTime
                if delayElapsed >= 1.0 {
                    // Kết thúc delay, bắt đầu hiệu ứng mới với random easing
                    isInDelay = false
                    self.randomizeEasing() // Random easing for each cycle
                    self.chargingEffectProgress = 0.0
                } else {
                    // Vẫn trong delay, giữ progress = 0
                    self.chargingEffectProgress = 0.0
                }
            } else {
                // Đang chạy hiệu ứng với random easing
                self.chargingEffectProgress += 1.0/120.0 // Hoàn thành 1 chu kỳ trong 2 giây
                let easedProgress = self.applyEasing(min(self.chargingEffectProgress, 1.0))
                
                if self.chargingEffectProgress >= 1.0 {
                    // Hiệu ứng chạy xong, bắt đầu delay 1 giây
                    self.chargingEffectProgress = 1.0
                    isInDelay = true
                    delayStartTime = CACurrentMediaTime()
                }
            }
            
            self.delegate?.batteryChargingEffectDidUpdate()
            
        }
    }
    
    func stopChargingEffectLoop() {
        isChargingEffectLooping = false
        chargingEffectProgress = 0
        chargingEffectTimer?.invalidate()
        chargingEffectTimer = nil
        delegate?.batteryChargingEffectDidUpdate()
    }
    
    func cleanup() {
        batteryMonitorTimer?.invalidate()
        chargingEffectTimer?.invalidate()
        batteryMonitorTimer = nil
        chargingEffectTimer = nil
        isChargingEffectLooping = false
        chargingEffectProgress = 0
    }
    
    private func easeInOutCubic(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return t1 < 0.5 ? 4 * t1 * t1 * t1 : 1 - pow(-2 * t1 + 2, 3) / 2
    }
    
    private func easeInQuad(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return t1 * t1
    }
    
    private func easeOutQuad(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return 1 - (1 - t1) * (1 - t1)
    }
    
    private func easeInOutQuad(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return t1 < 0.5 ? 2 * t1 * t1 : 1 - pow(-2 * t1 + 2, 2) / 2
    }
    
    private func easeInQuart(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return t1 * t1 * t1 * t1
    }
    
    private func easeOutQuart(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return 1 - pow(1 - t1, 4)
    }
    
    private func easeInOutQuart(_ t: CGFloat) -> CGFloat {
        let t1 = min(max(t, 0), 1)
        return t1 < 0.5 ? 8 * t1 * t1 * t1 * t1 : 1 - pow(-2 * t1 + 2, 4) / 2
    }
    
    private func applyEasing(_ t: CGFloat) -> CGFloat {
        switch currentEasingType {
        case .easeInQuad:
            return easeInQuad(t)
        case .easeOutQuad:
            return easeOutQuad(t)
        case .easeInOutQuad:
            return easeInOutQuad(t)
        case .easeInCubic:
            return easeInOutCubic(t) // Using cubic as base
        case .easeOutCubic:
            return easeInOutCubic(t) // Using cubic as base
        case .easeInOutCubic:
            return easeInOutCubic(t)
        case .easeInQuart:
            return easeInQuart(t)
        case .easeOutQuart:
            return easeOutQuart(t)
        case .easeInOutQuart:
            return easeInOutQuart(t)
        }
    }
    
    private func randomizeEasing() {
        let easingTypes: [EasingType] = [.easeInQuad, .easeOutQuad, .easeInOutQuad, 
                                        .easeInCubic, .easeOutCubic, .easeInOutCubic,
                                        .easeInQuart, .easeOutQuart, .easeInOutQuart]
        currentEasingType = easingTypes.randomElement() ?? .easeInOutCubic
        currentDuration = TimeInterval.random(in: 1.8...2.5)
    }
}

enum EasingType {
    case easeInQuad, easeOutQuad, easeInOutQuad
    case easeInCubic, easeOutCubic, easeInOutCubic
    case easeInQuart, easeOutQuart, easeInOutQuart
}

protocol BatteryMonitorDelegate: AnyObject {
    func batteryChargingEffectDidUpdate()
}
