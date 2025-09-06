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
    
    // Performance optimization - cached values
    private var cachedSinPhase: CGFloat = 0
    private var cachedAmplitudeMultiplier: CGFloat = 0
    private var cachedSpeedMultiplier: CGFloat = 0
    private var lastPhaseUpdate: CGFloat = -1
    
    // Timing control
    var lastFrequencyChange: TimeInterval = 0
    var lastPhaseSpeedChange: TimeInterval = 0
    
    // State
    var isWaveActive: Bool = true
    var isReversing: Bool = false
    
    // Configuration for smoother transitions
    private let minFrequency: CGFloat = 2.8
    private let maxFrequency: CGFloat = 4.2
    private let minPhaseSpeed: CGFloat = 0.03
    private let maxPhaseSpeed: CGFloat = 0.12
    
    func update() {
        // Cache calculations for better performance
        let phaseChanged = abs(phase - lastPhaseUpdate) > 0.001
        if phaseChanged {
            cachedSinPhase = sin(phase * 0.5)
            cachedAmplitudeMultiplier = sin(phase * 0.3)
            lastPhaseUpdate = phase
        }
        
        // Phase luôn được update để galaxy và particles không bị dừng
        phase += phaseSpeed + 0.02 * cachedSinPhase
        amplitude = baseAmplitude + 0.8 * cachedAmplitudeMultiplier
        
        // Cache speed calculation only when needed
        if cachedSpeedMultiplier == 0 || phaseChanged {
            cachedSpeedMultiplier = 0.7 + 0.7 * pow(drawProgress, 1.5)
        }
        let speed = initialDrawSpeed * cachedSpeedMultiplier
        
        updateDrawProgress(with: speed)
        updateDynamicParameters()
    }
    
    private func updateDrawProgress(with speed: CGFloat) {
        if isReversing {
            drawProgress -= speed * (1 - pow(1 - drawProgress, 2.2))
            drawProgress = max(0, drawProgress) // More efficient than if check
        } else {
            if drawProgress < 1 {
                drawProgress += speed * (1 - pow(drawProgress, 2.2))
                drawProgress = min(1, drawProgress) // More efficient than if check
            }
        }
    }
    
    private func updateDynamicParameters() {
        guard !isReversing && drawProgress >= 1.0 else { return }
        
        let now = CACurrentMediaTime()
        
        // Use randomized intervals for more natural feel
        if now - lastFrequencyChange > Double.random(in: 2.0...4.0) {
            frequency = CGFloat.random(in: minFrequency...maxFrequency)
            lastFrequencyChange = now
        }
        
        if now - lastPhaseSpeedChange > Double.random(in: 2.0...4.0) {
            phaseSpeed = CGFloat.random(in: minPhaseSpeed...maxPhaseSpeed)
            lastPhaseSpeedChange = now
        }
    }
    
    func reset() {
        drawProgress = 0
        isReversing = false
        // Clear cached values for fresh start
        cachedSpeedMultiplier = 0
        lastPhaseUpdate = -1
        // Không reset phase để galaxy và particles tiếp tục chạy mượt mà
    }
    
    func startReversing() {
        isReversing = true
        // Clear cache to recalculate for reverse animation
        cachedSpeedMultiplier = 0
    }
    
    // MARK: - Utility Methods
    
    /// Get current wave intensity (0.0 to 1.0)
    func getCurrentIntensity() -> CGFloat {
        let baseIntensity = drawProgress
        let phaseVariation = 0.1 * abs(cachedSinPhase)
        return min(1.0, baseIntensity + phaseVariation)
    }
    
    /// Get current wave position for external synchronization
    func getCurrentWavePosition(width: CGFloat) -> CGFloat {
        return isReversing ? 
            width - (width * drawProgress) : 
            width * drawProgress
    }
    
    /// Check if wave animation is complete
    var isAnimationComplete: Bool {
        return isReversing ? drawProgress <= 0 : drawProgress >= 1.0
    }
}
