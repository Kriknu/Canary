//
//  PaintViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-28.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import FirebaseStorage

class PaintViewController: UIViewController {
    // Canary Model
    let canaryModel: CanaryModel = CanaryModel.sharedInstance
    
    // Paint Views
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var paintView: UIView!
    
    // Top Navigation
    @IBOutlet weak var navigationMenu: UINavigationBar!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // Settings & Misc
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var opacityLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var paletteView: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var specificSettingsView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    
    // Actions
    @IBAction func settingsToggleAction(_ sender: UIButton) {
        // Make specific settings view visible
        if specificSettingsView.isHidden {
            specificSettingsView.isHidden = false
            view.bringSubview(toFront: specificSettingsView)
        } else {
            specificSettingsView.isHidden = true
        }
    }
    @IBAction func opacitySlider(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
        opacityLabel.text = "Opacity: \(Int(sender.value * 100)) %"
        setupSettingsButton()
    }
    @IBAction func sizeSlider(_ sender: UISlider) {
        brushWidth = CGFloat(sender.value*20 + 1)
        sizeLabel.text = "Size: \(Int(sender.value*100)) %"
        setupSettingsButton()
    }

    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0 / 255, 0 / 255, 0 / 255),                        // black
        (0 / 255, 214.0 / 255, 198.0 / 255),                // turquoise
        (255.0 / 255, 0 / 255, 0 / 255),                    // red
        (0 / 255, 255.0 / 255, 0 / 255),                    // green
        (0 / 255, 0 / 255, 255.0 / 255),                    // blue
        (255.0 / 255, 204.0 / 255, 0 / 255),                // yellow
        (11.0 / 255, 0 / 255, 103.0 / 255),                 // purple
        (255.0 / 255, 255.0 / 255, 255.0 / 255)             // white
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initComponents();
        //setupSettingsButtons()
        
        doneButton.action = #selector(PaintViewController.saveImage)
        cancelButton.action = #selector(PaintViewController.doSegueBack	)
        view.bringSubview(toFront: settingsView)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hide necessary views
        settingsView.isHidden = true
        specificSettingsView.isHidden = true
        
        
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: paintView)
    }
    
    func initComponents(){
        setupPaletteFrame()
        setupResetButton()
        setupSpecificSettings()
        setupSettingsButton()
    }
    
    func setupSpecificSettings(){
        setupSettingsButton()
        specificSettingsView.layer.cornerRadius = 20
        specificSettingsView.layer.masksToBounds = true
        setupOpacityComponents()
        setupSizeComponents()
    }
    
    func setupSettingsButton(){
        buttonContainer.backgroundColor = .clear
        let x = (buttonContainer.frame.width - brushWidth) / 2
        let y = (buttonContainer.frame.height - brushWidth) / 2
        settingsButton.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: brushWidth, height: brushWidth))
        settingsButton.layer.cornerRadius = settingsButton.frame.width / 2
        settingsButton.backgroundColor = color
        buttonContainer.layer.cornerRadius = buttonContainer.frame.width / 2
        buttonContainer.layer.borderColor = color.cgColor
        buttonContainer.layer.borderWidth = 2
    }
    
    func setupOpacityComponents(){
        opacityLabel.text = "Opacity: 50 %"
        opacity = 0.5
    }
    
    func setupSizeComponents(){
        sizeLabel.text = "Size: 50 %"
        brushWidth = 10.5;
    }
    
    func setupResetButton(){
        resetButton.layer.cornerRadius = resetButton.frame.width / 2
        resetButton.layer.borderWidth = 1
    }
    
    func setupPaletteFrame(){
        let colSize = (specificSettingsView.frame.width-40) / 8.0;
        var i = 0
        for entry in colors {
            let iAsFloat = CGFloat(i)
            let colorSelectView = UIControl(frame: CGRect(x: iAsFloat*colSize, y: 0, width: colSize, height: colSize))
            let colorSpot = UIView(frame: CGRect(x: colSize/4.0, y: colSize/4.0, width: colSize/2.0, height: colSize/2.0))
            colorSpot.backgroundColor = UIColor(displayP3Red: entry.0, green: entry.1, blue: entry.2, alpha: 1.0)
            colorSpot.layer.borderWidth = 1.0
            colorSpot.layer.borderColor = UIColor.black.cgColor
            colorSpot.layer.cornerRadius = colSize/4.0
            colorSelectView.addSubview(colorSpot)
            
            // Add listener and info used for color selection
            colorSelectView.isUserInteractionEnabled = true
            var ac:Selector?
            if i == 0 {
                ac = #selector(setBlackColor)
            }else if i == 1 {
                ac = #selector(setWhiteColor)
            }else if i == 2 {
                ac = #selector(setRedColor)
            }else if i == 3 {
                ac = #selector(setGreenColor)
            }else if i == 4 {
                ac = #selector(setBlueColor)
            }else if i == 5 {
                ac = #selector(setYellowColor)
            }else if i == 6 {
                ac = #selector(setPurpleColor)
            }else {
                ac = #selector(setCyanColor)
            }
            let gest: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: ac)
            gest.numberOfTapsRequired = 1
            colorSelectView.addGestureRecognizer(gest)
            i+=1
            paletteView.addSubview(colorSelectView)
        }
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(paintView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
        return
        }
        tempImageView.image?.draw(in: paintView.bounds)
        
        // 2
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        // 3
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        // 4
        context.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        // Hide saveButton when drawing
        //saveButton.isHidden = true
        
        guard let touch = touches.first else {
            return
        }
        
        // 6
        swiped = true
        let currentPoint = touch.location(in: tempImageView)
        drawLine(from: lastPoint, to: currentPoint)
        
        // 7
        lastPoint = currentPoint
    }
    
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Show necessary views
        settingsView.isHidden = false
        
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: paintView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: paintView.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
    }

    @objc func saveImage(){
        //TODO: Add error handling if we fail to upload image
        //let imageName = getImageName()
        //canaryModel.getClosestLibrary(lat: <#T##Double#>, long: <#T##Double#>)
        //self.uploadImageToFirebase(imageName)
        self.canaryModel.addMessage()
        self.doSegueBack()
    }
    
    @objc func doSegueBack(){
        self.performSegue(withIdentifier: "mainView", sender: self)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func setBlackColor(){
        color = UIColor.init(red: colors[0].0, green: colors[0].1, blue: colors[0].2, alpha: 1.0)
        setupSettingsButton()
        print("Black")
    }
    @objc func setWhiteColor(){
        color = UIColor.init(red: colors[1].0, green: colors[1].1, blue: colors[1].2, alpha: 1.0)
        print("White")
        setupSettingsButton()
    }
    @objc func setRedColor(){
        color = UIColor.init(red: colors[2].0, green: colors[2].1, blue: colors[2].2, alpha: 1.0)
        print("Red")
        setupSettingsButton()
    }
    @objc func setGreenColor(){
        color = UIColor.init(red: colors[3].0, green: colors[3].1, blue: colors[3].2, alpha: 1.0)
        print("Green")
        setupSettingsButton()
    }
    @objc func setBlueColor(){
        color = UIColor.init(red: colors[4].0, green: colors[4].1, blue: colors[4].2, alpha: 1.0)
        print("Blue")
        setupSettingsButton()
    }
    @objc func setYellowColor(){
        color = UIColor.init(red: colors[5].0, green: colors[5].1, blue: colors[5].2, alpha: 1.0)
        print("Yellow")
        setupSettingsButton()
    }
    @objc func setPurpleColor(){
        color = UIColor.init(red: colors[6].0, green: colors[6].1, blue: colors[6].2, alpha: 1.0)
        print("Purple")
        setupSettingsButton()
    }
    @objc func setCyanColor(){
        color = UIColor.init(red: colors[7].0, green: colors[7].1, blue: colors[7].2, alpha: 1.0)
        print("Cyan")
        setupSettingsButton()
    }
    
    // Actions
    @IBAction func resetButtonAction(_ sender: UIButton) {
        mainImageView.image = nil
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
    }
}
