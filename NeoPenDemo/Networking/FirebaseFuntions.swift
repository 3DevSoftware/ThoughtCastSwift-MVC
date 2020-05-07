//
//  FirebaseFuntions.swift
//  ThoughtCastiOSRebuilt
//
//  Created by Trevor Walker on 11/4/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseFunctions {
    
    static func login(email: String, password: String, completion: @escaping (Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if let error = error{
                print("Error in \(#function) : \(error.localizedDescription) /n--/n \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    static func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
            completion(false)
            return
        }
        completion(true)
    }
    
    static func pullUserData(email: String, completion: @escaping (Bool, DocumentSnapshot?) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(email)
        docRef.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription + " --> \(error)")
                completion(false, nil)
                return
            }
            completion(true, document)
        }
    }
}
