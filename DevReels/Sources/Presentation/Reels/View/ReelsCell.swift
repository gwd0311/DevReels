//
//  ReelsCell.swift
//  DevReels
//
//  Created by hanjongwoo on 2023/05/14.
//  Copyright © 2023 DevReels. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ReelsCell: UITableViewCell, Identifiable {
    
    // MARK: - Properties
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "릴스제목"
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.text = "설명"
    }
    
    private lazy var thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    private lazy var bottomGradientImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    internal lazy var videoLayer = AVPlayerLayer().then {
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        $0.backgroundColor = UIColor.clear.cgColor
        $0.videoGravity = AVLayerVideoGravity.resize
    }
    
    var playerController: VideoPlayerController?
    
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                VideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    // MARK: - Inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        thumbnailImageView.imageURL = nil
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradient()
    }
    
    func configureGradient() {
        let util = Utilities.shared
        let color1 = UIColor.black.withAlphaComponent(0.0)
        let color2 = UIColor.black.withAlphaComponent(0.7)
        let gradient = util.createGradient(color1: color1, color2: color2, frame: bottomGradientImageView.bounds)
        bottomGradientImageView.image = gradient
    }
    
    func configureCell(data: VideoObject) {
        self.thumbnailImageView.imageURL = data.thumbnailURL
        self.videoURL = data.videoURL
        self.titleLabel.text = data.title
        self.descriptionLabel.text = data.videoDescription
    }
    
    // MARK: - Layout
    private func layout() {
        contentView.addSubViews([thumbnailImageView, bottomGradientImageView, titleLabel, descriptionLabel])

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(-150)
            $0.leading.equalTo(contentView.snp.leading).offset(20)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(-120)
            $0.leading.equalTo(thumbnailImageView.snp.leading).offset(20)
            $0.trailing.equalTo(thumbnailImageView.snp.trailing).offset(-20)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomGradientImageView.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(-120)
            $0.leading.equalTo(thumbnailImageView.snp.leading)
            $0.trailing.equalTo(thumbnailImageView.snp.trailing)
            $0.bottom.equalTo(thumbnailImageView.snp.bottom)
        }
        
        thumbnailImageView.layer.addSublayer(videoLayer)
    }
}

extension ReelsCell: PlayVideoLayerContainer {
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(
            thumbnailImageView.frame,
            from: thumbnailImageView)
        guard let videoFrame = videoFrameInParentSuperView,
              let superViewFrame = superview?.frame else {
                  return 0
              }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
}