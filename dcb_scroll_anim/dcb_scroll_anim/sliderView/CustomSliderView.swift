//
//  CustomSliderV.swift
//  dcb_scroll_anim
//
//  Created by Baiaman Apsamatov on 3/9/21.
//

import UIKit

// MARK: - for taking absolute position of layer

extension UIView {
    func getLayerPosition(flag: Bool) -> CGPoint {
        if flag, let temp = layer.presentation() {
            return temp.position
        }
        return center
    }
}

class CustomSliderV: UIView {
    private var flag: Bool = false {
        didSet {
            if let refreshScale = refreshScale {
                refreshScale.isPaused = !flag
            }
        }
    }

    // MARK: - layer for scale

    private lazy var curveCanvasShapeLayer: CAShapeLayer = self.makeShapeLayer()
    private lazy var gradient: CAGradientLayer = self.makeGradientLayer()
    private lazy var circleView: UIView = self.makeCircleView()

    private lazy var backgroundView: UIView = self.makeBackgroundView()

    private lazy var topControl: UIView = self.makeControlPointView()
    private lazy var rightSideControlPoint2: UIView = self.makeControlPointView()
    private lazy var leftStartCurve: UIView = self.makeControlPointView()
    private lazy var leftSideControlPoint2: UIView = self.makeControlPointView()
    private lazy var leftSideControlPoint1: UIView = self.makeControlPointView()
    private lazy var rightEndCurve: UIView = self.makeControlPointView()
    private lazy var rightSideControlPoint1: UIView = self.makeControlPointView()

    private lazy var nativeSlider: UISlider = self.makeSliderView()
    private lazy var maskShapeLayer: CAShapeLayer = self.makeMaskShapelayer()

    lazy var editButton: UIButton = self.makeEditButton()
    lazy var containerFieldCurrency: UIView = self.makeContainer()
//    lazy var summTextField: UITextField = self.makeUItextField()
    lazy var currencyImageView: UIImageView = self.makeCurrencyImage()

    private var containerView: UIView = UIView()
    private var allView: [UIView] = []
    private var refreshScale: CADisplayLink?
    private var nativeSliderCoordinateX: CGFloat = 0.0

    weak var delegate: DelegateChangeSlider?

    private var countOfRect: Int = 20
    private var pathBounds: CGRect = .zero

    init(localView: UIView) {
        containerView = localView
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: containerView.bounds.width, height: 100.0))

        circleView.backgroundColor = UIColor.clear

        curveCanvasShapeLayer.frame.size = containerView.frame.size

        containerView.addSubview(circleView)
        circleView.center.y = 130
        circleView.center.x = containerView.bounds.midX

        containerView.layer.addSublayer(curveCanvasShapeLayer)
        settingsDisplayRefresh()

        // bottom side
        containerView.addSubview(topControl)
        containerView.addSubview(rightSideControlPoint2)
        // left side
        containerView.addSubview(leftStartCurve)
        containerView.addSubview(leftSideControlPoint1)
        containerView.addSubview(leftSideControlPoint2)
        // right side
        containerView.addSubview(rightSideControlPoint1)
        containerView.addSubview(rightEndCurve)

        // initial change positions
        leftStartCurve.center = CGPoint(x: circleView.frame.minX - 25, y: circleView.frame.minY + 15)
        leftSideControlPoint2.center = CGPoint(x: circleView.frame.midX - 20, y: circleView.frame.minY)
        leftSideControlPoint1.center = CGPoint(x: circleView.frame.minX - 10, y: circleView.frame.midY - 5)

        topControl.center = CGPoint(x: circleView.frame.midX, y: circleView.frame.minY - 20)
        rightSideControlPoint2.center = CGPoint(x: circleView.frame.midX + 20, y: circleView.frame.minY)

        rightEndCurve.center = CGPoint(x: circleView.frame.maxX + 25, y: circleView.frame.minY + 15)
        rightSideControlPoint1.center = CGPoint(x: circleView.frame.maxX + 10, y: circleView.frame.midY - 5)

        createRectangle()

        curveCanvasShapeLayer.path = curvePath()
        gradient.frame = pathBounds
        gradient.mask = curveCanvasShapeLayer
        gradient.frame.size.height += 600
        gradient.frame.origin.y = 0.0
        containerView.layer.addSublayer(gradient)

        containerView.backgroundColor = UIColor.clear

        rectangleChangePosition()

        containerView.addSubview(nativeSlider)
        sliderAutolayout()
        nativeSlider.addTarget(self, action: #selector(sliderChangeValue(sender:)), for: .valueChanged)
        let tempImage = UIImage(named: "ic_left_to_right_slider_button")
        nativeSlider.setThumbImage(tempImage, for: .normal)
        nativeSlider.setValue(50000, animated: false)
        containerView.addSubview(backgroundView)
        autolayoutBackgroundView()
        maskShapeLayer.bounds = backgroundView.bounds
        maskShapeLayer.path = curvePathMask()
        backgroundView.layer.mask = maskShapeLayer

        backgroundView.layer.addSublayer(maskShapeLayer)
        containerView.insertSubview(backgroundView, at: 0)

        backgroundView.addSubview(containerFieldCurrency)
//        containerFieldCurrency.addSubview(summTextField)
        containerFieldCurrency.addSubview(currencyImageView)
        backgroundView.addSubview(editButton)

        autolayoutEditButton()
    }

    func curvePathMask() -> CGPath {
        changePostitionControlPoints()
        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0.0, y: circleView.frame.minY + 15))
        path.addLine(to: leftStartCurve.getLayerPosition(flag: flag))
        path.addCurve(to: topControl.getLayerPosition(flag: flag), controlPoint1: leftSideControlPoint1.getLayerPosition(flag: flag), controlPoint2: leftSideControlPoint2.getLayerPosition(flag: flag))
        path.addCurve(to: rightEndCurve.getLayerPosition(flag: flag), controlPoint1: rightSideControlPoint1.getLayerPosition(flag: flag), controlPoint2: rightSideControlPoint2.getLayerPosition(flag: flag))
        path.addLine(to: CGPoint(x: backgroundView.bounds.width, y: circleView.frame.minY + 15))

        path.addLine(to: CGPoint(x: backgroundView.bounds.width, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: backgroundView.frame.maxY))

        return path.cgPath
    }

    func autolayoutBackgroundView() {
        backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 125).isActive = true
    }

    func sliderAutolayout() {
        nativeSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2.0).isActive = true
        nativeSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0).isActive = true
        nativeSlider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 48).isActive = true
    }

    func autolayoutEditButton() {
        NSLayoutConstraint.activate([
            editButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16.0),
            editButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 21.0),
            editButton.widthAnchor.constraint(equalToConstant: 24.0),
            editButton.heightAnchor.constraint(equalToConstant: 24.0)
        ])

        NSLayoutConstraint.activate([
            containerFieldCurrency.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            containerFieldCurrency.heightAnchor.constraint(equalToConstant: 34.0),
            containerFieldCurrency.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),

            currencyImageView.centerYAnchor.constraint(equalTo: containerFieldCurrency.centerYAnchor),
            currencyImageView.heightAnchor.constraint(equalToConstant: 16.0),
            currencyImageView.widthAnchor.constraint(equalToConstant: 12.0),
            currencyImageView.trailingAnchor.constraint(equalTo: containerFieldCurrency.trailingAnchor),

//            summTextField.topAnchor.constraint(equalTo: containerFieldCurrency.topAnchor),
//            summTextField.leadingAnchor.constraint(equalTo: containerFieldCurrency.leadingAnchor),
//            summTextField.trailingAnchor.constraint(equalTo: currencyImageView.leadingAnchor, constant: -10.0),
//            summTextField.bottomAnchor.constraint(equalTo: containerFieldCurrency.bottomAnchor),
        ])

//        summTextField.addTarget(self, action: #selector(changeSummOfTextField(sender:)), for: .editingChanged)
//        summTextField.addTarget(self, action: #selector(didEndChangeTextField(sender:)), for: .editingDidEnd)
    }

    @objc func didEndChangeTextField(sender: UITextField) {
        print("did end change")
        sender.isUserInteractionEnabled = sender.isFirstResponder
    }

    @objc func changeSummOfTextField(sender: UITextField) {
        guard let summText = sender.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil) else { return }
        guard let summ = Int(summText) else { return }
        if summ < 3000, summ > 100000 {
            delegate?.getLimitError(flagError: true)
        } else {
            delegate?.getLimitError(flagError: false)
        }
        sender.text = formatingNumber(number: summ)
    }

    @objc func sliderChangeValue(sender: UISlider) {
        let trackRect = sender.trackRect(forBounds: sender.bounds)
        let thumbRect = sender.thumbRect(forBounds: sender.bounds, trackRect: trackRect, value: sender.value)

        circleView.frame.origin.x = thumbRect.minX
        rectangleChangePosition()
        curveCanvasShapeLayer.path = curvePath()
        maskShapeLayer.path = curvePathMask()
        backgroundView.layer.mask = maskShapeLayer
        delegate?.getSliderPercent(summm: Int(round(sender.value / 1000)) * 1000)
//        summTextField.text = formatingNumber(number: Int(round(sender.value / 1000)) * 1000)
    }

    func formatingNumber(number: Int) -> String {
        var temp = String(number)
        var index = 1
        if number >= 10000, number < 100000 {
            index += 1
            temp.insert(contentsOf: " ", at: temp.index(temp.startIndex, offsetBy: index))
        } else if number == 100000 {
            index += 2
            temp.insert(contentsOf: " ", at: temp.index(temp.startIndex, offsetBy: index))
        } else if number < 10000, number >= 3000 {
            temp.insert(contentsOf: " ", at: temp.index(temp.startIndex, offsetBy: index))
            index = 1
        }
        return temp
    }

    func rectangleChangePosition() {
        let width = containerView.bounds.width
        var deltaXItems: CGFloat = 10.0
        changePostitionControlPoints()

        for item in 0 ..< countOfRect {
            if allView[item].frame.origin.x <= circleView.frame.maxX - 8 {
                allView[item].backgroundColor = UIColor(named: "5243C2")
            } else {
                allView[item].backgroundColor = UIColor(named: "444444")
            }

            if deltaXItems >= leftStartCurve.getLayerPosition(flag: flag).x, deltaXItems <= rightEndCurve.getLayerPosition(flag: flag).x {
                let t = getPercentWayOfBezierPath(lineDelta: deltaCurrentLines(line: deltaXItems), fullPercentDelta: deltaStartAndEndPoint())

                UIView.animate(withDuration: 0.05) {
                    self.allView[item].center.y = self.calculateBezierPath(tPercentOfWay: t).y - 33.0
                }
            } else {
                UIView.animate(withDuration: 0.05) {
                    self.allView[item].center.y = self.circleView.frame.minY - 10.0
                }
            }
            deltaXItems += width / 20.0
        }
    }

    func createRectangle() {
        let width = containerView.bounds.width
        var deltaXItems: CGFloat = 7

        for item in 1 ... countOfRect {
            if item == 1 {
                let localView = UIView(frame: CGRect(x: deltaXItems, y: containerView.bounds.midY - 20.0, width: 3.0, height: 19.0))
                localView.layer.cornerRadius = 2.0
                localView.backgroundColor = UIColor.lightGray
                allView.append(localView)
                containerView.addSubview(localView)
            } else {
                deltaXItems += width / 20.0
                let localView = UIView(frame: CGRect(x: deltaXItems, y: containerView.bounds.midY - 20.0, width: 3.0, height: 19.0))
                localView.layer.cornerRadius = 2.0
                localView.backgroundColor = UIColor.lightGray
                allView.append(localView)
                containerView.addSubview(localView)
            }
        }
    }

    func settingsDisplayRefresh() {
        refreshScale = CADisplayLink(target: self, selector: #selector(refreshDisplay))
        refreshScale?.add(to: .main, forMode: .default)
        refreshScale?.isPaused = true
    }

    @objc func refreshDisplay() {
        rectangleChangePosition()
        curveCanvasShapeLayer.path = curvePath()
        maskShapeLayer.path = curvePathMask()
        backgroundView.layer.mask = maskShapeLayer
    }

    func curvePath() -> CGPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: containerView.bounds.minX, y: circleView.frame.minY + 15))
        path.addLine(to: leftStartCurve.getLayerPosition(flag: flag))
        path.addCurve(to: topControl.getLayerPosition(flag: flag), controlPoint1: leftSideControlPoint1.getLayerPosition(flag: flag), controlPoint2: leftSideControlPoint2.getLayerPosition(flag: flag))
        path.addCurve(to: rightEndCurve.getLayerPosition(flag: flag), controlPoint1: rightSideControlPoint1.getLayerPosition(flag: flag), controlPoint2: rightSideControlPoint2.getLayerPosition(flag: flag))
        path.addLine(to: CGPoint(x: containerView.bounds.maxX, y: circleView.frame.minY + 15))
        pathBounds = path.bounds
        path.flatness = 1.0

        return path.cgPath
    }

    func changePostitionControlPoints() {
        leftStartCurve.center = CGPoint(x: circleView.frame.minX - 13.0, y: circleView.frame.minY + 15)
        leftSideControlPoint1.center = CGPoint(x: circleView.frame.minX - 1, y: circleView.frame.midY - 6.0)
        leftSideControlPoint2.center = CGPoint(x: circleView.frame.minX - 1.5, y: circleView.frame.minY - 3.8)

        topControl.center = CGPoint(x: circleView.frame.midX, y: circleView.frame.minY - 5.5)

        rightSideControlPoint1.center = CGPoint(x: circleView.frame.maxX + 1.5, y: circleView.frame.minY - 3.8)
        rightSideControlPoint2.center = CGPoint(x: circleView.frame.maxX + 1.0, y: circleView.frame.midY - 6.0)
        rightEndCurve.center = CGPoint(x: circleView.frame.maxX + 13.0, y: circleView.frame.minY + 15)
    }

    func deltaCurrentLines(line: CGFloat) -> CGFloat {
        let deltaLineOfScale = line - 10.0
        let deltaBetweenPoints = deltaLineOfScale - leftStartCurve.getLayerPosition(flag: flag).x
        return deltaBetweenPoints
    }

    func getPercentWayOfBezierPath(lineDelta: CGFloat, fullPercentDelta: CGFloat) -> CGFloat {
        return lineDelta / fullPercentDelta
    }

    func deltaStartAndEndPoint() -> CGFloat {
        let deltaStart: CGFloat = leftStartCurve.getLayerPosition(flag: flag).x - 15
        let deltaEnd: CGFloat = rightEndCurve.getLayerPosition(flag: flag).x - 20

        let deltaBetweenPoints = deltaEnd - deltaStart

        return deltaBetweenPoints
    }

    func calculateBezierPath(tPercentOfWay: CGFloat) -> CGPoint {
        var summOfPointX = CGFloat(0)
        var summOfPointY = CGFloat(0)

        let oneMinusPercent: CGFloat = (CGFloat(1) - CGFloat(tPercentOfWay))

        let firstX = pow(oneMinusPercent, 4) * leftStartCurve.frame.midX
        let firstY = pow(oneMinusPercent, 4) * leftStartCurve.frame.maxY

        let secondX = 4 * pow(oneMinusPercent, 3) * tPercentOfWay * leftSideControlPoint1.frame.midX
        let secondY = 4 * pow(oneMinusPercent, 3) * tPercentOfWay * leftSideControlPoint1.frame.minY

        let thirdX = 6 * pow(oneMinusPercent, 2) * pow(tPercentOfWay, 2) * topControl.frame.midX
        let thirdY = 6 * pow(oneMinusPercent, 2) * pow(tPercentOfWay, 2) * topControl.frame.minY

        let fourhtX = 4 * oneMinusPercent * pow(tPercentOfWay, 3) * rightSideControlPoint1.frame.minX - 5
        let fourhtY = 4 * oneMinusPercent * pow(tPercentOfWay, 3) * rightSideControlPoint2.frame.maxY + 0.5

        let fivethX = pow(tPercentOfWay, 4) * rightEndCurve.frame.midX
        let fivethY = pow(tPercentOfWay, 4) * leftStartCurve.frame.maxY + 0.5

        summOfPointX += firstX + secondX + thirdX + fourhtX + fivethX
        summOfPointY += firstY + secondY + thirdY + fourhtY + fivethY

        return CGPoint(x: summOfPointX, y: summOfPointY)
    }

    // MARK: - MANUAL move to

    func moveCircleTo(move: Float) {
        nativeSlider.setValue(move, animated: false)
        getCoordinateNativeSlider()

        circleView.frame.origin.x = nativeSliderCoordinateX
        rectangleChangePosition()
        curveCanvasShapeLayer.path = curvePath()
        maskShapeLayer.path = curvePathMask()
        backgroundView.layer.mask = maskShapeLayer
    }

    func moveCircleFrame() {
        flag = true
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            self.circleView.frame.origin.x = 0.0
        } completion: { [weak self] flag in
            guard let self = self else { return }
            self.flag = false
        }
    }

    // MARK: - get coordinate nativeSlider

    func getCoordinateNativeSlider() {
        let trackRect = nativeSlider.trackRect(forBounds: nativeSlider.bounds)
        let thumbRect = nativeSlider.thumbRect(forBounds: nativeSlider.bounds, trackRect: trackRect, value: nativeSlider.value)
        nativeSliderCoordinateX = thumbRect.minX
    }

//    @objc func editButtonAction(sender: UIButton) {
//        if summTextField.isFirstResponder {
//            summTextField.isUserInteractionEnabled = false
//            summTextField.resignFirstResponder()
//        } else {
//            summTextField.isUserInteractionEnabled = true
//            summTextField.becomeFirstResponder()
//        }
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - delegate for change positions and data transfer percent of way

protocol DelegateChangeSlider: AnyObject {
    func getSliderPercent(summm: Int)
    func getLimitError(flagError: Bool)
}

extension UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

extension CustomSliderV: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let trimmed = textField.text!.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
//        let result = summValidation(trimmedText: trimmed, countReplacement: string.count, replacementString: string)
//        textField.text = result.1
//        return true
//    }

//    func summValidation(trimmedText: String, countReplacement: Int, replacementString: String) -> Bool {
//        if let summ = trimmed {
//            let temp = summ + string
//            let number: Int? = Int(temp)
//            print(number)
//        }
//        var text: String = trimmedText
//        if countReplacement == 1 {
//            text = text.appending(replacementString)
//            guard let summ = Int(text) else { return false }
//            if summ >= 3000, summ <= 100000 {
//                return true
//            } else {
//                return false
//            }
//        } else {
//            text.removeLast()
//            guard let summ = Int(text) else { return false }
//            if summ >= 3000, summ <= 100000 {
//                return true
//            } else {
//                return false
//            }
//        }
//    }
}

private extension CustomSliderV {
    func makeShapeLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 2.5
        layer.strokeColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.shadowOpacity = 1.0
        return layer
    }

    func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        // swiftlint:disable force_unwrapping
        layer.colors = [UIColor(named: "84FFFF")!.cgColor,
                        UIColor(named: "84FFFF")!.cgColor,
                        UIColor(named: "84FFFF100")!.cgColor,
                        UIColor(named: "8C82FF")!.cgColor,
                        UIColor(named: "8C82FF")!.cgColor,
                        UIColor(named: "84FFFF")!.cgColor,
                        UIColor(named: "84FFFF")!.cgColor]
        // swiftlint:enable force_unwrapping
        layer.actions = ["startPoint": NSNull(), "endPoint": NSNull(), "colors": NSNull()]
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.locations = [0.0, 0.03, 0.3, 0.6, 0.8, 0.98, 1.0]
        return layer
    }

    func makeCircleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.frame.size = CGSize(width: 40, height: 40)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }

    func makeBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "222222backgroundSlider")
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }

    func makeControlPointView() -> UIView {
        let pointView = UIView()
        pointView.frame.size = CGSize(width: 5.0, height: 5.0)
        pointView.translatesAutoresizingMaskIntoConstraints = false
        pointView.backgroundColor = UIColor.clear
        return pointView
    }

    func makeSliderView() -> UISlider {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumValue = 3000
        view.maximumValue = 100000
        view.minimumTrackTintColor = UIColor.clear
        view.maximumTrackTintColor = UIColor.clear
        return view
    }

    func makeMaskShapelayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.actions = ["fillColor": NSNull(), "path": NSNull(), "backgroundColor": NSNull()]
        layer.lineCap = .butt
        layer.lineJoin = .round
        layer.fillColor = UIColor(named: "222222backgroundSlider")?.cgColor
        return layer
    }

    func makeEditButton() -> UIButton {
        let temp = UIButton()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.setImage(UIImage(named: "slider_edit_button"), for: .normal)
//        temp.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        return temp
    }

//    func makeUItextField() -> UITextField {
//        let temp = UITextField()
//        temp.translatesAutoresizingMaskIntoConstraints = false
//        temp.textAlignment = .center
//        temp.text = "3 000"
//        temp.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight(rawValue: 700))
//        temp.textColor = .white
//        temp.tintColor = UIColor(hexFromString: "#5243C2")
//        temp.keyboardType = .numberPad
//        temp.keyboardAppearance = .dark
//        temp.isUserInteractionEnabled = false
//        temp.delegate = self
//        return temp
//    }

    func makeContainer() -> UIView {
        let temp = UIView()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.backgroundColor = .clear
        return temp
    }

    func makeCurrencyImage() -> UIImageView {
        let temp = UIImageView()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.image = UIImage(named: "som_currency1")?.withRenderingMode(.alwaysTemplate)
        temp.tintColor = .white
        temp.contentMode = .scaleAspectFit
        return temp
    }
}
