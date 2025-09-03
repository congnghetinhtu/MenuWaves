//
//  EffectController.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

class EffectController {
    // Animation components
    let waveAnimator = WaveAnimator()
    let allyAnimator = AllyAnimator()
    let galaxyRenderer = GalaxyRenderer()
    
    // Timing control
    var effectTimer: Timer?
    var effectElapsed: TimeInterval = 0
    
    // Main animation timer
    var timer: Timer?
    
    // State tracking
    var lastPhase: CGFloat = 0
    var lastDrawProgress: CGFloat = -1
    var lastIsReversing: Bool = false
    
    weak var delegate: EffectControllerDelegate?
    
    func start(size: NSSize) {
        galaxyRenderer.initialize(size: size)
        
        // Setup callback cho ally animator
        allyAnimator.onUpdate = { [weak self] in
            self?.delegate?.effectControllerDidUpdate()
        }
        
        // Setup main animation timer
        let refreshRate: Double = NSScreen.main?.maximumFramesPerSecond != 0 ? Double(NSScreen.main?.maximumFramesPerSecond ?? 60) : 60
        let frameInterval = 1.0 / refreshRate
        
        timer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let oldPhase = self.waveAnimator.phase
            let oldDrawProgress = self.waveAnimator.drawProgress
            let oldIsReversing = self.waveAnimator.isReversing
            
            self.waveAnimator.update()
            self.galaxyRenderer.updateParticles(size: size)
            
            // Luôn update icon để galaxy và particles không bị khựng
            // Đặc biệt quan trọng khi ally animation đang chạy
            self.delegate?.effectControllerDidUpdate()
        }
        
        // Setup effect cycle timer (30s/2s cycle)
        setupEffectCycle()
    }
    
    private func setupEffectCycle() {
        effectElapsed = 0
        waveAnimator.isWaveActive = true
        waveAnimator.isReversing = false
        
        effectTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.effectElapsed += 1.0
            
            if self.waveAnimator.isWaveActive && self.effectElapsed >= 30 {
                self.waveAnimator.isWaveActive = false
                self.waveAnimator.startReversing()
                self.allyAnimator.startAllyAnimation()
                
                // Reset after ally animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) {
                    self.resetCycle()
                }
            }
        }
    }
    
    private func resetCycle() {
        allyAnimator.reset()
        waveAnimator.reset()
        effectElapsed = 0
        waveAnimator.isWaveActive = true
        waveAnimator.isReversing = false
    }
    
    func cleanup() {
        timer?.invalidate()
        effectTimer?.invalidate()
        allyAnimator.reset()
        timer = nil
        effectTimer = nil
    }
}

protocol EffectControllerDelegate: AnyObject {
    func effectControllerDidUpdate()
}
