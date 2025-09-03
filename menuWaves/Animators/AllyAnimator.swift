//
//  AllyAnimator.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

class AllyAnimator {
    // Ally text animation properties
    var allyDrawProgress: CGFloat = 0 // 0 -> 2 (0-1: fade-in, 1-2: fade-out)
    
    // Flip animation properties
    var isFlipping: Bool = false
    var flipProgress: CGFloat = 0 // 0 -> 1 (flip animation progress)
    var showCountdown: Bool = false
    
    // Gradient animation properties for "NEXT"
    var nextGradientStartTime: TimeInterval = 0
    var nextGradientProgress: CGFloat = 0 // 0 -> 1 (gradient animation progress)
    var isNextGradientActive: Bool = false
    
    // Timer
    var allyFrameTimer: Timer?
    
    // Callback để notify updates
    var onUpdate: (() -> Void)?
    
    func startAllyAnimation() {
        let startTime = CACurrentMediaTime()
        allyDrawProgress = 0
        
        allyFrameTimer?.invalidate()
        allyFrameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] t in
            guard let self = self else { 
                t.invalidate()
                return 
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            
            if elapsed < 2.5 {
                self.allyDrawProgress = CGFloat(elapsed / 2.5) // 0 -> 1 (fade-in)
                
                // Kích hoạt hiệu ứng gradient ngay từ đầu để liền mạch
                if !self.isNextGradientActive {
                    self.isNextGradientActive = true
                    self.nextGradientStartTime = startTime
                }
                
                // Cập nhật gradient progress cho NEXT
                if self.isNextGradientActive {
                    let gradientElapsed = CACurrentMediaTime() - self.nextGradientStartTime
                    self.nextGradientProgress = CGFloat(fmod(gradientElapsed * 0.25, 1.0))
                }
            } else if elapsed < 5.5 {
                self.allyDrawProgress = 1.0 // giữ "Thanh Solar NEXT" lâu hơn (3 giây)
                
                // Tiếp tục gradient progress cho NEXT
                if self.isNextGradientActive {
                    let gradientElapsed = CACurrentMediaTime() - self.nextGradientStartTime
                    self.nextGradientProgress = CGFloat(fmod(gradientElapsed * 0.25, 1.0))
                }
            } else if elapsed < 6.5 {
                // Bắt đầu hiệu ứng lật
                if !self.isFlipping {
                    self.isFlipping = true
                    self.flipProgress = 0
                }
                self.flipProgress = CGFloat((elapsed - 5.5) / 1.0) // flip trong 1 giây
                if self.flipProgress >= 0.5 && !self.showCountdown {
                    self.showCountdown = true
                }
                
                // Tiếp tục gradient trong giai đoạn flip để liền mạch
                if self.isNextGradientActive && !self.showCountdown {
                    let gradientElapsed = CACurrentMediaTime() - self.nextGradientStartTime
                    self.nextGradientProgress = CGFloat(fmod(gradientElapsed * 0.25, 1.0))
                }
            } else if elapsed < 12.5 {
                self.flipProgress = 1.0
                self.showCountdown = true
                
                // Tiếp tục gradient trong giai đoạn countdown (nếu cần)
                if self.isNextGradientActive && !self.showCountdown {
                    let gradientElapsed = CACurrentMediaTime() - self.nextGradientStartTime
                    self.nextGradientProgress = CGFloat(fmod(gradientElapsed * 0.4, 1.0))
                }
            } else if elapsed < 14.0 {
                self.allyDrawProgress = 1.0 + CGFloat((elapsed-12.5)/1.5) // fade-out
            } else {
                self.allyDrawProgress = 2.0
                self.isFlipping = false
                self.showCountdown = false
                self.flipProgress = 0
                self.isNextGradientActive = false
                self.nextGradientProgress = 0
                t.invalidate()
                self.allyFrameTimer = nil
            }
            
            // Trigger update callback
            self.onUpdate?()
        }
    }
    
    func reset() {
        allyFrameTimer?.invalidate()
        allyFrameTimer = nil
        allyDrawProgress = 0
        isFlipping = false
        showCountdown = false
        flipProgress = 0
        isNextGradientActive = false
        nextGradientProgress = 0
    }
    
    func getCountdownText() -> String {
        let now = Date()
        let calendar = Calendar.current
        let targetDate = calendar.date(from: DateComponents(year: 2050, month: 1, day: 1)) ?? Date()
        let timeRemaining = targetDate.timeIntervalSince(now)
        
        if timeRemaining <= 0 {
            return "Happy 2050!"
        }
        
        let days = Int(timeRemaining) / (24 * 3600)
        let hours = (Int(timeRemaining) % (24 * 3600)) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        
        return String(format: "%dd" + " " + " " + " " + "%02d:%02d:%02d", days, hours, minutes, seconds)
    }
}
