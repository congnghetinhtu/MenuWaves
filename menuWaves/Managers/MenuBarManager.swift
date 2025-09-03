//
//  MenuBarManager.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

class MenuBarManager {
    var statusItem: NSStatusItem?
    var isDockHidden: Bool = false
    
    weak var delegate: MenuBarManagerDelegate?
    
    func setupMenuBar(width: CGFloat) {
        statusItem = NSStatusBar.system.statusItem(withLength: width)
        
        // Thêm menu chuột phải với lựa chọn Quit
        let menu = NSMenu()
        let dockItem = NSMenuItem(title: "Hide from Dock", action: #selector(toggleDockVisibility(_:)), keyEquivalent: "h")
        dockItem.target = self
        dockItem.state = isDockHidden ? .on : .off
        menu.addItem(dockItem)
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    func updateIcon(_ image: NSImage) {
        statusItem?.button?.image = image
    }
    
    @objc func toggleDockVisibility(_ sender: NSMenuItem) {
        isDockHidden.toggle()
        sender.state = isDockHidden ? .on : .off
        if isDockHidden {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    @objc func quitApp() {
        delegate?.menuBarManagerDidRequestQuit()
    }
}

protocol MenuBarManagerDelegate: AnyObject {
    func menuBarManagerDidRequestQuit()
}
