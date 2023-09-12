//
//  MainViewController.swift
//  ColorPicker
//
//  Created by Sergey Ruppel on 07.09.2023.
//

import UIKit

protocol DataUpdateProtocol {
    func onDataUpdate(data: Color)
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var customColor = Color()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = UIColor.random
    }
    
    @IBAction func changeColorByDelegatesAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ChangeBGViewController") as? ChangeBGViewController else { return }
        
        convertUIColorToCustomColor()
        
        vc.customColor = self.customColor
        vc.buttonsState = true
        vc.delegate = self
        
        self.present(vc, animated: true)
    }
    
    @IBAction func changeColorByClosuresAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ChangeBGViewController") as? ChangeBGViewController else { return }
        
        convertUIColorToCustomColor()
        vc.customColor = self.customColor
        
        vc.completionHandler = { [weak self] newValue in
            self?.infoLabel.text = "Background color was changed by Closures"
            self?.backgroundView.backgroundColor = UIColor(
                red: newValue.red,
                green: newValue.green,
                blue: newValue.blue,
                alpha: newValue.alpha
            )
        }
        
        self.present(vc, animated: true)
    }
    
    private func convertUIColorToCustomColor() {
        guard let color = backgroundView.backgroundColor,
              let components = color.cgColor.components else { return }
        customColor.red = components[0]
        customColor.green = components[1]
        customColor.blue = components[2]
        customColor.alpha = components[3]
    }
    
}

extension MainViewController: DataUpdateProtocol {
    func onDataUpdate(data: Color) {
        self.backgroundView.backgroundColor = UIColor(
            red: data.red,
            green: data.green,
            blue: data.blue,
            alpha: data.alpha
        )
        self.infoLabel.text = "Background color was\nchanged by Delegates"
    }
}
