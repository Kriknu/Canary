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
    @IBOutlet weak var brushColor: UIImageView!
    @IBOutlet weak var specificSettingsView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var paintDot: UIView!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var sizeSlider: UISlider!
    
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
        setupSettingsButton()
    }
    @IBAction func sizeSlider(_ sender: UISlider) {
        brushWidth = CGFloat(sender.value*20 + 1)
        setupSettingsButton()
    }

    var lastPoint = CGPoint.zero
    var color = UIColor(displayP3Red: 75.0 / 255,  green: 75.0 / 255,  blue: 75.0 / 255, alpha: 1.0)
    var brushWidth: CGFloat = 11
    var opacity: CGFloat = 1.0
    var swiped = false
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (206.0 / 255,  71.0 / 255,  69.0 / 255),            // red          #CE4745 206,  71,  69
        (138.0 / 255,  66.0 / 255, 146.0 / 255),            // purple       #8A4292 138,  66, 146
        ( 52.0 / 255, 120.0 / 255, 246.0 / 255),            // blue         #3478F6  52, 120, 246
        ( 52.0 / 255, 209.0 / 255, 244.0 / 255),            // turquoise    #34D1F4  52, 209, 244
        (120.0 / 255, 184.0 / 255,  86.0 / 255),            // green        #78B856 120, 184,  86
        (242.0 / 255, 187.0 / 255,  75.0 / 255),            // yellow       #F2BB4B 242, 187,  75
        (233.0 / 255, 233.0 / 255, 233.0 / 255),            // white        #E9E9E9 233, 233, 233
        ( 75.0 / 255,  75.0 / 255,  75.0 / 255),            // black        #4B4B4B  75,  75,  75
    ]
    
    let borderColors: [(CGFloat, CGFloat, CGFloat)] = [
        (165.0 / 255,  60.0 / 255,  59.0 / 255),            // red          #A53C3B 165,  60,  59
        (110.0 / 255,  52.0 / 255, 116.0 / 255),            // purple       #8A4292 110,  52, 116
        ( 41.0 / 255,  96.0 / 255, 196.0 / 255),            // blue         #2960C4  41,  96, 196
        (  9.0 / 255, 171.0 / 255, 207.0 / 255),            // turquoise    #09ABCF   9, 171, 207
        ( 96.0 / 255, 147.0 / 255,  68.0 / 255),            // green        #609344  96, 147,  68
        (193.0 / 255, 149.0 / 255,  60.0 / 255),            // yellow       #C1953C 193, 149,  60
        (200.0 / 255, 200.0 / 255, 200.0 / 255),            // white        #C8C8C8 200, 200, 200
        ( 45.0 / 255,  45.0 / 255,  45.0 / 255),            // black        #808080  45,  45,  45
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initComponents()
        
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
        setupSpecificSettings()
        setupSettingsButton()
    }
    
    func setupSpecificSettings(){
        specificSettingsView.layer.cornerRadius = 20
        specificSettingsView.layer.masksToBounds = false
        specificSettingsView.layer.borderWidth = 1.0
        specificSettingsView.layer.borderColor = UIColor(displayP3Red: 102.0/255, green: 170.0/255, blue: 179.0/255, alpha: 0.75).cgColor
        specificSettingsView.layer.shadowColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 0.25).cgColor
        specificSettingsView.layer.shadowOpacity = 1
        specificSettingsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        specificSettingsView.layer.shadowRadius = 4
        setupOpacityComponents()
        setupSizeComponents()
    }
    
    func setupSettingsButton(){
        let x = (buttonContainer.frame.width - brushWidth) / 2
        let y = 0 - (brushWidth / 2) + 44
        
        paintDot.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: brushWidth, height: brushWidth))
        paintDot.alpha = opacity
        paintDot.layer.cornerRadius = brushWidth / 2
        paintDot.backgroundColor = color
        
        brushColor.alpha = opacity
    }
    
    func setupOpacityComponents(){
        opacityLabel.text = "Opacity"
        opacity = 0.5
    }
    
    func setupSizeComponents(){
        sizeLabel.text = "Size"
    }
    
    func setupPaletteFrame(){
        opacitySlider.maximumTrackTintColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 0.25)
        sizeSlider.maximumTrackTintColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 0.25)
        
        let colSize = (specificSettingsView.frame.width - 40) / 8.0;
        var i = 0
        for entry in colors {
            let iAsFloat = CGFloat(i)
            let colorSelectView = UIControl(frame: CGRect(x: iAsFloat*colSize, y: 0, width: colSize, height: 44))
            let colorSpot = UIView(frame: CGRect(x: colSize/4.0, y: colSize/4.0, width: colSize/2.0, height: colSize/2.0))
            let borderColor = borderColors[i]
            colorSpot.backgroundColor = UIColor(displayP3Red: entry.0, green: entry.1, blue: entry.2, alpha: 1.0)
            colorSpot.layer.borderWidth = 1.0
            colorSpot.layer.borderColor = UIColor(red: borderColor.0, green:borderColor.1, blue: borderColor.2, alpha: 1.0).cgColor
            colorSpot.layer.cornerRadius = colSize/4.0
            colorSelectView.addSubview(colorSpot)
            
            // Add listener and info used for color selection
            colorSelectView.isUserInteractionEnabled = true
            var ac:Selector?
            if i == 0 {
                ac = #selector(setRedColor)
            }else if i == 1 {
                ac = #selector(setPurpleColor)
            }else if i == 2 {
                ac = #selector(setBlueColor)
            }else if i == 3 {
                ac = #selector(setTurquoiseColor)
            }else if i == 4 {
                ac = #selector(setGreenColor)
            }else if i == 5 {
                ac = #selector(setYellowColor)
            }else if i == 6 {
                ac = #selector(setWhiteColor)
            }else {
                ac = #selector(setBlackColor)
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
        /*
         1.
         Get device ID
         2. Add Incrementer
         3.
         */
        let imageName = self.canaryModel.getImageName()
        //canaryModel.getClosestLibrary(lat: <#T##Double#>, long: <#T##Double#>)
        self.canaryModel.uploadImageToFirebase(imageName, img: self.mainImageView.image)
        self.canaryModel.addMessage(imageName: imageName)
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
    @objc func setRedColor(){
        color = UIColor.init(red: colors[0].0, green: colors[0].1, blue: colors[0].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushRed")
        print("Red")
        setupSettingsButton()
    }
    @objc func setPurpleColor(){
        color = UIColor.init(red: colors[1].0, green: colors[1].1, blue: colors[1].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushPurple")
        print("Purple")
        setupSettingsButton()
    }
    @objc func setBlueColor(){
        color = UIColor.init(red: colors[2].0, green: colors[2].1, blue: colors[2].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushBlue")
        print("Blue")
        setupSettingsButton()
    }
    @objc func setTurquoiseColor(){
        color = UIColor.init(red: colors[3].0, green: colors[3].1, blue: colors[3].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushTurquoise")
        print("Cyan")
        setupSettingsButton()
    }
    @objc func setGreenColor(){
        color = UIColor.init(red: colors[4].0, green: colors[4].1, blue: colors[4].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushGreen")
        print("Green")
        setupSettingsButton()
    }
    @objc func setYellowColor(){
        color = UIColor.init(red: colors[5].0, green: colors[5].1, blue: colors[5].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushYellow")
        print("Yellow")
        setupSettingsButton()
    }
    @objc func setWhiteColor(){
        color = UIColor.init(red: colors[6].0, green: colors[6].1, blue: colors[6].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushWhite")
        print("White")
        setupSettingsButton()
    }
    @objc func setBlackColor(){
        color = UIColor.init(red: colors[7].0, green: colors[7].1, blue: colors[7].2, alpha: 1.0)
        brushColor.image = UIImage(named: "BrushBlack")
        setupSettingsButton()
        print("Black")
    }
    
    // Actions
    @IBAction func resetButtonAction(_ sender: UIBarButtonItem) {
        mainImageView.image = nil
    }
}
