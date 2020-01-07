//
//  StationPlaybackController.swift
//
//
//  Created by Arveen kumar on 8/30/19.
//  Copyright © 2019 Feed FM. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import FeedMedia

class NowPlayingController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var favHeartView: UIButton!
    @IBOutlet weak var station: UILabel!
    @IBOutlet weak var playButton: UIView!
    @IBOutlet weak var playButtons: UIView!
    @IBOutlet weak var trackAndArtist: UILabel!
    @IBOutlet weak var remainingTime: FMRemainingTimeLabel!
    @IBOutlet weak var elapsedTime: FMElapsedTimeLabel!
    @IBOutlet weak var progressBar: FMProgressView!
    @IBOutlet weak var stationDescription: MarqueeLabel!
    @IBOutlet weak var stationTags: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playPauseLabel: UILabel!
    
    var color: UIColor = UIColor.hexStringToUIColor(hex: "#5CADB5")
    var favorites: Array<String>? = nil
    var player:FMAudioPlayer = FMAudioPlayer.shared()
    
    
    override func viewDidLoad() {
        // Watch for player events
        NotificationCenter.default.addObserver( self, selector: #selector(self.stationChanged), name: NSNotification.Name.FMAudioPlayerActiveStationDidChange, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(self.itemChanged), name: NSNotification.Name.FMAudioPlayerCurrentItemDidBeginPlayback, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(self.stateChanged), name: NSNotification.Name.FMAudioPlayerPlaybackStateDidChange, object: nil)
        
        let defaults = UserDefaults.standard
        favorites = defaults.array(forKey: "favorites") as? Array<String> ?? []
        playButtons.clipsToBounds = true
        controlsView.clipsToBounds = true
        favHeartView.layer.cornerRadius = 5.0
        controlsView.layer.cornerRadius = 4.0
        playButtons.backgroundColor = self.color
        
    }
    
    //
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        self.favorites = defaults.array(forKey: "favorites") as? Array<String> ?? []
        player.whenAvailable({
            // Post a notification to make sure UI is up to date
            let notification = NSNotification.init(name: NSNotification.Name.FMAudioPlayerCurrentItemDidBeginPlayback, object: nil)
            self.itemChanged(notification: notification)
                
            
            self.station.text = self.player.activeStation.name
            for option in self.player.activeStation.options!
            {
                let optionKey = option.key as! String
                if(optionKey == "artists" || optionKey == "Artists" )
                {
                    self.stationDescription.text = ((option.value as? String ?? " "))
                }
            }
            
            if(self.favorites?.contains( self.player.activeStation.name) ?? false)
            {

                self.favHeartView.subviews.forEach { ($0 as! UIImageView).isHighlighted = true }
                self.favHeartView.backgroundColor = self.color
            }
            self.progressBar.progressTintColor = self.color
            self.elapsedTime.textColor = self.color
            self.addTags()
            
        }) {
            // Do nothing
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Now Playing")
    }
    
    // Station has changed
    
    @objc func stationChanged(notification:NSNotification)  {
        
        self.station.text = self.player.activeStation.name
        
        let defaults = UserDefaults.standard
        self.favorites = defaults.array(forKey: "favorites") as? Array<String> ?? []
        if(self.favorites?.contains( self.player.activeStation.name) ?? false)
        {
            self.favHeartView.backgroundColor = self.color
        }
        self.addTags()
        
    }
    
    
    // Retrive tags form the current station options(if any) and show them in UI in a presentable way
    
    func addTags()  {
        
        var name:String = ""
        for option in self.player.activeStation.options!
        {
            let optionKey = option.key as! String
            if(optionKey.caseInsensitiveCompare("genre")  == .orderedSame || optionKey.caseInsensitiveCompare("intensity")  == .orderedSame || optionKey.caseInsensitiveCompare("bpm")  == .orderedSame) {
                let label = UILabel()
                label.font = UIFont.preferredFont(forTextStyle: .body)
                label.textColor = .white
                label.textAlignment = .center
                let str = option.key as? String
                if(!name.isEmpty)
                {
                    name = name + ", "
                }
                if(str?.contains("BPM") ?? false || str?.contains("bpm")  ?? false){
                    
                    name = name+(option.value as? String ?? "")+" BPM"
                }
                else {
                    name = name+(option.value as? String ?? "")
                }
            }
        }
        stationTags.text = name
        
        
    }
    // Manage fav button
    @IBAction func favClicked(_ sender: Any) {
        if((favorites?.contains(player.activeStation.name))!)
        {
            (sender as! UIButton).backgroundColor = UIColor.hexStringToUIColor(hex: "#F1F1F1")
            (sender as! UIButton).subviews.forEach { ($0 as! UIImageView).isHighlighted = false }
            let temp = favorites?.firstIndex(of:player.activeStation.name)
            if(temp != nil){
                favorites?.remove(at:temp!)
            }
        }
        else {

            favHeartView.backgroundColor = self.color
            (sender as! UIButton).subviews.forEach { ($0 as! UIImageView).isHighlighted = true }
            favorites?.append(player.activeStation.name)
        }
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
    }
    
    // Watch for player state chaged between play and pause
    
    @objc func stateChanged(notification:NSNotification)  {
        if(self.playPauseLabel == nil)
        {
            return
        }
        switch self.player.playbackState {
        case FMAudioPlayerPlaybackState.playing, FMAudioPlayerPlaybackState.stalled, FMAudioPlayerPlaybackState.requestingSkip, FMAudioPlayerPlaybackState.waitingForItem:
            self.playPauseLabel.text = "PAUSE"
            
        default:
            self.playPauseLabel.text = "PLAY"
        }
    }
    
    // Song has changed so update UI
    @objc func itemChanged(notification:NSNotification)  {
        
        // This can be dome with setting the label class to FMMetadata label as well and adding formart parameter
        // Look at artist and song labels for detail
        self.trackAndArtist.text = (self.player.currentItem?.name ?? "")
        
    }
    
    
}
