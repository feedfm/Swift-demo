//
//  ParentViewController.swift
//  
//
//  Created by Arveen kumar on 8/28/19.
//  Copyright © 2019 Feed FM. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import FeedMedia


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension UIColor {
    
    static func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )

    }
}


class ParentViewController: ButtonBarPagerTabStripViewController  {
        
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tabContainerView: UIView!
    @IBOutlet weak var backView: UIView!
    var logo_url = "https://feed.fm/images/feedfm-logo-greyred.png"
    var color: UIColor = UIColor.hexStringToUIColor(hex: "#21262B")
    var defaultColor: UIColor = UIColor.hexStringToUIColor(hex: "#5CADB5")
    override func viewDidAppear(_ animated: Bool) {
        
    
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    override func viewDidLoad() {
        prepareUI()
        let shadowPath = UIBezierPath(rect: tabContainerView.bounds)
        tabContainerView.layer.masksToBounds = false
        tabContainerView.layer.shadowColor = UIColor.black.cgColor
        tabContainerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        tabContainerView.layer.shadowOpacity = 0.07
        tabContainerView.layer.shadowRadius = 5
        tabContainerView.layer.shadowPath = shadowPath.cgPath
       let darkCol = UIColor.hexStringToUIColor(hex: "#21262B")
       if #available(iOS 13.0, *) {
           let app = UIApplication.shared
           let statusBarHeight: CGFloat = app.statusBarFrame.size.height

           let statusbarView = UIView()
           statusbarView.backgroundColor = darkCol
           view.addSubview(statusbarView)
           statusbarView.translatesAutoresizingMaskIntoConstraints = false
           statusbarView.heightAnchor
               .constraint(equalToConstant: statusBarHeight).isActive = true
           statusbarView.widthAnchor
               .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
           statusbarView.topAnchor
               .constraint(equalTo: view.topAnchor).isActive = true
           statusbarView.centerXAnchor
               .constraint(equalTo: view.centerXAnchor).isActive = true

       } else {
           let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
           statusBar?.backgroundColor = darkCol
       }
        // change selected bar color
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.selectedBarVerticalAlignment = .top
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = self.defaultColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            if(newCell?.label.text == nil || oldCell?.label.text == nil) {return}
            let se:String = newCell?.label.text ?? ""
            if(se.contains("Station")) {
                oldCell?.label.textColor = .lightGray
                newCell?.label.textColor = .black
                newCell?.contentView.backgroundColor = .white
                oldCell?.contentView.backgroundColor = .white
            }
            else {
                self.buttonBarView.backgroundColor = .black
                oldCell?.label.textColor = .lightGray
                newCell?.label.textColor = .white
                newCell?.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#383b3e")
                oldCell?.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#2a2e30")
                
                self.buttonBarView.setNeedsDisplay()
            }
        }
        super.viewDidLoad()
        
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NowPlaying")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Stations")
        return [child_2, child_1]
    }
    
    
    func prepareUI() {
        
        FMAudioPlayer.shared().whenAvailable({
            // Player is available
        }, notAvailable: {
            
            // The player is not available for this user due to location or DMCA issues, hide music controls
        })
        
        // Download and set the logo
        logo.downloaded(from: self.logo_url)
        
    }
    
    

}
