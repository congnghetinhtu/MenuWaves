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
    
    // Main animation timer for better performance
    var displayTimer: Timer?
    
    // State tracking
    var lastPhase: CGFloat = 0
    var lastDrawProgress: CGFloat = -1
    var lastIsReversing: Bool = false
    var cachedSize: NSSize = NSSize(width: 200, height: 22)
    
    weak var delegate: EffectControllerDelegate?
    
    func start(size: NSSize) {
        cachedSize = size
        galaxyRenderer.initialize(size: size)
        
        // Setup callback cho ally animator
        allyAnimator.onUpdate = { [weak self] in
            self?.delegate?.effectControllerDidUpdate()
        }
        
        // Setup main animation timer for smooth 60fps animation
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            self?.updateAnimation()
        }
        
        // Setup effect cycle timer (30s/2s cycle)
        setupEffectCycle()
    }
    
    private func updateAnimation() {
        // Store previous state for change detection
        let oldPhase = self.waveAnimator.phase
        let oldDrawProgress = self.waveAnimator.drawProgress
        let oldIsReversing = self.waveAnimator.isReversing
        
        // Update animations
        self.waveAnimator.update()
        self.galaxyRenderer.updateParticles(size: cachedSize)
        
        // Update ally animator if it's running
        if self.allyAnimator.allyFrameTimer != nil {
            // Ally animation logic handled in its own timer
        }
        
        // Only update icon if there are significant changes (performance optimization)
        let phaseDiff = abs(oldPhase - self.waveAnimator.phase)
        let drawProgressDiff = abs(oldDrawProgress - self.waveAnimator.drawProgress)
        let hasSignificantChange = phaseDiff > 0.05 || drawProgressDiff > 0.01 || oldIsReversing != self.waveAnimator.isReversing
        
        if hasSignificantChange {
            self.delegate?.effectControllerDidUpdate()
        } else {
            // Always update for smooth 60fps when wave is actively drawing
            if !self.waveAnimator.isAnimationComplete {
                self.delegate?.effectControllerDidUpdate()
            }
        }
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
        displayTimer?.invalidate()
        effectTimer?.invalidate()
        allyAnimator.reset()
        
        // Clear any cached data for memory efficiency
        lastPhase = 0
        lastDrawProgress = -1
        lastIsReversing = false
        
        displayTimer = nil
        effectTimer = nil
    }
    
    // MARK: - Memory Management
    
    deinit {
        cleanup()
    }
}

protocol EffectControllerDelegate: AnyObject {
    func effectControllerDidUpdate()
}
