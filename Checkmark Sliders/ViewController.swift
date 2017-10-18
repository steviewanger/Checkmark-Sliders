//
//  ViewController.swift
//  Checkmark Sliders
//
//  Created by Wang, Steve on 7/3/17.
//  Copyright © 2017 ClubHub. All rights reserved.
//

import UIKit

//        firstTextField
//        secondTextField
//        thirdTextfield
//        fourthTextField
//        fifthTextField

class ViewController: UIViewController {
    // Mass
    @IBOutlet weak var firstSlider: UISlider!
    @IBOutlet weak var firstTextField: UITextField!

    // Stiffness
    @IBOutlet weak var secondSlider: UISlider!
    @IBOutlet weak var secondTextField: UITextField!

    // Initial Velocity
    @IBOutlet weak var thirdSlider: UISlider!
    @IBOutlet weak var thirdTextfield: UITextField!

    // Damping
    @IBOutlet weak var fourthSlider: UISlider!
    @IBOutlet weak var fourthTextField: UITextField!

    // Delay of spring
    @IBOutlet weak var fifthSlider: UISlider!
    @IBOutlet weak var fifthTextField: UITextField!

    @IBOutlet weak var checkmarkView: UIView!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var tempTopConstraint: NSLayoutConstraint!

    var animation: CheckmarkAnimation!

    override func viewDidLoad() {
        super.viewDidLoad()

        tempTopConstraint = topConstraint

        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))]
        numberToolbar.sizeToFit()

        firstTextField.inputAccessoryView = numberToolbar
        secondTextField.inputAccessoryView = numberToolbar
        thirdTextfield.inputAccessoryView = numberToolbar
        fourthTextField.inputAccessoryView = numberToolbar
        fifthTextField.inputAccessoryView = numberToolbar

        firstSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        secondSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        thirdSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        fourthSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        fifthSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)

        firstTextField.addTarget(self, action: #selector(textFieldValueChanged(textfield:)), for: .editingDidEnd)
        secondTextField.addTarget(self, action: #selector(textFieldValueChanged(textfield:)), for: .editingDidEnd)
        thirdTextfield.addTarget(self, action: #selector(textFieldValueChanged(textfield:)), for: .editingDidEnd)
        fourthTextField.addTarget(self, action: #selector(textFieldValueChanged(textfield:)), for: .editingDidEnd)
        fifthTextField.addTarget(self, action: #selector(textFieldValueChanged(textfield:)), for: .editingDidEnd)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                topConstraint.isActive = false
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                topConstraint = tempTopConstraint
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpAnimation()

        firstSlider.value = animation.mass.toFloat()
        sliderValueChanged(slider: firstSlider)
        secondSlider.value = animation.stiffness.toFloat()
        sliderValueChanged(slider: secondSlider)
        thirdSlider.value = animation.initialVelocity.toFloat()
        sliderValueChanged(slider: thirdSlider)
        fourthSlider.value = animation.damping.toFloat()
        sliderValueChanged(slider: fourthSlider)
        fifthSlider.value = Float(animation.springCircleDelay)
        sliderValueChanged(slider: fifthSlider)
    }

    func sliderValueChanged(slider: UISlider) {
        switch slider.tag {
        case 1: firstTextField.text = slider.value.toString()
        case 2: secondTextField.text = slider.value.toString()
        case 3: thirdTextfield.text = slider.value.toString()
        case 4: fourthTextField.text = slider.value.toString()
        case 5: fifthTextField.text = slider.value.toString()
        default: break
        }
    }

    func textFieldValueChanged(textfield: UITextField) {
        var slider: UISlider = UISlider()
        switch textfield.tag {
        case 1: slider = firstSlider
        case 2: slider = secondSlider
        case 3: slider = thirdSlider
        case 4: slider = fourthSlider
        case 5: slider = fifthSlider
        default: break
        }

        guard let value = textfield.text?.toFloat(), value <= slider.maximumValue else {
            textfield.text = slider.value.toString()
            return
        }
        slider.value = value
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func clearView() {
        animation = nil
    }

    func setUpAnimation() {
        animation = CheckmarkAnimation()
        animation.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.addSubview(animation)
        animation.leadingAnchor.constraint(equalTo: checkmarkView.leadingAnchor).isActive = true
        animation.trailingAnchor.constraint(equalTo: checkmarkView.trailingAnchor).isActive = true
        animation.topAnchor.constraint(equalTo: checkmarkView.topAnchor).isActive = true
        animation.heightAnchor.constraint(equalToConstant: 232).isActive = true
    }

    @IBAction func animate(_ sender: Any) {
        clearView()
        setUpAnimation()
        animation.mass = firstSlider.value.toCGFloat()
        animation.stiffness = secondSlider.value.toCGFloat()
        animation.initialVelocity = thirdSlider.value.toCGFloat()
        animation.damping = fourthSlider.value.toCGFloat()
        animation.springCircleDelay = fifthSlider.value.toTimeInterval()
        animation.animate(completion: nil)
    }
}

extension Float {
    func toString() -> String? {
        return String(format:"%.2f", self)
    }

    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }

    func toTimeInterval() -> TimeInterval {
        return TimeInterval(self)
    }
}

extension CGFloat {
    func toFloat() -> Float {
        return Float(self)
    }
}

extension String {
    func toFloat() -> Float? {
        return Float(self)
    }
}

//
//  AnimationView.swift
//  IFS Banking
//
//  Created by Wang, Steve on 6/22/17.
//  Copyright © 2017 NCR Corp. All rights reserved.
//

import Foundation

struct AnimationKeys {
    static let kFillCircle = "fillCircleAnimation"
    static let kDrawCircle = "drawCircleAnimation"
    static let kSpringAnimation = "spingViewAnimation"
}

class AnimationView: UIView {
    func animate(completion: (() -> Void)?) {
        //Override by subclasses
    }

    func viewHeight() -> CGFloat {
        return 0.0
    }
}

class CheckmarkAnimation: AnimationView {
    var circleLayer = CAShapeLayer()
    var strokeColor = CheckmarkAnimation.UIColorFromRGB(rgbValue: 0x78b348).cgColor
    var fillColor = UIColor.clear.cgColor
    var radius: CGFloat = 50.0
    let viewPadding: CGFloat = 30.0

    init(radius: CGFloat) {
        super.init(frame: .zero)

        self.radius = radius
        setUpView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circleLayer.position = center
    }

    override func viewHeight() -> CGFloat {
        return radius * 2.0 + viewPadding
    }

    var springCircleDelay: TimeInterval = 0.3

    override func animate(completion: (() -> Void)?) {
        drawCircle(duration: 0.4) {
            self.circleLayer.backgroundColor = self.strokeColor
            self.fillCircle(duration: 0.4) {
                CATransaction.begin()
                self.startDrawingCheckMark(duration: 0.5)
                self.springCircle(delay: self.springCircleDelay)

                CATransaction.setCompletionBlock() {
                    completion?()
                }
                CATransaction.commit()
            }
        }
    }

    func setUpView() {
        backgroundColor = UIColor.white
    }

    func drawCircle(duration: TimeInterval, completion: @escaping () -> ()) {
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let diameter = radius * 2.0
        let rect = CGRect(x: 0.0, y: 0.0, width: diameter, height: diameter)

        circleLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
        circleLayer.cornerRadius = radius
        circleLayer.fillColor = backgroundColor?.cgColor
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.position = center
        circleLayer.bounds = rect
        circleLayer.strokeColor = strokeColor
        circleLayer.lineWidth = 0.08 * radius
        circleLayer.strokeEnd = 0.0
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(circleLayer)

        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = 0
        animation.toValue = 1.0
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        CATransaction.setCompletionBlock {
            completion()
        }
        circleLayer.add(animation, forKey: AnimationKeys.kDrawCircle)
        CATransaction.commit()
    }

    func fillCircle(duration: TimeInterval, completion: @escaping () -> ()) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        let endShape = UIBezierPath(roundedRect: CGRect(x: circleLayer.bounds.width / 2.0, y: circleLayer.bounds.height / 2.0, width: 0.0, height: 0.0), cornerRadius: 0.0).cgPath
        animation.toValue = endShape
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        CATransaction.setCompletionBlock {
            completion()
        }
        circleLayer.add(animation, forKey: AnimationKeys.kFillCircle)
        CATransaction.commit()
    }

    func startDrawingCheckMark(duration: TimeInterval) {
        let startXPoint: CGFloat = circleLayer.bounds.width * 0.31
        let startYPoint: CGFloat = circleLayer.bounds.height * 0.52
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: startXPoint, y: startYPoint))

        let bottomXPoint: CGFloat = circleLayer.bounds.width * 0.47
        let bottomYPoint: CGFloat = circleLayer.bounds.height * 0.66
        path.addLine(to: (CGPoint(x: bottomXPoint, y: bottomYPoint)))

        let topXPoint: CGFloat = circleLayer.bounds.width * 0.74
        let topYPoint: CGFloat = circleLayer.bounds.height * 0.3
        path.addLine(to: (CGPoint(x: topXPoint, y: topYPoint)))

        let pathLayer = CAShapeLayer()
        pathLayer.position = CGPoint(x: circleLayer.bounds.width / 2.0, y: circleLayer.bounds.width / 2.0)
        pathLayer.bounds = circleLayer.bounds
        pathLayer.path = path.cgPath
        pathLayer.strokeColor = UIColor.white.cgColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 0.14 * radius
        pathLayer.lineJoin = kCALineJoinMiter
        circleLayer.addSublayer(pathLayer)

        let pathAnimation = CABasicAnimation(keyPath:"strokeEnd")
        pathAnimation.duration = duration
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pathLayer.add(pathAnimation, forKey: "checkAnimation")
    }

    var mass: CGFloat = 2
    var stiffness: CGFloat = 80
    var initialVelocity: CGFloat = 40
    var damping: CGFloat = 12

    func springCircle(delay: TimeInterval) {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.mass = mass
        animation.stiffness = stiffness
        animation.initialVelocity = initialVelocity
        animation.damping = damping
        animation.fromValue = 0.95
        animation.toValue = 1
        animation.duration = animation.settlingDuration
        animation.beginTime = CACurrentMediaTime() + delay
        circleLayer.add(animation, forKey: AnimationKeys.kSpringAnimation)
    }

    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
