//
//  DrawView.swift
//  test
//
//  Created by ios_school on 2/11/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class DrawView: UIView {
    @IBInspectable var shapeColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var isShapeHidden: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    private var curPath: UIBezierPath?
    var shapeHitHandler: ((DrawView) -> Void)?

    override func draw(_ rect: CGRect) {
        guard !isShapeHidden else {
            curPath = nil
            return
        }
        shapeColor.setStroke()
        let path = getTrianglePath()
        path.stroke()
        curPath = path
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        shapeHitHandler?(self)
    }
    
    func moveDrawObject() {
        isShapeHidden = !isShapeHidden
        setNeedsDisplay()
    }
    
    private func getTrianglePath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 3
        path.addArc(withCenter: CGPoint(x: 50, y: 20), radius: 15, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.move(to: CGPoint(x: 45, y: 15))
        path.addLine(to: CGPoint(x: 50, y: 25))
        path.addLine(to: CGPoint(x: 55, y: 10))
        return path
    }
}
