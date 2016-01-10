//
//  DocumentCell.swift
//  VKStorage
//
//  Created by Mike on 1/7/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var previewImageView: UIImageView!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var moreButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .None
    titleLabel.lineBreakMode = .ByTruncatingMiddle
    progressView.progress = 0
    progressView.hidden = true
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    progressView.hidden = true
  }
  
}

extension DocumentCell : ProgressDelegate {
  func progressDidChange(completionPercentage: Float) {
    progressView.progress = completionPercentage
    if completionPercentage == 1.0 {
      progressView.hidden = true
    }
  }
}