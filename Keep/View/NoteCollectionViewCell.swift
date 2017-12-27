//
//  NoteCollectionViewCell.swift
//  Keep
//
//  Created by Obi-Voin Kenobi on 12/20/17.
//  Copyright © 2017 Obi-Voin Kenobi. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {

    var id: NSUUID!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var background: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenWidth = UIScreen.main.bounds.size.width
        let collectionViewWidth = screenWidth - (16 * 2)
        let cellWidth = collectionViewWidth / 2
        let cellWidthWithSpacing = cellWidth - 4
        
        widthConstraint.constant = cellWidthWithSpacing
    }
    
    func setNoteData(note: Note) {
        self.id = note.id! as NSUUID
        self.title.text = note.title ?? "Untitle"
        self.note.text = note.note ?? "Empty Note"
    }

}
