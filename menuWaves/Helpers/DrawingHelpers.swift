//
//  DrawingHelpers.swift
//  menuWaves
//
//  Created by Van Thanh Pham on 9/1/25.
//

import Foundation
import AppKit

extension NSImage {
    static func createMenuBarIcon(
        size: NSSize,
        waveAnimator: WaveAnimator,
        allyAnimator: AllyAnimator,
        galaxyRenderer: GalaxyRenderer,
        chargingEffectProgress: CGFloat
    ) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        
        // Thiết lập motion blur context
        guard let context = NSGraphicsContext.current?.cgContext else { 
            image.unlockFocus()
            return image 
        }
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // Motion blur intensity dựa trên tốc độ chuyển động
        let blurRadius: CGFloat = 0.8 + 0.4 * abs(sin(waveAnimator.phase * 0.3))
        
        // Áp dụng shadow blur cho toàn bộ để tạo motion blur
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.clear
        shadow.shadowBlurRadius = blurRadius
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.set()
        
        let rect = NSRect(origin: .zero, size: size)
        
        DrawingHelpers.drawGalaxy(in: rect, galaxyRenderer: galaxyRenderer, phase: waveAnimator.phase)
        DrawingHelpers.drawParticles(in: rect, galaxyRenderer: galaxyRenderer, phase: waveAnimator.phase)
        DrawingHelpers.drawRipples(in: rect, galaxyRenderer: galaxyRenderer, phase: waveAnimator.phase)
        
        if waveAnimator.isWaveActive || waveAnimator.isReversing {
            DrawingHelpers.drawWave(in: rect, waveAnimator: waveAnimator, chargingEffectProgress: chargingEffectProgress)
        } else if chargingEffectProgress > 0 {
            // Vẽ sóng mờ khi ally animation để hiệu ứng sạc đầy vẫn hiển thị
            DrawingHelpers.drawWave(in: rect, waveAnimator: waveAnimator, chargingEffectProgress: chargingEffectProgress, isBackground: true)
        }
        
        // Hiệu ứng chữ Ally với flip transition
        if waveAnimator.isReversing {
            DrawingHelpers.drawAllyText(in: rect, allyAnimator: allyAnimator, phase: waveAnimator.phase)
        }
        
        image.unlockFocus()
        return image
    }
}

class DrawingHelpers {
    static func drawGalaxy(in rect: NSRect, galaxyRenderer: GalaxyRenderer, phase: CGFloat) {
        // Vẽ background galaxy với các ngôi sao nhấp nháy
        let starSpeed: CGFloat = 0.35
        for i in 0..<galaxyRenderer.starCount {
            let base = galaxyRenderer.starPositions[i]
            let offset = sin(phase * starSpeed + CGFloat(i) * 1.3) * 6
            let x = base.x + offset
            let y = base.y
            let starSize = 1.2 + CGFloat(i % 3) * 0.5
            let alpha = galaxyRenderer.starAlphas[i]
            
            NSColor(calibratedWhite: 1.0, alpha: alpha).setFill()
            let starRect = NSRect(x: x, y: y, width: starSize, height: starSize)
            NSBezierPath(ovalIn: starRect).fill()
        }
    }
    
    static func drawParticles(in rect: NSRect, galaxyRenderer: GalaxyRenderer, phase: CGFloat) {
        // Motion blur cho particles
        let particleBlurTrails = 3
        let trailSpacing: CGFloat = 0.8
        
        // Vẽ particles bay lơ lửng
        for i in 0..<galaxyRenderer.particleCount {
            let position = galaxyRenderer.particlePositions[i]
            let time = phase * 0.1
            let hue = fmod(time + CGFloat(i) * 0.3, 1.0)
            
            // Vẽ particle với motion blur trails
            for trail in 0..<particleBlurTrails {
                let trailAlpha = galaxyRenderer.particleAlphas[i] * (1.0 - CGFloat(trail) * 0.4)
                let trailOffset = CGFloat(trail) * trailSpacing
                let trailX = position.x - galaxyRenderer.particleVelocities[i].x * trailOffset * 3
                let trailY = position.y - galaxyRenderer.particleVelocities[i].y * trailOffset * 3
                
                let color = NSColor(hue: hue, saturation: 0.7, brightness: 0.9, alpha: trailAlpha * 0.6)
                color.setFill()
                
                let size = CGFloat.random(in: 1.5...3.0) * (1.0 - CGFloat(trail) * 0.2)
                let particleRect = NSRect(x: trailX-size/2, y: trailY-size/2, width: size, height: size)
                NSBezierPath(ovalIn: particleRect).fill()
            }
        }
    }
    
    static func drawRipples(in rect: NSRect, galaxyRenderer: GalaxyRenderer, phase: CGFloat) {
        // Vẽ ripple effects
        for ripple in galaxyRenderer.ripples {
            // Vẽ ripple với motion blur
            for blurLayer in 0..<2 {
                let blurAlpha = ripple.alpha * (1.0 - CGFloat(blurLayer) * 0.5)
                let blurRadius = ripple.radius + CGFloat(blurLayer) * 0.8
                
                let color = NSColor(calibratedWhite: 1.0, alpha: blurAlpha * 0.4)
                color.setStroke()
                let ripplePath = NSBezierPath(ovalIn: NSRect(
                    x: ripple.position.x - blurRadius,
                    y: ripple.position.y - blurRadius,
                    width: blurRadius * 2,
                    height: blurRadius * 2
                ))
                ripplePath.lineWidth = 1.0 - CGFloat(blurLayer) * 0.3
                ripplePath.stroke()
            }
        }
    }
    
    static func drawWave(in rect: NSRect, waveAnimator: WaveAnimator, chargingEffectProgress: CGFloat, isBackground: Bool = false) {
        let amplitude = waveAnimator.amplitude
        let frequency = waveAnimator.frequency
        let midY = rect.midY
        let maxX: CGFloat = waveAnimator.isReversing ? 
            rect.maxX - (rect.width * waveAnimator.drawProgress) : 
            rect.minX + (rect.width * waveAnimator.drawProgress)
        
        // Adaptive stride for better performance vs quality balance
        let strideStep: CGFloat = max(0.5, rect.width / 350)
        let tailEffect = 0.7 + 0.3 * sin(waveAnimator.phase * 0.25)
        let tailStart = rect.width * 0.7
        var prevPt: NSPoint? = nil
        let lw = max(2, rect.width / 50)
        
        // Reduce motion blur layers for better performance when background
        let blurLayers = isBackground ? 2 : 3
        let motionOffset = 1.2 * sin(waveAnimator.phase * 0.5)
        
        // Pre-calculate wave phase offset to avoid repetitive calculation
        let wavePhaseOffset = waveAnimator.phase
        
        // Cloudy gradient: blend giữa các màu nhạt với hiệu ứng aurora
        let time = waveAnimator.phase * 0.05
        
        // Gradient colors cho charging effect
        let chargingColors: [NSColor] = [
            NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.4, alpha: 1),
            NSColor(calibratedRed: 0.1, green: 0.9, blue: 0.5, alpha: 1),
            NSColor(calibratedRed: 0.0, green: 0.7, blue: 0.3, alpha: 1),
            NSColor(calibratedRed: 0.3, green: 0.95, blue: 0.6, alpha: 1),
            NSColor(calibratedRed: 0.15, green: 0.85, blue: 0.45, alpha: 1)
        ]
        
        let originalColors: [NSColor] = [
            NSColor(calibratedRed: 0.45 + 0.2*sin(time), green: 0.62 + 0.1*cos(time*1.3), blue: 1.0, alpha: 1),
            NSColor(calibratedRed: 0.62 + 0.1*cos(time*0.7), green: 0.38, blue: 1.0 - 0.1*sin(time), alpha: 1),
            NSColor(calibratedWhite: 0.85 + 0.1*sin(time*2), alpha: 1),
            NSColor(calibratedWhite: 0.65, alpha: 1),
            NSColor(calibratedRed: 0.30, green: 0.65 + 0.15*sin(time*1.5), blue: 1.0, alpha: 1)
        ]
        
        // Vẽ motion blur layers
        for layer in 0..<blurLayers {
            let layerAlpha = 1.0 - CGFloat(layer) * 0.3
            let layerOffset = CGFloat(layer) * motionOffset * 0.5
            
            prevPt = nil
            let xRange: [CGFloat] = waveAnimator.isReversing ? 
                stride(from: rect.maxX, to: maxX, by: -strideStep).map { $0 } : 
                stride(from: rect.minX, to: maxX, by: strideStep).map { $0 }
                
                for (i, x) in xRange.enumerated() {
                var amp = amplitude
                if x > tailStart {
                    let tailRatio = (x - tailStart) / (rect.width - tailStart)
                    amp *= (1.0 - tailRatio * tailEffect)
                }
                
                // Use pre-calculated phase offset for better performance
                let y = midY + amp * sin(frequency * (x / rect.width * 2 * .pi) + wavePhaseOffset) + layerOffset
                let pt = NSPoint(x: x, y: y)
                
                if let prev = prevPt {
                    let frac = CGFloat(i) / CGFloat(max(xRange.count-1, 1)) // Avoid division by zero
                    let positionRatio = x / rect.width                    // Charging wave effect
                    let greenIntensity: CGFloat
                    if chargingEffectProgress > 0 {
                        let waveWidth: CGFloat = 0.5
                        let waveCenter = chargingEffectProgress
                        let waveStart = waveCenter - waveWidth/2
                        let waveEnd = waveCenter + waveWidth/2
                        
                        if positionRatio >= waveStart && positionRatio <= waveEnd {
                            let localPosition = (positionRatio - waveStart) / waveWidth
                            // Ease-in-out cubic for smooth charging effect
                            let t1 = min(max(localPosition, 0), 1)
                            let easedLocalPosition = t1 < 0.5 ? 4*t1*t1*t1 : 1 - pow(-2*t1+2, 3)/2
                            if easedLocalPosition <= 0.5 {
                                greenIntensity = easedLocalPosition * 2
                            } else {
                                greenIntensity = (1.0 - easedLocalPosition) * 2
                            }
                        } else {
                            greenIntensity = 0.0
                        }
                    } else {
                        greenIntensity = 0.0
                    }
                    
                    // Tính màu gradient
                    let colorIdx = Int(frac * CGFloat(originalColors.count-1))
                    let nextIdx = min(colorIdx+1, originalColors.count-1)
                    let localFrac = (frac * CGFloat(originalColors.count-1)) - CGFloat(colorIdx)
                    let originalColor = originalColors[colorIdx].blended(withFraction: localFrac, of: originalColors[nextIdx]) ?? originalColors[colorIdx]
                    let chargingColor = chargingColors[colorIdx].blended(withFraction: localFrac, of: chargingColors[nextIdx]) ?? chargingColors[colorIdx]
                    
                    let finalColor = originalColor.blended(withFraction: greenIntensity, of: chargingColor) ?? originalColor
                    let backgroundAlpha = isBackground ? 0.3 : 1.0
                    let blurColor = finalColor.withAlphaComponent(layerAlpha * backgroundAlpha)
                    blurColor.setStroke()
                    
                    let seg = NSBezierPath()
                    seg.move(to: prev)
                    seg.line(to: pt)
                    seg.lineCapStyle = .round
                    seg.lineWidth = lw * (layer == 0 ? 1.0 : 0.7)
                    seg.stroke()
                }
                prevPt = pt
            }
        }

        // Hiệu ứng lấp lánh và ngôi sao
        if waveAnimator.drawProgress >= 1.0 {
            let sparkleCount = 3
            for i in 0..<sparkleCount {
                let sparkleX = rect.minX + (CGFloat(i+1) / CGFloat(sparkleCount+1)) * rect.width
                let sparkleY = midY + amplitude * sin(frequency * (sparkleX / rect.width * 2 * .pi) + waveAnimator.phase + CGFloat(i))
                let sparkleSize = CGFloat.random(in: 1.2...2.2)
                let sparkleAlpha = (0.7 + 0.3 * sin(waveAnimator.phase * 1.5 + CGFloat(i) * 2)) * (isBackground ? 0.3 : 1.0)
                
                NSColor(calibratedWhite: 1.0, alpha: sparkleAlpha).setFill()
                let sparkleRect = NSRect(x: sparkleX-0.5, y: sparkleY-0.5, width: sparkleSize, height: sparkleSize)
                NSBezierPath(ovalIn: sparkleRect).fill()
            }
        }

        // Vẽ ngôi sao
        let starPhaseSpeed: CGFloat = 0.25
        let starX = rect.maxX
        let starY = midY + amplitude * sin(frequency * (starX / rect.width * 2 * .pi) + waveAnimator.phase * starPhaseSpeed)
        let tipOffset: CGFloat = 3
        let starPoint = NSPoint(x: starX, y: starY - tipOffset)
        drawStar(at: starPoint, size: 8, alpha: isBackground ? 0.3 : 1.0)
    }
    
    static func drawAllyText(in rect: NSRect, allyAnimator: AllyAnimator, phase: CGFloat) {
        let displayText = allyAnimator.showCountdown ? allyAnimator.getCountdownText() : "Thanh Solar NEXT"
        let font = NSFont.systemFont(ofSize: allyAnimator.showCountdown ? 11 : 13, weight: .bold)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        // Ease-in-out cubic
        func easeInOut(_ t: CGFloat) -> CGFloat {
            let t1 = min(max(t, 0), 1)
            return t1 < 0.5 ? 4*t1*t1*t1 : 1 - pow(-2*t1+2, 3)/2
        }
        
        let fadeIn = min(allyAnimator.allyDrawProgress, 1.0)
        let fadeOut = max(0, min(allyAnimator.allyDrawProgress-1.0, 1.0))
        let alpha: CGFloat = fadeIn < 1.0 ? easeInOut(fadeIn) : 1.0 - easeInOut(fadeOut)
        
        // Scale bounce effect với flip
        let bounceScale: CGFloat
        if fadeIn < 1.0 {
            bounceScale = 0.6 + 0.4 * easeInOut(fadeIn) + 0.2 * sin(fadeIn * .pi * 3) * (1 - fadeIn)
        } else {
            bounceScale = 1.0 - 0.3 * easeInOut(fadeOut)
        }
        
        // Vị trí
        let startX: CGFloat = 0
        let centerX: CGFloat = rect.width/2
        let endX: CGFloat = rect.width
        let y: CGFloat = 2
        let w: CGFloat = rect.width
        let h: CGFloat = rect.height-4
        let x: CGFloat
        if fadeIn < 1.0 {
            x = startX + (centerX-startX)*easeInOut(fadeIn)
        } else {
            x = centerX + (endX-centerX)*easeInOut(fadeOut)
        }
        
        // Scale transform với flip effect
        NSGraphicsContext.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.translateX(by: x, yBy: y + h/2)
        
        // Hiệu ứng lật
        if allyAnimator.isFlipping {
            let flipScaleY = cos(allyAnimator.flipProgress * .pi)
            let adjustedFlipScaleY = max(0.1, abs(flipScaleY))
            transform.scaleX(by: bounceScale, yBy: bounceScale * adjustedFlipScaleY)
        } else {
            transform.scaleX(by: bounceScale, yBy: bounceScale)
        }
        
        transform.translateX(by: -x, yBy: -(y + h/2))
        transform.concat()
        
        // Motion blur cho text
        let textBlurLayers = 2
        let motionBlurOffset: CGFloat = 1.0 * sin(phase * 0.4)
        let textRect = NSRect(x: x-w/2, y: y, width: w, height: h)
        
        // Vẽ text với motion blur
        for blurLayer in 0..<textBlurLayers {
            let blurAlpha = alpha * (1.0 - CGFloat(blurLayer) * 0.4)
            let blurOffsetX = CGFloat(blurLayer) * motionBlurOffset * 0.7
            let blurOffsetY = CGFloat(blurLayer) * motionBlurOffset * 0.3
            let blurRect = NSRect(x: textRect.origin.x + blurOffsetX, y: textRect.origin.y + blurOffsetY, width: textRect.width, height: textRect.height)
            
            if !allyAnimator.showCountdown && displayText == "Thanh Solar NEXT" && allyAnimator.isNextGradientActive {
                // Gradient effect cho "NEXT"
                drawGradientText(displayText, in: blurRect, font: font, style: style, alpha: blurAlpha, gradientProgress: allyAnimator.nextGradientProgress)
            } else {
                // Text bình thường
                let textColor = allyAnimator.showCountdown ? 
                    NSColor(calibratedRed: 1.0, green: 0.8, blue: 0.2, alpha: blurAlpha) :
                    NSColor.white.withAlphaComponent(blurAlpha)
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: textColor,
                    .paragraphStyle: style
                ]
                
                let attrStr = NSAttributedString(string: displayText, attributes: attrs)
                attrStr.draw(in: blurRect)
            }
        }
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    private static func drawGradientText(_ text: String, in rect: NSRect, font: NSFont, style: NSMutableParagraphStyle, alpha: CGFloat, gradientProgress: CGFloat) {
        let baseText = "Thanh Solar "
        let nextText = "NEXT"
        
        // Vẽ phần "Thanh Solar " bình thường
        let baseColor = NSColor.white.withAlphaComponent(alpha)
        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: baseColor,
            .paragraphStyle: style
        ]
        
        let baseAttrStr = NSAttributedString(string: baseText, attributes: baseAttrs)
        let baseSize = baseAttrStr.size()
        let totalSize = NSAttributedString(string: text, attributes: baseAttrs).size()
        
        let baseRect = NSRect(
            x: rect.origin.x + (rect.width - totalSize.width) / 2,
            y: rect.origin.y + (rect.height - baseSize.height) / 2,
            width: baseSize.width,
            height: baseSize.height
        )
        baseAttrStr.draw(in: baseRect)
        
        // Vẽ "NEXT" với gradient
        let nextRect = NSRect(
            x: baseRect.maxX,
            y: baseRect.origin.y,
            width: totalSize.width - baseSize.width,
            height: baseSize.height
        )
        
        let nextChars = Array(nextText)
        let charWidth = nextRect.width / CGFloat(nextChars.count)
        let gradientWidth: CGFloat = 1.0
        
        for (i, char) in nextChars.enumerated() {
            let charRect = NSRect(
                x: nextRect.origin.x + CGFloat(i) * charWidth,
                y: nextRect.origin.y,
                width: charWidth,
                height: nextRect.height
            )
            
            let charPosition = CGFloat(i) / CGFloat(max(nextChars.count - 1, 1))
            let wavePosition = gradientProgress * (1.0 + 2.0 * gradientWidth) - gradientWidth
            let distanceFromWave = abs(charPosition - wavePosition)
            
            let charColor: NSColor
            if distanceFromWave < gradientWidth {
                let gradientT = 1.0 - (distanceFromWave / gradientWidth)
                let smoothGradientT = gradientT * gradientT * (3.0 - 2.0 * gradientT)
                
                let hue = fmod(gradientProgress * 1.5 + charPosition * 0.3, 1.0)
                let gradientColor = NSColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: alpha)
                
                charColor = NSColor(
                    calibratedRed: 1.0 + (gradientColor.redComponent - 1.0) * smoothGradientT,
                    green: 1.0 + (gradientColor.greenComponent - 1.0) * smoothGradientT,
                    blue: 1.0 + (gradientColor.blueComponent - 1.0) * smoothGradientT,
                    alpha: alpha
                )
            } else {
                charColor = NSColor.white.withAlphaComponent(alpha)
            }
            
            let charAttrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: charColor,
                .paragraphStyle: style
            ]
            
            let charAttrStr = NSAttributedString(string: String(char), attributes: charAttrs)
            charAttrStr.draw(in: charRect)
        }
    }
    
    private static func drawStar(at point: NSPoint, size: CGFloat, alpha: CGFloat = 1.0) {
        let path = NSBezierPath()
        let starPoints = 5
        let r = size / 2
        let center = point
        let angle = CGFloat.pi / 2
        
        for i in 0...starPoints {
            let theta = angle + CGFloat(i) * 2 * .pi / CGFloat(starPoints)
            let x = center.x + r * cos(theta)
            let y = center.y + r * sin(theta)
            if i == 0 {
                path.move(to: NSPoint(x: x, y: y))
            } else {
                path.line(to: NSPoint(x: x, y: y))
            }
        }
        
        NSColor.systemYellow.withAlphaComponent(alpha).setFill()
        path.close()
        path.fill()
        NSColor.systemOrange.withAlphaComponent(alpha).setStroke()
        path.lineWidth = 1.2
        path.stroke()
    }
}
