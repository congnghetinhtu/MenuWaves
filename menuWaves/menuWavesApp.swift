//
//  menuWavesApp.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 8/23/25.
//

import SwiftUI
import AppKit

@main
struct menuWavesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // Core managers
    private let menuBarManager = MenuBarManager()
    private let batteryMonitor = BatteryMonitor()
    private let effectController = EffectController()
    
    // Configuration
    private let waveWidth: CGFloat = 200
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup delegates
        menuBarManager.delegate = self
        batteryMonitor.delegate = self
        effectController.delegate = self
        
        // Initialize components
        let size = NSSize(width: waveWidth, height: 22)
        menuBarManager.setupMenuBar(width: waveWidth)
        batteryMonitor.setupBatteryMonitoring()
        effectController.start(size: size)
        
        // Initial icon update
        updateIcon()
    }
    
    private func updateIcon() {
        let size = NSSize(width: waveWidth, height: 22)
        let image = NSImage.createMenuBarIcon(
            size: size,
            waveAnimator: effectController.waveAnimator,
            allyAnimator: effectController.allyAnimator,
            galaxyRenderer: effectController.galaxyRenderer,
            chargingEffectProgress: batteryMonitor.chargingEffectProgress
        )
        menuBarManager.updateIcon(image)
    }
    
    private func cleanup() {
        effectController.cleanup()
        batteryMonitor.cleanup()
    }
}

// MARK: - MenuBarManagerDelegate
extension AppDelegate: MenuBarManagerDelegate {
    func menuBarManagerDidRequestQuit() {
        cleanup()
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - BatteryMonitorDelegate  
extension AppDelegate: BatteryMonitorDelegate {
    func batteryChargingEffectDidUpdate() {
        updateIcon()
    }
}

// MARK: - EffectControllerDelegate
extension AppDelegate: EffectControllerDelegate {
    func effectControllerDidUpdate() {
        updateIcon()
    }
}
