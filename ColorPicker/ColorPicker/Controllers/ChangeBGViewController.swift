//
//  ChangeBGViewController.swift
//  ColorPicker
//
//  Created by Sergey Ruppel on 07.09.2023.
//

import UIKit

class ChangeBGViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
        
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var alphaSlider: UISlider!
    
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blueTextField: UITextField!
    @IBOutlet weak var alphaTextField: UITextField!
    @IBOutlet weak var hexTextField: UITextField!
    @IBOutlet weak var applyByDelegatesButton: UIButton!
    @IBOutlet weak var applyByClosuresButton: UIButton!
    
    // MARK: - Properties
    
    var customColor: Color?
    var buttonsState: Bool?
    var delegate: DataUpdateProtocol?
    
    var completionHandler: ((Color) -> ())?
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - @IBActions
    
    @IBAction func slidersChanged(_ sender: UISlider) {
        changeColorBySliders(sender)
    }
    @IBAction func textFieldsAction(_ sender: UITextField) {
        changeColorByTextInput(sender)
    }
    @IBAction func hexTextFieldAction(_ sender: UITextField) {
        changeColorByHex(sender)
    }
    @IBAction func applyByDelegatesAction() {
        if let customColor { delegate?.onDataUpdate(data: customColor) }
        self.dismiss(animated: true)
    }
    @IBAction func applyByClosuresAction() {
        guard let completionHandler = completionHandler else { return }
        completionHandler(customColor!)
        
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods

    private func setupUI() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        startKeyBoardObserver()
        updateSliders()
        updateTextFields()
        if let buttonsState {
            if buttonsState {
                applyByDelegatesButton.isEnabled = true
                applyByClosuresButton.isEnabled = false
            }
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    private func changeColorBySliders(_ slider: UISlider) {
        guard customColor != nil else { return }
        switch slider.tag {
            case 1:
                customColor?.red = CGFloat(slider.value / slider.maximumValue)
            case 2:
                customColor?.green = CGFloat(slider.value / slider.maximumValue)
            case 3:
                customColor?.blue = CGFloat(slider.value / slider.maximumValue)
            case 4:
                customColor?.alpha = CGFloat(slider.value / slider.maximumValue)
            default: return
        }
        updateTextFields()
        updateHexTextField()
    }
    
    private func changeColorByTextInput(_ textField: UITextField) {
        guard customColor != nil else { return }
        switch textField.tag {
            case 1:
                if let redColorString = textField.text,
                   let redColorFloat = Float(redColorString) {
                    customColor?.red = CGFloat(redColorFloat / redSlider.maximumValue)
                }
            case 2:
                if let greenColorString = textField.text,
                   let greenColorFloat = Float(greenColorString) {
                    customColor?.green = CGFloat(greenColorFloat / greenSlider.maximumValue)
                }
            case 3:
                if let blueColorString = textField.text,
                   let blueColorFloat = Float(blueColorString) {
                    customColor?.blue = CGFloat(blueColorFloat / blueSlider.maximumValue)
                }
            case 4:
                if let alphaString = textField.text,
                   let alphaFloat = Float(alphaString) {
                    customColor?.alpha = CGFloat(alphaFloat / alphaSlider.maximumValue)
                }
            default: return
        }
        updateSliders()
    }
    
    private func changeColorByHex(_ textField: UITextField) {
        guard customColor != nil,
              let hex = textField.text else { return }
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (hexString.hasPrefix("#")) {
            hexString.removeFirst()
        }
        if ((hexString.count) > 6) {
            hexString.removeLast()
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        customColor?.red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        customColor?.green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        customColor?.blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        customColor?.alpha = CGFloat(1.0)

        updateSliders()
        updateTextFields()
    }
    
    private func updateTextFields() {
        if let customColor {
            redTextField.text = String(Int(Float(customColor.red) * redSlider.maximumValue))
            greenTextField.text = String(Int(Float(customColor.green) * greenSlider.maximumValue))
            blueTextField.text = String(Int(Float(customColor.blue) * blueSlider.maximumValue))
            alphaTextField.text = String(Int(Float(customColor.alpha) * alphaSlider.maximumValue))
        }
        updateBackgroundColor()
    }
    
    private func updateSliders() {
        if let customColor {
            redSlider.value = Float(customColor.red) * redSlider.maximumValue

            greenSlider.value = Float(customColor.green) * greenSlider.maximumValue
            blueSlider.value = Float(customColor.blue) * blueSlider.maximumValue
            alphaSlider.value = Float(customColor.alpha) * alphaSlider.maximumValue
        }

        updateBackgroundColor()
        updateHexTextField()
    }
    
    func updateHexTextField() {
        if let customColor {
            hexTextField.text = String(format: "%02lX%02lX%02lX",
                                       lroundf(Float(customColor.red * 255)),
                                       lroundf(Float(customColor.green * 255)),
                                       lroundf(Float(customColor.blue * 255)))
        }
    }
    
    func updateBackgroundColor() {
        backgroundView.backgroundColor = customColorToUIColor(customColor)
    }
    private func customColorToUIColor(_ color: Color?) -> UIColor {
        return UIColor(red: color?.red ?? 0.0,
                       green: color?.green ?? 0.0,
                       blue: color?.blue ?? 0.0,
                       alpha: color?.alpha ?? 0.0)
    }
    
    private func calculateValues(_ color: Color?, _ slider: UISlider) -> Float {
        guard let color else { return 0.0 }
        return Float(color.red) * slider.maximumValue
    }
    
    private func startKeyBoardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0.0,
                                         left: 0.0,
                                         bottom: keyboardSize.height,
                                         right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets(top: 0.0,
                                         left: 0.0,
                                         bottom: 0.0,
                                         right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
