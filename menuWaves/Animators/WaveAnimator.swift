//
//  WaveAnimator.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

class WaveAnimator {
    // Wave properties
    var phase: CGFloat = 0
    var drawProgress: CGFloat = 0
    var initialDrawSpeed: CGFloat = 0.03
    var frequency: CGFloat = 2.2
    var baseAmplitude: CGFloat = 6
    var amplitude: CGFloat = 6
    var phaseSpeed: CGFloat = 0.06
    
    // Timing control
    var lastFrequencyChange: TimeInterval = 0
    var lastPhaseSpeedChange: TimeInterval = 0
    
    // State
    var isWaveActive: Bool = true
    var isReversing: Bool = false
    
    func update() {
        // Phase luôn được update để galaxy và particles không bị dừng
        phase += phaseSpeed + 0.02 * sin(phase * 0.5)
        amplitude = baseAmplitude + 0.8 * sin(phase * 0.3)
        
        // Tăng tốc độ vẽ dần khi drawProgress tăng
        let speed = initialDrawSpeed * (0.7 + 0.7 * pow(drawProgress, 1.5))
        
        if isReversing {
            drawProgress -= speed * (1 - pow(1 - drawProgress, 2.2))
            if drawProgress < 0 { drawProgress = 0 }
        } else {
            if drawProgress < 1 {
                drawProgress += speed * (1 - pow(drawProgress, 2.2))
                if drawProgress > 1 { drawProgress = 1 }
            } else {
                // Khi đã vẽ xong đoạn đầu, cho tần số sóng và tốc độ di chuyển thay đổi ngẫu nhiên mỗi 2-4 giây
                let now = CACurrentMediaTime()
                if now - lastFrequencyChange > Double.random(in: 2.0...4.0) {
                    frequency = CGFloat.random(in: 2.8...4.2)
                    lastFrequencyChange = now
                }
                if now - lastPhaseSpeedChange > Double.random(in: 2.0...4.0) {
                    phaseSpeed = CGFloat.random(in: 0.03...0.12)
                    lastPhaseSpeedChange = now
                }
            }
        }
    }
    
    func reset() {
        drawProgress = 0
        isReversing = false
        // Không reset phase để galaxy và particles tiếp tục chạy mượt mà
    }
    
    func startReversing() {
        isReversing = true
    }
}
