//
//  StationViewController.swift
//  
//
//  Created by Arveen kumar on 8/30/19.
//  Copyright © 2019 Feed FM. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import FeedMedia

class StationViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource , IndicatorInfoProvider {

    @IBOutlet weak var favSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var miniProgress: FMProgressView!
    @IBOutlet weak var miniPlay: FMPlayPauseButton!
    
    var stationList:Array<FMStation>!
    var player:FMAudioPlayer = FMAudioPlayer.shared()
    var tabcontroller:PagerTabStripViewController?
    var cellSpacingHeight :CGFloat = 10.0
    var color: UIColor? = UIColor.hexStringToUIColor(hex: "#5CADB5")
    var favorites: Array<String> = []
    
    override func viewDidLoad() {
       miniPlay.isEnabled = true
       miniPlay.isHidden = true
       self.tableview.rowHeight = 75;
       player.whenAvailable({
            self.miniPlay.isHidden = true
            self.player.disableSongStartNotifications = true
            self.player.secondsOfCrossfade = 6.0
            self.stationList = self.player.stationList as? Array<FMStation>
            self.tableview.dataSource = self;
            self.tableview.delegate = self
            self.tableview.reloadData()
       })
       {
            // Do nothing
       }
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        favSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        favSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        favSegmentedControl.layer.cornerRadius = 5
        let defaults = UserDefaults.standard
        favorites = defaults.array(forKey: "favorites") as? Array<String> ?? []
        
        miniPlay.backgroundColor = self.color
        miniProgress.progressTintColor = self.color
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        self.favorites = defaults.array(forKey: "favorites") as? Array<String> ?? []
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stationList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MYTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "TableViewCell") as! MYTableViewCell
        

        if let st:FMStation = stationList?[indexPath.section] {
            cell.stationName.text = st.name
            for option in st.options!
            {
                let optionKey = option.key as! String
                if(optionKey == "artists" || optionKey == "Artists" )
                {
                    cell.artistsName.text = ((option.value as? String ?? " ")) 
                }
            }
            if(self.isStationAFav(station: st)){
                cell.logoView.backgroundColor = color
                cell.logoView.subviews.forEach { ($0 as! UIImageView).isHighlighted = true }
            }
            else
            {
                cell.logoView.backgroundColor = UIColor.hexStringToUIColor(hex: "#F1F1F1")
                cell.logoView.subviews.forEach { ($0 as! UIImageView).isHighlighted = false }
            }
        }
        cell.logoView.tag = indexPath.section
        cell.logoView.addTarget(self, action: #selector(favButtonClicked(_:)) , for: UIControl.Event.touchUpInside)
        cell.logoView.layer.cornerRadius = 4
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 4
        let shadowPath = UIBezierPath(rect: cell.bounds)
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.layer.shadowOpacity = 0.07
        cell.layer.shadowPath = shadowPath.cgPath
        
        //cell.clipsToBounds = true
        return cell
    }
    
    @objc func favButtonClicked(_ sender:UIButton) {
        let index = sender.tag as Int
        let station = self.stationList[index]
        if(self.isStationAFav(station: station)){
            sender.backgroundColor = UIColor.hexStringToUIColor(hex: "#F1F1F1")
            sender.subviews.forEach { ($0 as! UIImageView).isHighlighted = false }
            if let index = favorites.firstIndex(of: station.name){
                favorites.remove(at: index)
            }
        }
        else {
            sender.backgroundColor = color
            sender.subviews.forEach { ($0 as! UIImageView).isHighlighted = true }
            favorites.append(station.name)
        }
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
    }
    
    func isStationAFav(station: FMStation) -> Bool {
        for str:String in favorites {
            if(station.name.contains(str))
            {
                return true
            }
        }
        return false
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        tabcontroller = pagerTabStripController
        return IndicatorInfo(title: "Stations")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        tableView.deselectRow(at: indexPath, animated: true)
        if let st = stationList?[indexPath.section] {
            
            player.setActiveStation(st , withCrossfade: true)
            if(player.playbackState != FMAudioPlayerPlaybackState.playing){
                player.play()
            }
            tabcontroller?.moveToViewController(at: 1, animated: true)
            self.miniPlay.isHidden = false
        }
        
    }
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl){
        
        if(sender.selectedSegmentIndex == 0)
        {
            self.stationList = self.player.stationList as? Array<FMStation>
        }
        else
        {
            self.stationList.removeAll()
            guard let tempList  = self.player.stationList as? Array<FMStation> else { return }
            for item in tempList {
                if self.isStationAFav(station: item)
                {
                    self.stationList.append(item)
                }
            }
        }
        tableview.reloadData()
    }
}

class MYTableViewCell: UITableViewCell {
    
    @IBOutlet weak var logoView: UIButton!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var artistsName: UILabel!
    
    
}
