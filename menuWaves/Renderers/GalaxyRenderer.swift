//
//  GalaxyRenderer.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

class GalaxyRenderer {
    // Galaxy properties
    let sparkleCount = 3
    let starCount = 13
    var starPositions: [CGPoint] = []
    var starAlphas: [CGFloat] = []
    
    // Particles bay lơ lửng
    let particleCount = 8
    var particlePositions: [CGPoint] = []
    var particleVelocities: [CGPoint] = []
    var particleAlphas: [CGFloat] = []
    
    // Hiệu ứng ripple
    var ripples: [(position: CGPoint, radius: CGFloat, alpha: CGFloat)] = []
    var lastRippleTime: TimeInterval = 0
    
    func initialize(size: NSSize) {
        // Khởi tạo vị trí và alpha cho các ngôi sao
        starPositions = (0..<starCount).map { i in
            let x = CGFloat(i) / CGFloat(starCount) * size.width + CGFloat.random(in: -8...8)
            let y = CGFloat.random(in: 4...size.height-4)
            return CGPoint(x: x, y: y)
        }
        starAlphas = (0..<starCount).map { _ in CGFloat.random(in: 0.5...1.0) }
        
        // Khởi tạo particles bay lơ lửng
        particlePositions = (0..<particleCount).map { _ in
            CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
        }
        particleVelocities = (0..<particleCount).map { _ in
            CGPoint(x: CGFloat.random(in: -0.5...0.5), y: CGFloat.random(in: -0.3...0.3))
        }
        particleAlphas = (0..<particleCount).map { _ in CGFloat.random(in: 0.3...0.8) }
    }
    
    func updateParticles(size: NSSize) {
        // Cập nhật particles bay lơ lửng
        for i in 0..<particleCount {
            particlePositions[i].x += particleVelocities[i].x
            particlePositions[i].y += particleVelocities[i].y
            
            // Bounce off boundaries
            if particlePositions[i].x < 0 || particlePositions[i].x > size.width {
                particleVelocities[i].x *= -1
                particlePositions[i].x = max(0, min(size.width, particlePositions[i].x))
            }
            if particlePositions[i].y < 0 || particlePositions[i].y > size.height {
                particleVelocities[i].y *= -1
                particlePositions[i].y = max(0, min(size.height, particlePositions[i].y))
            }
            
            // Thay đổi alpha nhẹ
            starAlphas[i % starCount] += CGFloat.random(in: -0.02...0.02)
            starAlphas[i % starCount] = max(0.3, min(1.0, starAlphas[i % starCount]))
        }
        
        // Cập nhật ripples
        ripples = ripples.compactMap { ripple in
            var newRipple = ripple
            newRipple.radius += 2.0
            newRipple.alpha -= 0.02
            return newRipple.alpha > 0 ? newRipple : nil
        }
        
        // Tạo ripple mới ngẫu nhiên
        let now = CACurrentMediaTime()
        if now - lastRippleTime > Double.random(in: 1.0...3.0) && ripples.count < 3 {
            let newRipple = (
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height)),
                radius: CGFloat(0),
                alpha: CGFloat(0.3)
            )
            ripples.append(newRipple)
            lastRippleTime = now
        }
    }
}
