//
//  CoreDataCRUD.swift
//  Keep
//
//  Created by Obi-Voin Kenobi on 12/21/17.
//  Copyright © 2017 Obi-Voin Kenobi. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataCRUD {
    
    static let shared = CoreDataCRUD()
    
    private var appDelegate: AppDelegate!
    private var context: NSManagedObjectContext!
    private var entity: NSEntityDescription!
    
    private let entityName = "Notes"
    private let KEY_ID = "id"
    private let KEY_TITLE = "title"
    private let KEY_NOTE = "note"
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        
        // Init Variables for Core Data Usage
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    public func insert(noteValue: Note) -> Bool {
        let note = NSManagedObject(entity: entity, insertInto: context)
        
        note.setValue(NSUUID(), forKey: KEY_ID)
        note.setValue(noteValue.title, forKey: KEY_TITLE)
        note.setValue(noteValue.note, forKey: KEY_NOTE)
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
            return false
        }
        return true
    }
    
    public func select() -> [Note]? {
        var notes: [Note]?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            notes = [Note]()
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: KEY_ID) as! NSUUID
                let title = data.value(forKey: KEY_TITLE) as? String
                let note = data.value(forKey: KEY_NOTE) as? String
                
                notes?.append(Note(id: id, title: title, note: note))
            }
        } catch {
            print("Failed")
        }
        
        return notes
    }
    
    public func update(updateNote: Note) -> Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", updateNote.id)
        
        do {
            let result = try context.fetch(request)
            
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: KEY_ID) as! NSUUID
                
                if id.isEqual(updateNote.id) {
                    data.setValue(updateNote.title, forKey: KEY_TITLE)
                    data.setValue(updateNote.note, forKey: KEY_NOTE)
                    break;
                }
                
            }
            
            try context.save()
            return true
        } catch {
            print("Failed")
        }
        return false
    }
    
    
    public func delete(uuid: NSUUID) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", uuid)
        
        do {
            let result = try context.fetch(request)
            
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: KEY_ID) as! NSUUID
                
                if id.isEqual(uuid) {
                    context.delete(data)
                    try context.save()  
                    return true
                }
            }
        } catch {
            print("Failed")
        }
        return false
    }
}

