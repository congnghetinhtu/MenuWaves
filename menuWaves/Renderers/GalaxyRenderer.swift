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
    let sparkleCount = 2
    let starCount = 10
    var starPositions: [CGPoint] = []
    var starAlphas: [CGFloat] = []
    
    // Particles bay lơ lửng
    let particleCount = 5
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
        // Cập nhật particles bay lơ lửng với tối ưu performance
        for i in 0..<particleCount {
            var position = particlePositions[i]
            var velocity = particleVelocities[i]
            
            position.x += velocity.x
            position.y += velocity.y
            
            // Bounce off boundaries with optimized checks
            if position.x < 0 {
                velocity.x = -velocity.x
                position.x = 0
            } else if position.x > size.width {
                velocity.x = -velocity.x
                position.x = size.width
            }
            
            if position.y < 0 {
                velocity.y = -velocity.y
                position.y = 0
            } else if position.y > size.height {
                velocity.y = -velocity.y
                position.y = size.height
            }
            
            particlePositions[i] = position
            particleVelocities[i] = velocity
            
            // Thay đổi alpha nhẹ với giới hạn
            let alphaIndex = i % starCount
            starAlphas[alphaIndex] += CGFloat.random(in: -0.02...0.02)
            starAlphas[alphaIndex] = max(0.3, min(1.0, starAlphas[alphaIndex]))
        }
        
        // Cập nhật ripples với filter để tối ưu
        ripples = ripples.compactMap { ripple in
            var newRipple = ripple
            newRipple.radius += 2.0
            newRipple.alpha -= 0.02
            return newRipple.alpha > 0 ? newRipple : nil
        }
        
        // Tạo ripple mới ngẫu nhiên với rate limit
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
