//
//  ColorPickerView.swift
//  Notes
//
//  Created by Sergey on 15/07/2019.
//  Copyright © 2019 Sergey Akentev. All rights reserved.
//

import Foundation
import UIKit

//
// Utilities
//

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let (red, green, blue, _) = rgba
        return (red, green, blue)
    }
    
    convenience init?(named name: String) {
        let color: UIColor
        switch name {
        case "BorderColor": color = #colorLiteral(red: 0.7089999914, green: 0.7089999914, blue: 0.7089999914, alpha: 1)
        case "LabelTextsColor": color = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        case "LightBorderColor": color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.200000003)
        case "ThumbViewWideBorderColor": color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6999999881)
        case "ThumbViewWideBorderDarkColor": color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3000000119)
        default:
            NSLog("FlexColorPicker: Unknow named color requested with name: \(name). Falling back to default color (grey).")
            color = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
        self.init(cgColor: color.cgColor)
    }
    
    public var hsbColor: HSBColor {
        return HSBColor(color: self)
    }
    
    public func hexValue(alwaysIncludeAlpha: Bool = false) -> String {
        let (red, green, blue, alpha) = rgba
        let r = colorComponentToUInt8(red)
        let g = colorComponentToUInt8(green)
        let b = colorComponentToUInt8(blue)
        let a = colorComponentToUInt8(alpha)
        
        if alpha == 1 && !alwaysIncludeAlpha {
            return String(format: "%02lX%02lX%02lX", r, g, b)
        }
        return String(format: "%02lX%02lX%02lX%02lX", r, g, b, a)
    }
    
}

@inline(__always)
public func colorComponentToUInt8(_ component: CGFloat) -> UInt8 {
    return UInt8(max(0, min(255, round(255 * component))))
}

public func rgbFrom(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    let hPrime = Int(hue * 6)
    let f = hue * 6 - CGFloat(hPrime)
    let p = brightness * (1 - saturation)
    let q = brightness * (1 - f * saturation)
    let t = brightness * (1 - (1 - f) * saturation)
    
    switch hPrime % 6 {
    case 0: return (brightness, t, p)
    case 1: return (q, brightness, p)
    case 2: return (p, brightness, t)
    case 3: return (p, q, brightness)
    case 4: return (t, p, brightness)
    default: return (brightness, p, q)
    }
}

public func foregroundImage(_ intWidth: Int, _ intHeight: Int) -> UIImage {
    var imageData = [UInt8](repeating: 1, count: (4 * intWidth * intHeight))
    for i in 0 ..< intWidth {
        for j in 0 ..< intHeight {
            let index = 4 * (i + j * intWidth)
            let hue: CGFloat = CGFloat(max (0, min(1, CGFloat(j) / CGFloat(intHeight))))
            let saturation: CGFloat = CGFloat(1 - max(0, min(1, CGFloat(i) / CGFloat(intWidth))))
            let (r, g, b) = rgbFrom(hue: hue, saturation: saturation, brightness: 1)
            imageData[index] = colorComponentToUInt8(r)
            imageData[index + 1] = colorComponentToUInt8(g)
            imageData[index + 2] = colorComponentToUInt8(b)
            imageData[index + 3] = 255
        }
    }
    return UIImage(rgbaBytes: imageData, width: intWidth, height: intHeight) ?? UIImage()
}

public func backgroundImage(_ intWidth: Int, _ intHeight: Int) -> UIImage? {
    let size = CGSize(width: intWidth, height: intHeight)
    if size.width == 0 || size.height == 0 {
        return nil
    }
    return UIImage.drawImage(ofSize: size, path: UIBezierPath(rect: CGRect(origin: .zero, size: size)), fillColor: .black)
}

extension UIImage {
    public convenience init?(rgbaBytes: [UInt8], width: Int, height: Int) {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let data = Data(rgbaBytes)
        let mutableData = UnsafeMutableRawPointer.init(mutating: (data as NSData).bytes)
        let context = CGContext(data: mutableData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        guard let cgImage = context?.makeImage() else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    public static func drawImage(ofSize size: CGSize, path: UIBezierPath, fillColor: UIColor) -> UIImage? {
        let imageRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fillColor.cgColor)
        context?.addPath(path.cgPath)
        context?.drawPath(using: .fill)
        defer {
            UIGraphicsEndImageContext()
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return nil
    }
}

extension UIImageView {
    func convertToImageSpace(point: CGPoint) -> CGPoint {
        return transform(point: point, toImageSpace: true)
    }
    
    func convertFromImageSpace(point: CGPoint) -> CGPoint {
        return transform(point: point, toImageSpace: false)
    }
    
    private func transform(point: CGPoint, toImageSpace: Bool) -> CGPoint {
        guard let contentSize = image?.size else {
            return point
        }
        let multiplier: CGFloat = toImageSpace ? -1 : 1
        let verticalDiff = (bounds.height - contentSize.height) * multiplier
        let horizontalDiff = (bounds.width - contentSize.width) * multiplier
        return CGPoint(
            x: adjustedCoordinate(for: point.x, axisAlignment: contentMode.horizontalAlighnment, difference: horizontalDiff),
            y: adjustedCoordinate(for: point.y, axisAlignment: contentMode.verticalAlighnment, difference: verticalDiff)
        )
    }
    
    private func adjustedCoordinate(for coordinate: CGFloat, axisAlignment: Alighnment, difference: CGFloat) -> CGFloat {
        switch axisAlignment {
        case .begining: return coordinate
        case .center: return coordinate + difference / 2
        case .end: return coordinate + difference
        }
    }
}

private enum Alighnment {
    case begining, center, end
}

fileprivate extension UIView.ContentMode {
    var verticalAlighnment: Alighnment {
        switch self {
        case .bottom, .bottomLeft, .bottomRight: return .end
        case .center, .left, .right, .scaleAspectFit, .scaleAspectFill, .scaleToFill, .redraw: return .center
        case .top, .topRight, .topLeft: return .begining
        @unknown default:
            fatalError()
        }
    }
    
    var horizontalAlighnment: Alighnment {
        switch self {
        case .left, .topLeft, .bottomLeft: return .begining
        case .top, .center, .bottom, .scaleAspectFit, .scaleAspectFill, .scaleToFill, .redraw: return .center
        case .right, .topRight, .bottomRight: return .end
        @unknown default:
            fatalError()
        }
    }
}

extension UIView {
    
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @objc
    var cornerRadius_: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

public struct HSBColor: Hashable {
    public let hue: CGFloat
    public let saturation: CGFloat
    public let brightness: CGFloat
    public let alpha: CGFloat
    
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1) {
        self.hue = max(0, min(1, hue))
        self.saturation = max(0, min(1, saturation))
        self.brightness = max(0, min(1, brightness))
        self.alpha = max(0, min(1, alpha))
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        return rgbFrom(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    init(color: UIColor) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public func asTuple() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        return (hue, saturation, brightness, alpha)
    }
    
    public func asTupleNoAlpha() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        return (hue, saturation, brightness)
    }
    
    public func toUIColor() -> UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public func withHue(_ hue: CGFloat, andSaturation saturation: CGFloat) -> HSBColor {
        return HSBColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public func withBrightness(_ brightness: CGFloat) -> HSBColor {
        return HSBColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public static func == (l: HSBColor, r: HSBColor) -> Bool {
        return l.hue == r.hue && l.saturation == r.saturation && l.brightness == r.brightness && l.alpha == r.alpha
    }
}

fileprivate extension UIView {
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return topAnchor
    }
    
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
}

//
// Controls
//

let defaultSelectedColor = UIColor.white.hsbColor
let defaultHitBoxInset: CGFloat = 16
private let defaultTextColor: UIColor = UIColor(named: "LabelTextsColor") ?? .black
private let defaultCornerradius: CGFloat = 5
private let defaultExpandedUpscaleRatio: CGFloat = 1.6

class AbstractColorControl: UIControl {
    private let defaultBorderWidth: CGFloat = 1 / UIScreen.main.scale
    
    private(set) public var selectedHSBColor: HSBColor = defaultSelectedColor
    
    var selectedColor: UIColor {
        get {
            return selectedHSBColor.toUIColor()
        }
        set {
            selectedHSBColor = newValue.hsbColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    func commonInit() {
        isExclusiveTouch = true
    }
    
    func setSelectedHSBColor(_ hsbColor: HSBColor) {
        selectedHSBColor = hsbColor
    }
    
    func locationForTouches(_ touches: Set<UITouch>) -> CGPoint? {
        return touches.first?.location(in: self)
    }
    
    func setDefaultBorder(on: Bool, forView view: UIView) {
        view.borderColor = UIColor(named: "BorderColor")
        view.borderWidth = on ? defaultBorderWidth : 0
    }
}

class ColorPreviewWithHex: AbstractColorControl {
    private let confirmAnimationScaleRatio: CGFloat = 0.87
    private let confirmAnimationSpringDamping: CGFloat = 0.7
    private let confirmAnimationDuration = 0.3
    private let hexHeight: CGFloat = 20
    private let hexFont = UIFont.systemFont(ofSize: 12)
    
    private let colorView = UIView()
    private let hexLabel = UILabel()
    
    private var labelHeightConstraint = NSLayoutConstraint()
    
    var tapToConfirm: Bool = true
    
    override var frame: CGRect {
        didSet {
            updateCornerRadius()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(65), height: CGFloat(90))
    }
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(colorView)
        addSubview(hexLabel)
        
        colorView.translatesAutoresizingMaskIntoConstraints = true
        hexLabel.translatesAutoresizingMaskIntoConstraints = true
        
        hexLabel.textColor = defaultTextColor
        hexLabel.textAlignment = .center
        hexLabel.font = hexFont
        setDefaultBorder(on: true, forView: self)
        setSelectedHSBColor(selectedHSBColor)
        updateCornerRadius()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = self.bounds
        hexLabel.frame = CGRect(
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.maxY - hexHeight),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: hexHeight)
        )
        colorView.frame = CGRect(
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.minY),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: viewBounds.maxY - viewBounds.minY - hexHeight)
        )
    }
    
    override func setSelectedHSBColor(_ hsbColor: HSBColor) {
        super.setSelectedHSBColor(hsbColor)
        let color = selectedColor
        colorView.backgroundColor = color
        hexLabel.text = "#\(color.hexValue())"
    }
    
    private func handleTouchDown() {
        guard tapToConfirm else {
            return
        }
        UIView.animate(withDuration: confirmAnimationDuration, delay: 0, usingSpringWithDamping: confirmAnimationSpringDamping, initialSpringVelocity: 0, options: [], animations: {
            self.layer.transform = CATransform3DMakeScale(self.confirmAnimationScaleRatio, self.confirmAnimationScaleRatio, 1)
        }, completion: nil)
    }
    
    private func handleTouchUp(valid: Bool) {
        guard tapToConfirm else {
            return
        }
        UIView.animate(withDuration: confirmAnimationDuration, delay: 0, usingSpringWithDamping: confirmAnimationSpringDamping, initialSpringVelocity: 0, options: [], animations:  {
            self.layer.transform = CATransform3DIdentity
        }) { _ in
            if valid {
                self.sendActions(for: .primaryActionTriggered)
            }
        }
    }
    
    private func updateCornerRadius() {
        cornerRadius_ = min(defaultCornerradius, bounds.height / 2, bounds.width / 2)
        if cornerRadius_ > 0 {
            clipsToBounds = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches), point(inside: location, with: event) else {
            return
        }
        handleTouchDown()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches) else {
            return
        }
        handleTouchUp(valid: point(inside: location, with: event))
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchUp(valid: false)
        super.touchesCancelled(touches, with: event)
    }
}

class UIViewWithCommonInit: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    func commonInit() {
    }
    
}

class CircleShapedView: UIViewWithCommonInit {
    
    override var frame: CGRect {
        didSet {
            updateCornerRadius()
        }
    }
    
    override func commonInit() {
        super.commonInit()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        cornerRadius_ = min(bounds.height, bounds.width) / 2
    }
    
}

class ColorPickerThumbView: UIViewWithCommonInit {
    private let defaultWideBorderWidth: CGFloat = 6
    private let expansionAnimationDuration = 0.3
    private let collapsingAnimationDelay = 0.1
    private let borderDarkeningAnimationDuration = 0.3
    private let expansionAnimationSpringDamping: CGFloat = 0.7
    private let brightnessToChangeToDark: CGFloat = 0.3
    private let saturationToChangeToDark: CGFloat = 0.4
    private let textLabelUpShift: CGFloat = 12
    // private let maxContrastRatioWithWhiteToDarken: CGFloat = 0.25
    private let percentageTextFont = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    private let colorPickerThumbViewDiameter: CGFloat = 28
    private let borderView = CircleShapedView()
    private let colorView = CircleShapedView()
    private let percentageLabel = UILabel()
    var autoDarken: Bool = true
    var showPercentage: Bool = true
    var expandOnTap: Bool = true
    
    var expandedUpscaleRatio: CGFloat = defaultExpandedUpscaleRatio {
        didSet {
            if isExpanded {
                setExpanded(true, animated: true)
            }
        }
    }
    
    public private(set) var color: UIColor = defaultSelectedColor.toUIColor()
    
    var percentage: Int = 0 {
        didSet {
            updatePercentage(percentage)
        }
    }
    
    public private(set) var isExpanded = false
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: colorPickerThumbViewDiameter, height: colorPickerThumbViewDiameter)
    }
    
    var wideBorderWidth: CGFloat {
        return defaultWideBorderWidth
    }
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(borderView)
        addSubview(colorView)
        addSubview(percentageLabel)
        
        borderView.translatesAutoresizingMaskIntoConstraints = true
        colorView.translatesAutoresizingMaskIntoConstraints = true
        percentageLabel.translatesAutoresizingMaskIntoConstraints = true
        
        borderView.borderColor = UIColor(named: "BorderColor")
        borderView.borderWidth = 1 / UIScreen.main.scale
        percentageLabel.font = percentageTextFont
        percentageLabel.textColor = defaultTextColor
        percentageLabel.textAlignment = .center
        percentageLabel.alpha = 0
        clipsToBounds = false
        borderView.backgroundColor = UIColor(named: "ThumbViewWideBorderColor")
        setColor(color)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = self.bounds
        borderView.frame = CGRect (
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.minY),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: viewBounds.maxY - viewBounds.minY)
        )
        colorView.frame = CGRect (
            origin: CGPoint(x: viewBounds.minX + defaultWideBorderWidth, y: viewBounds.minY + defaultWideBorderWidth),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX - 2 * defaultWideBorderWidth, height: viewBounds.maxY - viewBounds.minY - 2 * defaultWideBorderWidth)
        )
        let percentageLabelSize = percentageLabel.intrinsicContentSize
        percentageLabel.frame = CGRect(
            center: CGPoint(x: viewBounds.maxX / 2, y: viewBounds.minY - percentageLabelSize.height),
            size: percentageLabelSize
        )
    }
    
    func setColor(_ color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
        setDarkBorderIfNeeded()
    }
    
    func updatePercentage(_ percentage: Int) {
        percentageLabel.text = String(min(100, max(0, percentage))) + "%"
        setNeedsLayout()
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        let transform = expanded && expandOnTap ? CATransform3DMakeScale(expandedUpscaleRatio, expandedUpscaleRatio, 1) : CATransform3DIdentity
        let textLabelRaiseAmount: CGFloat = expanded && expandOnTap ? (bounds.height / 2) * defaultExpandedUpscaleRatio + textLabelUpShift : (bounds.height / 2)  + textLabelUpShift
        let labelTransform = CATransform3DMakeTranslation(0, -textLabelRaiseAmount, 0)
        isExpanded = expanded
        
        UIView.animate(withDuration: animated ? expansionAnimationDuration : 0, delay: expanded ? 0 : collapsingAnimationDelay, usingSpringWithDamping: expansionAnimationSpringDamping, initialSpringVelocity: 0, options: [], animations: {
            self.borderView.layer.transform = transform
            self.colorView.layer.transform = transform
            self.percentageLabel.layer.transform = labelTransform
            self.percentageLabel.alpha = expanded && self.showPercentage ? 1 : 0
        }, completion: nil)
    }
    
    func setDarkBorderIfNeeded(animated: Bool = true) {
        let (_, s, b) = color.hsbColor.asTupleNoAlpha()
        let isBorderDark = autoDarken && 1 - b < brightnessToChangeToDark && s < saturationToChangeToDark
        
        #if TARGET_INTERFACE_BUILDER
        setWideBorderColors(isBorderDark) //animations do not work
        #else
        UIView.animate(withDuration: animated ? borderDarkeningAnimationDuration : 0) {
            self.setWideBorderColors(isBorderDark)
        }
        #endif
    }
    
    var colorIdicatorRadius: CGFloat {
        return bounds.width / 2 - defaultWideBorderWidth
    }
    
    private func setWideBorderColors(_ isDark: Bool) {
        self.borderView.borderColor = UIColor(named: isDark ? "BorderColor" : "LightBorderColor")
        self.borderView.backgroundColor = UIColor(named: isDark ? "ThumbViewWideBorderDarkColor" : "ThumbViewWideBorderColor")
    }
}

class ColorControlWithThumbView: AbstractColorControl {
    
    let contentView = UIView()
    let thumbView = ColorPickerThumbView()
    
    var contentBounds: CGRect {
        layoutIfNeeded()
        return contentView.frame
    }
    
    var hitBoxInsets = UIEdgeInsets(top: defaultHitBoxInset, left: defaultHitBoxInset, bottom: defaultHitBoxInset, right: defaultHitBoxInset) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var alignmentRectInsets: UIEdgeInsets {
        return hitBoxInsets
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(100))
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = self.bounds
        contentView.frame = CGRect(
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.minY),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: viewBounds.maxY - viewBounds.minY)
        )
    }
    
    override func locationForTouches(_ touches: Set<UITouch>) -> CGPoint? {
        guard let location = super.locationForTouches(touches) else {
            return nil
        }
        return convert(location, to: contentView)
    }
    
    func updateSelectedColor(at point: CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches) else {
            return
        }
        thumbView.setExpanded(true, animated: true)
        updateSelectedColor(at: location)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches) else {
            return
        }
        updateSelectedColor(at: location)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches) else {
            return
        }
        updateSelectedColor(at: location)
        thumbView.setExpanded(false, animated: true)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = locationForTouches(touches) else {
            return
        }
        updateSelectedColor(at: location)
        thumbView.setExpanded(false, animated: true)
        super.touchesCancelled(touches, with: event)
    }
    
}

class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private var startColor: UIColor = .clear
    private var endColor: UIColor = .clear
    private var startOffset: CGFloat = 0
    private var endOffset: CGFloat = 0
    
    func setupGradient(startColor: UIColor, endColor: UIColor, startOffset: CGFloat, endOffset: CGFloat) {
        self.startColor = startColor
        self.endColor = endColor
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.startOffset = startOffset
        self.endOffset = endOffset
        updatePoints()
    }
    
    override var frame: CGRect {
        didSet {
            updatePoints()
        }
    }
    
    func updatePoints() {
        gradientLayer.startPoint = CGPoint(x: startOffset / bounds.width, y: 0.5)
        gradientLayer.endPoint.x = 1 - endOffset / bounds.width
        gradientLayer.endPoint.y = 0.5
    }
    
}

class BrightnessSliderControl: ColorControlWithThumbView {
    
    private let gradientBackgroundView = UIImageView()
    private let gradientView = GradientView()
    
    private func modifiedColor(from color: HSBColor, with value: CGFloat) -> HSBColor {
        return color.withBrightness(1 - value)
    }
    
    private func valueAndGradient(for color: HSBColor) -> (value: CGFloat, gradientStart: UIColor, gradientEnd: UIColor) {
        return (1 - color.brightness, color.withBrightness(1).toUIColor(), color.withBrightness(0).toUIColor())
    }
    
    override var frame: CGRect {
        didSet {
            updateCornerRadius()
            updateThumbAndGradient()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(15))
    }
    
    override func commonInit() {
        super.commonInit()
        
        contentView.addSubview(gradientBackgroundView)
        gradientBackgroundView.addSubview(gradientView)
        
        gradientBackgroundView.translatesAutoresizingMaskIntoConstraints = true
        gradientView.translatesAutoresizingMaskIntoConstraints = true
        
        updateCornerRadius()
        gradientBackgroundView.clipsToBounds = true
        updateThumbAndGradient()
        contentView.addSubview(thumbView)
        setDefaultBorder(on: true, forView: gradientBackgroundView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = contentView.bounds
        gradientBackgroundView.frame = CGRect(
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.minY),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: viewBounds.maxY - viewBounds.minY)
        )
        let backgroundBounds = gradientBackgroundView.bounds
        gradientView.frame = CGRect(
            origin: CGPoint(x: backgroundBounds.minX, y: backgroundBounds.minY),
            size: CGSize(width: backgroundBounds.maxX - backgroundBounds.minX, height: backgroundBounds.maxY - backgroundBounds.minY)
        )
    }
    
    override func setSelectedHSBColor(_ hsbColor: HSBColor) {
        super.setSelectedHSBColor(hsbColor)
        updateThumbAndGradient()
    }
    
    private func updateCornerRadius() {
        gradientBackgroundView.cornerRadius_ = contentBounds.height / 2
    }
    
    func updateThumbAndGradient() {
        layoutIfNeeded()
        let (value, gradientStart, gradientEnd) = valueAndGradient(for: selectedHSBColor)
        let gradientLength = contentBounds.width - thumbView.colorIdicatorRadius * 2
        thumbView.frame = CGRect(center: CGPoint(x: thumbView.colorIdicatorRadius + gradientLength * min(max(0, value), 1), y: contentView.bounds.midY), size: thumbView.intrinsicContentSize)
        thumbView.setColor(selectedHSBColor.toUIColor())
        gradientView.setupGradient(startColor: gradientStart, endColor: gradientEnd, startOffset: thumbView.colorIdicatorRadius, endOffset: thumbView.colorIdicatorRadius)
    }
    
    override func updateSelectedColor(at point: CGPoint) {
        let gradientLength = contentBounds.width - thumbView.colorIdicatorRadius * 2
        let value = max(0, min(1, (point.x - thumbView.colorIdicatorRadius) / gradientLength))
        thumbView.percentage = Int(round(value * 100))
        setSelectedHSBColor(modifiedColor(from: selectedHSBColor, with: min(max(0, value), 1)))
        sendActions(for: .valueChanged)
    }
    
}

class RectangularPaletteControl: ColorControlWithThumbView {
    private let minimumDistanceForInBoundsTouchFromValidPoint: CGFloat = 44
    private var intWidth = 0
    private var intHeight = 0
    
    let foregroundImageView = UIImageView()
    let backgroundImageView = UIImageView()
    
    var size: CGSize = .zero {
        didSet {
            intWidth = Int(size.width)
            intHeight = Int(size.height)
        }
    }
    
    override var frame: CGRect {
        didSet {
            updatePaletteImagesAndThumb()
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            updateContentMode()
            updateThumbPosition(position: positionAndAlpha(for: selectedHSBColor).position)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(100))
    }
    
    func modifiedColor(from color: HSBColor, with point: CGPoint) -> HSBColor {
        let hue: CGFloat = CGFloat(max (0, min(1, point.y / size.height)))
        let saturation: CGFloat = CGFloat(1 - max(0, min(1, point.x / size.width)))
        return color.withHue(hue, andSaturation: saturation)
    }
    
    func closestValidPoint(to point: CGPoint) -> CGPoint {
        return CGPoint(x: min(size.width, max(0, point.x)), y: min(size.height, max(0, point.y)))
    }
    
    func positionAndAlpha(for color: HSBColor) -> (position: CGPoint, foregroundImageAlpha: CGFloat) {
        let (hue, saturation, brightness) = color.asTupleNoAlpha()
        return (CGPoint(x: (1 - saturation) * size.width, y: (hue) * size.height), brightness)
    }
    
    func supportedContentMode(for contentMode: UIView.ContentMode) -> UIView.ContentMode {
        return contentMode
    }
    
    override func commonInit() {
        super.commonInit()
        
        setDefaultBorder(on: true, forView: contentView)
        
        contentView.addSubview(backgroundImageView)
        backgroundImageView.addSubview(foregroundImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = true
        foregroundImageView.translatesAutoresizingMaskIntoConstraints = true
        
        updateContentMode()
        contentView.addSubview(thumbView)
        updatePaletteImagesAndThumb()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = contentView.bounds
        backgroundImageView.frame = CGRect(
            origin: CGPoint(x: viewBounds.minX, y: viewBounds.minY),
            size: CGSize(width: viewBounds.maxX - viewBounds.minX, height: viewBounds.maxY - viewBounds.minY)
        )
        let backgroundBounds = backgroundImageView.bounds
        foregroundImageView.frame = CGRect(
            origin: CGPoint(x: backgroundBounds.minX, y: backgroundBounds.minY),
            size: CGSize(width: backgroundBounds.maxX - backgroundBounds.minX, height: backgroundBounds.maxY - backgroundBounds.minY)
        )
    }
    
    override func setSelectedHSBColor(_ hsbColor: HSBColor) {
        let hasChanged = selectedHSBColor != hsbColor
        super.setSelectedHSBColor(hsbColor)
        if hasChanged {
            thumbView.setColor(hsbColor.toUIColor())
            let (position, foregroundAlpha) = positionAndAlpha(for: hsbColor)
            updateThumbPosition(position: position)
            foregroundImageView.alpha = foregroundAlpha
        }
    }
    
    func updatePaletteImagesAndThumb() {
        layoutIfNeeded()
        size = foregroundImageView.bounds.size
        foregroundImageView.image = foregroundImage(intWidth, intHeight)
        backgroundImageView.image = backgroundImage(intWidth, intHeight)
        assert(foregroundImageView.image!.size.width <= size.width && foregroundImageView.image!.size.height <= size.height, "Size of rendered image must be smaller or equal specified palette size")
        assert(backgroundImageView.image == nil || foregroundImageView.image?.size == backgroundImageView.image?.size, "foreground and background images rendered must have same size")
        updateContentMode()
        updateThumbPosition(position: positionAndAlpha(for: selectedHSBColor).position)
        thumbView.setColor(selectedColor)
    }
    
    func imageCoordinates(point: CGPoint, fromCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGPoint {
        return foregroundImageView.convertToImageSpace(point: foregroundImageView.convert(point, from: coordinateSpace))
    }
    
    func imageCoordinates(point: CGPoint, toCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGPoint {
        return foregroundImageView.convert(foregroundImageView.convertFromImageSpace(point: point), to: coordinateSpace)
    }
    
    override func updateSelectedColor(at point: CGPoint) {
        let pointInside = closestValidPoint(to: imageCoordinates(point: point, fromCoordinateSpace: contentView))
        setSelectedHSBColor(modifiedColor(from: selectedHSBColor, with: pointInside))
        updateThumbPosition(position: pointInside)
        sendActions(for: .valueChanged)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let maxTouchDistance = max(hitBoxInsets.bottom, hitBoxInsets.top, hitBoxInsets.left, hitBoxInsets.right, minimumDistanceForInBoundsTouchFromValidPoint)
        let touchPoint = imageCoordinates(point: closestValidPoint(to: imageCoordinates(point: point, fromCoordinateSpace: self)), toCoordinateSpace: self)
        if sqrt(pow((touchPoint.x - point.x), 2) + pow((touchPoint.y - point.y), 2)) > maxTouchDistance {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    private func updateThumbPosition(position: CGPoint) {
        thumbView.frame = CGRect(center: imageCoordinates(point: position, toCoordinateSpace: contentView), size: thumbView.intrinsicContentSize)
    }
    
    private func updateContentMode() {
        let contentMode = supportedContentMode(for: self.contentMode)
        backgroundImageView.contentMode = contentMode
        foregroundImageView.contentMode = contentMode
    }
    
}

//
// ColorPicker
//

@IBDesignable
class ColorPickerView: UIView {
    private let sideMargin: CGFloat = 20
    private let topMargin: CGFloat = 24
    private let paletteVerticalMargin: CGFloat = 42
    private let paletteHorizontalMargin: CGFloat = 32
    private let minDistanceFromSafeArea: CGFloat = 10
    private let minSpaceAboveSlider: CGFloat = 50
    
    private(set) var selectedHSBColor: HSBColor = defaultSelectedColor
    private(set) var colorControls = [AbstractColorControl]()
    
    private var standardConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    var colorChangeHandler: (() -> Void)?
    
    let colorPreview = ColorPreviewWithHex()
    let brightnessSlider = BrightnessSliderControl()
    let colorPalette = RectangularPaletteControl()
    
    var selectedColor: UIColor {
        get {
            return selectedHSBColor.toUIColor()
        }
        set {
            setColor(newValue.hsbColor, exceptControl: nil)
        }
    }
    
    func setColor(_ selectedColor: HSBColor, exceptControl control: AbstractColorControl?) {
        for c in colorControls where c !== control {
            c.setSelectedHSBColor(selectedColor)
        }
        selectedHSBColor = selectedColor
    }
    
    func addControl(_ colorControl: AbstractColorControl) {
        colorControls.append(colorControl)
        colorControl.addTarget(self, action: #selector(colorPicked(by:)), for: .valueChanged)
        colorControl.addTarget(self, action: #selector(colorConfirmed(by:)), for: .primaryActionTriggered)
    }
    
    @objc func colorPicked(by control: Any?) {
        guard let control = control as? AbstractColorControl else {
            return
        }
        let selectedColor = control.selectedHSBColor
        setColor(selectedColor, exceptControl: control)
        colorChangeHandler?()
    }
    
    @objc func colorConfirmed(by control: Any?) {
        guard let control = control as? AbstractColorControl else {
            return
        }
        if selectedHSBColor != control.selectedHSBColor {
            colorPicked(by: control)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250, height: 400)
    }
    
    func addColorControls() {
        
        addSubview(colorPreview)
        addSubview(brightnessSlider)
        addSubview(colorPalette)
        
        addControl(colorPreview)
        addControl(brightnessSlider)
        addControl(colorPalette)
        
        colorPreview.translatesAutoresizingMaskIntoConstraints = true
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = true
        colorPalette.translatesAutoresizingMaskIntoConstraints = true
        
        brightnessSlider.hitBoxInsets = UIEdgeInsets(top: defaultHitBoxInset, left: sideMargin, bottom: defaultHitBoxInset, right: sideMargin)
        
        colorPalette.contentMode = .top
        colorPalette.hitBoxInsets = UIEdgeInsets(top: defaultHitBoxInset, left: sideMargin, bottom: defaultHitBoxInset, right: sideMargin)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewBounds = self.bounds
        let colorPreviewSize = colorPreview.intrinsicContentSize
        let brightnessSliderSize = brightnessSlider.intrinsicContentSize
        if viewBounds.size.height < viewBounds.size.width && traitCollection.verticalSizeClass != .regular {
            // landscape
            colorPalette.frame = CGRect(
                origin: CGPoint(x: (viewBounds.maxX - viewBounds.minX) / 2 + paletteHorizontalMargin / 2, y: viewBounds.minY + sideMargin),
                size: CGSize(width: CGFloat(viewBounds.maxX - viewBounds.minX) / 2 - paletteHorizontalMargin / 2 - sideMargin, height: viewBounds.maxY - viewBounds.minY - sideMargin * 2)
            )
            colorPreview.frame = CGRect(
                origin: CGPoint(x: (viewBounds.maxX - viewBounds.minX) / 4 - colorPreviewSize.width / 2, y: (viewBounds.maxY - viewBounds.minY) / 2 - colorPreviewSize.height - minSpaceAboveSlider * 0.25),
                size: colorPreviewSize
            )
            brightnessSlider.frame = CGRect(
                origin: CGPoint(x: viewBounds.minX + sideMargin, y: CGFloat(viewBounds.maxY - viewBounds.minY) / 2 + minSpaceAboveSlider * 0.75),
                size: CGSize(width: (viewBounds.maxX - viewBounds.minX) / 2 - sideMargin - paletteHorizontalMargin / 2, height: brightnessSliderSize.height)
            )
        } else {
            // portrait
            colorPreview.frame = CGRect(
                origin: CGPoint(x: viewBounds.minX + sideMargin, y: viewBounds.minY + topMargin),
                size: colorPreviewSize
            )
            brightnessSlider.frame = CGRect(
                origin: CGPoint(x: viewBounds.minX + sideMargin * 2 + colorPreviewSize.width, y: viewBounds.minY + topMargin + colorPreviewSize.height - brightnessSliderSize.height),
                size: CGSize(width: viewBounds.maxX - viewBounds.minX - sideMargin * 3 - colorPreviewSize.width, height: brightnessSliderSize.height)
            )
            colorPalette.frame = CGRect(
                origin: CGPoint(x: viewBounds.minX + sideMargin, y: viewBounds.minY + topMargin + colorPreviewSize.height + paletteVerticalMargin),
                size: CGSize(width: viewBounds.maxX - viewBounds.minX - sideMargin * 2, height: viewBounds.maxY - viewBounds.minY - topMargin - paletteVerticalMargin - sideMargin - colorPreviewSize.height)
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addColorControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addColorControls()
    }
    
}

