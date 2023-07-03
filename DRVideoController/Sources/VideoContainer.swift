//
//  VideoContainer.swift
//  DevReels
//
//  Created by hanjongwoo on 2023/05/14.
//  Copyright © 2023 DevReels. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class VideoContainer {
    
    var url: String
    
    var shouldPlay = true {
        didSet {
            if shouldPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    
    var playOn: Bool {
        didSet {
            player.isMuted = VideoPlayerController.sharedVideoPlayer.mute
            playerItem.preferredPeakBitRate = VideoPlayerController.sharedVideoPlayer.preferredPeakBitRate
            if playOn && playerItem.status == .readyToPlay {
                player.play()
                shouldPlay = true
                print("PLAY")
            } else {
                player.pause()
                shouldPlay = false
                print("PAUSE")
            }
        }
    }
    
    let player: AVPlayer
    
    let playerItem: AVPlayerItem
    
    init(player: AVPlayer, item: AVPlayerItem, url: String) {
        self.player = player
        self.playerItem = item
        self.url = url
        playOn = false
    }
}
