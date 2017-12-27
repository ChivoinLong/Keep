//
//  ViewController.swift
//  Keep
//
//  Created by Obi-Voin Kenobi on 12/19/17.
//  Copyright © 2017 Obi-Voin Kenobi. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var notesCollectionView: UICollectionView!
    @IBOutlet weak var newNoteLabel: UILabel!
    @IBOutlet weak var newNoteTabBar: UITabBar!
    
    private var notes: [Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let noteCellNib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
        notesCollectionView.register(noteCellNib, forCellWithReuseIdentifier: "noteCell")
        if let flowLayout = notesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        notesCollectionView.dataSource = self
        notesCollectionView.delegate = self
        
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        notesCollectionView.addGestureRecognizer(longPressGesture)
        
        clearTabBarBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
}

extension HomeViewController {
    
    private func refresh() {
        notes = CoreDataCRUD.shared.select()
        notesCollectionView.reloadData()
    }
    
    private func clearTabBarBorder() {
        newNoteTabBar.backgroundImage = UIImage()
        newNoteTabBar.shadowImage = UIImage()
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "gotoDetailSegue", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDetailSegue" {
            if let destination = segue.destination as? DetailViewController {
                if let selectedNote = sender as? Note {
                    destination.isNewNote = false
                    destination.selectedNote = selectedNote
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
        
        cell.setNoteData(note: notes![indexPath.item])
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoDetailSegue", sender: notes![indexPath.item])
    }
    
}


// Handle Deleting Process
extension HomeViewController {
    
    @objc func handleLongGesture(gesture : UILongPressGestureRecognizer!) {
        
        guard gesture.state != .ended else {
            return
        }
        
        let point = gesture.location(in: notesCollectionView)
        
        guard let indexPath = notesCollectionView.indexPathForItem(at: point) else {
            print("couldn't find index path")
            return
        }
        
        
        // Get the Cell at IndexPath
        let selectedCell = notesCollectionView.cellForItem(at: indexPath) as! NoteCollectionViewCell
        
        // Init Action Sheet
        let actionSheet = UIAlertController(title: "Do you want to delete this note?", message: nil, preferredStyle: .actionSheet)
        
        // Init Actions for Action Sheet
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            if CoreDataCRUD.shared.delete(uuid: selectedCell.id) {
                self.refresh()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Set Actions
        actionSheet.addAction(actionDelete)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
}
